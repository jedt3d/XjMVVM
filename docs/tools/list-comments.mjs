#!/usr/bin/env node
// list-comments.mjs — print all reader comments grouped by chapter (for Claude to read & act on).
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
let data;
try { data = JSON.parse(readFileSync(join(ROOT, "reader", "comments.json"), "utf8")); }
catch { console.log("No comments yet (reader/comments.json not found)."); process.exit(0); }

const comments = data.comments || [];
const onlyOpen = process.argv.includes("--open");
const shown = onlyOpen ? comments.filter((c) => c.status !== "resolved") : comments;
if (!shown.length) { console.log(onlyOpen ? "No open comments." : "No comments yet."); process.exit(0); }

const byCh = {};
for (const c of shown) (byCh[c.chapter] = byCh[c.chapter] || []).push(c);
const open = comments.filter((c) => c.status !== "resolved").length;
console.log(`# Reader comments — ${shown.length} shown, ${open} open, ${comments.length} total\n`);
for (const ch of Object.keys(byCh).sort()) {
  console.log(`## ${ch}`);
  for (const c of byCh[ch].sort((a, b) => a.anchor.localeCompare(b.anchor, undefined, { numeric: true }))) {
    const badge = c.status === "resolved" ? "[resolved]" : "[OPEN]";
    const fb = c.feedback === "up" ? " 👍" : c.feedback === "down" ? " 👎" : "";
    const kind = c.parentId ? "reply" : "highlight";
    console.log(`  ${badge} (${c.id}) @${c.anchor} — ${c.author} [${kind}]${fb}`);
    if (c.quote) console.log(`    quoted: "${c.quote}"`);
    console.log(`    💬 ${c.body.replace(/\n/g, "\n       ")}`);
  }
  console.log("");
}
