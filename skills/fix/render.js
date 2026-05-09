#!/usr/bin/env node
const {readFileSync} = require('fs'), {resolve} = require('path');

const tplFile = resolve(process.argv[2]);
const flags = process.argv.slice(3).flatMap(a => a.split(/\s+/)).filter(Boolean);

const raw = readFileSync(tplFile, 'utf8');
const partsIdx = raw.indexOf('\n--- parts\n');
const template = partsIdx < 0 ? raw : raw.slice(0, partsIdx);
const partsRaw = partsIdx < 0 ? '' : raw.slice(partsIdx + '\n--- parts\n'.length);

// Parse parts: "name:\n" at line start begins a new part
const parts = {};
for (const chunk of partsRaw.split(/^(?=[a-zA-Z][\w-]*:$)/m)) {
  const m = chunk.match(/^([a-zA-Z][\w-]*):\n([\s\S]*?)(\n)?$/);
  if (m) parts[m[1]] = m[2];
}

function hasFlag(spec) {
  const [s, l] = spec.split('/'), ch = s[1];
  return flags.some(a => a === s || a === l
    || (a.startsWith('-') && !a.startsWith('--') && a.includes(ch)));
}

function expand(text, depth) {
  if (depth > 10) return text;
  return text.replace(/\{([^}]+)\}/g, (_, expr) => {
    expr = expr.trim();
    // {$rest -a/--agents -c/--commits} — remaining CLI args
    if (expr.startsWith('$rest')) {
      const specs = expr.split(/\s+/).slice(1);
      const chars = specs.map(s => s.split('/')[0][1]);
      const longs = specs.map(s => s.split('/')[1]);
      const rest = flags.filter(a => !longs.includes(a)
        && !(a.startsWith('-') && !a.startsWith('--') && [...a.slice(1)].every(ch => chars.includes(ch))));
      return rest.join(' ');
    }
    // {-f/--flag?if-true:if-false} or {-f/--flag?if-true}
    const cm = expr.match(/^(-[^\s?]+)\?([^\s:]+)(?::(\S+))?$/);
    if (cm) {
      const name = hasFlag(cm[1]) ? cm[2] : cm[3];
      return name && parts[name] ? expand(parts[name], depth + 1) : '';
    }
    // {part-name}
    return parts[expr] != null ? expand(parts[expr], depth + 1) : `{${expr}}`;
  });
}

let out = expand(template, 0);
let n = 0;
out = out.replace(/^#\./gm, () => ++n + '.');
process.stdout.write(out);
