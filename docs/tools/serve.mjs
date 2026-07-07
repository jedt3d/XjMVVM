#!/usr/bin/env node
// serve.mjs — local reader server: serves the built site + a tiny comments API that
// auto-saves inline notes to reader/comments.json.
// Run: npm run read   → http://localhost:8000/site/
import { createServer } from "node:http";
import { readFileSync, existsSync, mkdirSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, extname, normalize } from "node:path";
import { randomUUID } from "node:crypto";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const DB = join(ROOT, "reader", "comments.json");
const PORT = process.env.PORT || 8000;
const MIME = { ".html": "text/html; charset=utf-8", ".css": "text/css", ".js": "text/javascript",
  ".svg": "image/svg+xml", ".json": "application/json", ".woff2": "font/woff2", ".png": "image/png" };

mkdirSync(join(ROOT, "reader"), { recursive: true });
function load() { try { return JSON.parse(readFileSync(DB, "utf8")); } catch { return { comments: [] }; } }
function save(d) { writeFileSync(DB, JSON.stringify(d, null, 2)); }
if (!existsSync(DB)) save({ comments: [] });

function body(req) {
  return new Promise((res) => { let s = ""; req.on("data", (c) => (s += c)); req.on("end", () => { try { res(JSON.parse(s || "{}")); } catch { res({}); } }); });
}
const json = (r, code, obj) => { r.writeHead(code, { "content-type": "application/json" }); r.end(JSON.stringify(obj)); };

const server = createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const p = url.pathname;

  // ---- comments API ----
  if (p === "/api/ping") return json(res, 200, { ok: true });
  if (p === "/api/comments" && req.method === "GET") {
    const ch = url.searchParams.get("chapter");
    const d = load();
    return json(res, 200, { comments: ch ? d.comments.filter((c) => c.chapter === ch) : d.comments });
  }
  if (p === "/api/comments" && req.method === "POST") {
    const b = await body(req); const d = load();
    const c = { id: randomUUID().slice(0, 8), chapter: b.chapter || "", anchor: b.anchor || "",
      parentId: b.parentId || null, start: Number.isInteger(b.start) ? b.start : null, end: Number.isInteger(b.end) ? b.end : null,
      scope: b.scope || null, node: b.node || null, quote: (b.quote || "").slice(0, 240), body: b.body || "",
      status: "open", author: "reader", createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() };
    d.comments.push(c); save(d); return json(res, 200, c);
  }
  const m = p.match(/^\/api\/comments\/([A-Za-z0-9]+)$/);
  if (m) {
    const d = load(); const c = d.comments.find((x) => x.id === m[1]);
    if (!c) return json(res, 404, { error: "not found" });
    if (req.method === "PATCH") { const b = await body(req);
      if (b.body !== undefined) c.body = b.body;
      if (b.status !== undefined) c.status = b.status;
      if (b.feedback !== undefined) c.feedback = b.feedback;
      c.updatedAt = new Date().toISOString(); save(d); return json(res, 200, c); }
    if (req.method === "DELETE") { d.comments = d.comments.filter((x) => x.id !== m[1]); save(d); return json(res, 200, { ok: true }); }
  }

  // ---- static files ----
  let rel = decodeURIComponent(p === "/" ? "/site/index.html" : p);
  if (rel.endsWith("/")) rel += "index.html";
  const file = normalize(join(ROOT, rel));
  if (!file.startsWith(ROOT) || !existsSync(file)) { res.writeHead(404); return res.end("Not found"); }
  res.writeHead(200, { "content-type": MIME[extname(file)] || "application/octet-stream" });
  res.end(readFileSync(file));
});
server.listen(PORT, () => console.log(`XjMVVM docs reader -> http://localhost:${PORT}/site/   (comments: reader/comments.json)`));
