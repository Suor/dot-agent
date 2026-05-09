---
name: benchmark
description: Rules for writing performance benchmarks — fair timing, prod-parity, microbench-before-claiming, RAM measurement, subprocess hygiene. Use when writing/modifying perf benchmarks, comparing backends (redis/etcd/kafka/...), or claiming "X is faster than Y".
---

# Performance benchmarking rules

Apply these whenever writing performance benchmarks or making perf claims. Each rule comes from a real bench-session mistake.

## 1. Use project classes, not self-made wrappers

If the repo already has an API for the thing you want to measure — use it. Do **not** write a fresh async client / HTTP wrapper / gRPC stub just for the bench. The bench must exercise **the same code path that prod uses**, otherwise the result does not reflect reality.

Concrete: before writing any client code, grep for existing classes (`*Client*`, `*Updater*`, `*Connection*`). If prod uses `EtcdClientGRPC` / `CustomDictUpdater*`, the bench must use those too — same proto, same transport, same retry/timeout policy.

## 2. Serialize inside the timer if prod serializes inside

Pre-encoding payloads **before** `with measure(...)` understates time relative to a backend that does `to_json(value)` inside the transaction. Either:
- serialize inside the timed window (mirroring prod), or
- pre-encode for *all* backends being compared (symmetric).

Asymmetric pre-encoding (one backend pre-encoded, another serializing in-band) silently changes the ratios between backends and invalidates the comparison.

## 3. Use the same batched commands prod uses

Don't invent your own access pattern. If prod uses `set_many` / Txn-batch (e.g. up to 30k records per call), and the bench does `await put()` per item, you'll get ×40 worse throughput. That's not "backend A is slower than B" — that's "single requests are slower than batches".

Translate proven prod batching into bench code:
- redis: `pipeline×SET` → `MSET`; per-event `XADD` → batched `XADD` with one orjson blob
- etcd: per-key `Put` → `Txn` with many ops
- kafka: per-message produce → batched produce with `linger_ms`

If the backend has no obvious bulk API, check pipelines + bulk variants — there usually is one.

## 4. Microbench before claiming "X is faster"

Any claim like "X is faster than Y" without a measurement is almost always wrong. Past wrong claims:
- `array.array(iter).tobytes()` vs `struct.pack(*map)` — claimed faster, was 1.4× **slower**
- precompiled `struct.Struct.pack` vs `struct.pack` — gain was 1 µs/call (negligible)
- `set(groups) - index.keys()` vs per-element check — was 5–10× **slower**
- `np.searchsorted` for GUID lookup vs dict — was 4× **slower**

A microbench is 20 lines: `time.perf_counter` loop, tight iteration count, `min(timeit.repeat(...))`. Write it and verify before merging the claim into code or the bench report.

## 5. Subprocess watchers must survive parent death

If the bench spawns child processes (watchers, sidecars, load generators) and doesn't install `prctl(PR_SET_PDEATHSIG, SIGTERM)` + a SIGTERM handler that calls `os._exit(0)`, every crashed run leaks zombies. They will keep running, hold ports, eat memory, and break the next bench until killed manually.

~30 lines of code, fixes the entire category. Add it to every child-spawn helper, not just the one that bit you last time.

## 6. Duplicates in synthetic data are a data bug, not a feature

Sample-with-replacement on a generator + sets/sorted-sets that dedupe → you get `cardinality < N`, and the bench is no longer representative of real data sizes. Either:
- sample without replacement (UUIDs, shuffled index), or
- explicitly flag duplicates as a feature with a knob (`--allow-dup`).

Always assert `len(generated) == requested_n` and `len(set(generated)) == requested_n` (when uniqueness is intended) before the timed phase.

## 7. Redis: jemalloc fragmentation between phases

After a large `used_memory_peak` (e.g. a hashtable variant at 14 GB), RSS does **not** return to the kernel even after `FLUSHALL`. The next variant which legitimately uses 50 MB will still report 1+ GB RSS — pure fragmentation noise.

Between phases, run:
- `MEMORY PURGE`
- `CONFIG RESETSTAT`

Or restart redis between variants (more deterministic). Note in the report which approach was used.

## 8. Use prod config, not defaults

etcd/redis/kafka defaults (e.g. etcd `max-txn-ops 128`, `quota-backend-bytes 2GB`, default RDB save policy) do not reflect prod. With defaults you'll either crash on the first batch or measure synthetically different latencies.

Locate the prod config (e.g. `etcd-servers/runtime/config.yaml`) and use the same values. Document which config the bench was run against — it changes the numbers.

## 9. Measure RAM correctly

- `VmHWM` lies for long-lived processes (`redis-server`, `etcd`) — it reflects peak from previous runs, not this bench's window. Don't use it.
- For long-lived processes: periodic `VmRSS` sampler (e.g. `RSSPoller` at 100ms) over the bench window. Report peak/avg/p99 of that sample, not `VmHWM`.
- For freshly-spawned subprocesses (watchers, load-gens that exit at end of bench): `getrusage(RUSAGE_CHILDREN).ru_maxrss` is correct.

## 10. Tmpfs data dirs count as RAM

If the backend's data dir lives on tmpfs (e.g. etcd runtime `--data-dir /run/ideco-etcd-runtime`), "etcd uses disk" is misleading — etcd is using **additional RAM on top of its process RSS**. Total RAM = `RSS` + `du -sb data-dir`. Report the data-dir size as a separate column; otherwise the comparison vs. an on-disk backend is unfair.

---

## Workflow when invoked

1. Identify which rules apply to the task at hand. Not every bench needs all 10.
2. Before writing code: check rules 1, 3, 8 (existing classes, batched commands, prod config).
3. While writing: keep rules 2, 5, 6 in mind (timing window symmetry, subprocess hygiene, data uniqueness).
4. Before claiming any result: apply rule 4 (microbench) and rules 7, 9, 10 (memory accounting).
5. If the user proposes a comparison or makes a perf claim that violates one of these, push back with the rule and a concrete suggestion.
