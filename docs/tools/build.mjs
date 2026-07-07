// build.mjs — generate the static docs site from book/meta.json + book/*.md
// Directives (each on its own line in the markdown):
//   [[diagram:<name>|<caption>]]            inline diagrams/svg/<name>.svg in a pan/zoom viewer
//   [[snippet:<relpath>:<start-end>|<cap>]]  code snippet pulled from the Pi v0.80.3 source
// Raw HTML (e.g. <div class="note">…</div>) passes through marked untouched.
import { readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync, rmSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { marked } from "marked";
import { renderSnippet } from "./snippet.mjs";
import { escapeHtml, highlightCode } from "./highlighting.mjs";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const meta = JSON.parse(readFileSync(`${ROOT}/book/meta.json`, "utf8"));
// Inline CSS + JS into every page so styling never depends on external/relative fetches.
const FONT_CSS = readFileSync(`${ROOT}/assets/fonts.css`, "utf8");
const CSS = readFileSync(`${ROOT}/assets/book.css`, "utf8");
const READER_CSS = readFileSync(`${ROOT}/assets/reader.css`, "utf8");
const JS = readFileSync(`${ROOT}/assets/viewer.js`, "utf8");
const READER_JS = readFileSync(`${ROOT}/assets/reader.js`, "utf8");
const renderer = new marked.Renderer();
function codeLabel(language, source) {
  if (language === "xojo") return "Xojo example";
  if (language === "bash") return "Shell command";
  if (language === "json") return "JSON";
  if (language === "javascript") return "JavaScript";
  if (language === "markdown") return "Markdown";
  if ((language === "plaintext" || language === "text") && /(^|\n)[^\n]+\/\n/.test(source)) return "Directory listing";
  if ((language === "plaintext" || language === "text") && source.includes(" -> ")) return "Conceptual flow";
  return "Code block";
}

renderer.code = function code({ text, lang }) {
  const info = String(lang || "").match(/^\S*/)?.[0] || "plaintext";
  const source = String(text).replace(/\n$/, "");
  const { html, language } = highlightCode(source, info);
  const label = escapeHtml(codeLabel(language, source));
  return `<figure class="snippet snippet-fence">
  <figcaption class="snip-head">
    <span class="snip-loc snip-label">${label}</span>
    <button class="snip-cmt" data-comment-block title="Comment on this whole block, or highlight lines to comment on a narrower span"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M21 11.5a8.4 8.4 0 0 1-8.5 8.4 8.8 8.8 0 0 1-4-.9L3 20l1-3.9a8.4 8.4 0 1 1 17-4.6z"/></svg>Comment</button>
  </figcaption>
  <div class="snip-body"><pre class="code fence lang-${language}"><code>${html}</code></pre></div>
</figure>\n`;
};
marked.setOptions({ mangle: false, headerIds: false, renderer });

const ICONS = {
  zoomin: '<svg class="ic" viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.6" y2="16.6"/><line x1="11" y1="8" x2="11" y2="14"/><line x1="8" y1="11" x2="14" y2="11"/></svg>',
  zoomout: '<svg class="ic" viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.6" y2="16.6"/><line x1="8" y1="11" x2="14" y2="11"/></svg>',
  fit: '<svg class="ic" viewBox="0 0 24 24" aria-hidden="true"><polyline points="4 9 4 4 9 4"/><polyline points="20 9 20 4 15 4"/><polyline points="4 15 4 20 9 20"/><polyline points="20 15 20 20 15 20"/></svg>',
  reset: '<svg class="ic" viewBox="0 0 24 24" aria-hidden="true"><rect x="4" y="4" width="16" height="16" rx="2"/></svg>',
};

function inlineSvg(name) {
  const p = `${ROOT}/diagrams/svg/${name}.svg`;
  if (!existsSync(p)) return `<div class="note">Missing diagram: ${name}.svg</div>`;
  let svg = readFileSync(p, "utf8").replace(/<\?xml[\s\S]*?\?>/i, "").replace(/<!DOCTYPE[\s\S]*?>/i, "");
  svg = svg.replace(/(<svg\b[^>]*?)\swidth="[^"]*"/i, "$1").replace(/(<svg\b[^>]*?)\sheight="[^"]*"/i, "$1");
  svg = svg.replace(/<svg\b/i, '<svg preserveAspectRatio="xMidYMid meet"');
  return svg;
}

function diagramBlock(name, caption, figNo) {
  const cap = caption ? `<figcaption class="figcap"><b>Figure ${figNo}</b> - ${caption}</figcaption>` : "";
  return `<figure class="diagram">
  <div class="figure-frame">
    <div class="toolbar">
      <button class="tool" data-act="zoomin">${ICONS.zoomin}Zoom in</button>
      <button class="tool" data-act="zoomout">${ICONS.zoomout}Zoom out</button>
      <button class="tool" data-act="fit">${ICONS.fit}Fit</button>
      <button class="tool" data-act="reset">${ICONS.reset}1:1</button>
      <span class="hint" data-role="zoomlabel">100%</span>
      <span class="spacer"></span>
      <button class="tool cmt-btn" data-comment-block title="Comment on this whole diagram"><svg class="ic" viewBox="0 0 24 24" aria-hidden="true"><path d="M21 11.5a8.4 8.4 0 0 1-8.5 8.4 8.8 8.8 0 0 1-4-.9L3 20l1-3.9a8.4 8.4 0 1 1 17-4.6z"/></svg>Comment</button>
    </div>
    <div class="stage"><div class="canvas">${inlineSvg(name)}</div></div>
  </div>${cap}</figure>`;
}

// Replace directive lines with placeholder tokens, render markdown, then substitute HTML back.
function renderChapter(md, chapterNum) {
  const blocks = [];
  let figNo = 0;
  const lines = md.split("\n").map((line) => {
    const dg = line.match(/^\s*\[\[diagram:([^|\]]+)(?:\|([^\]]*))?\]\]\s*$/);
    if (dg) { figNo++; blocks.push(diagramBlock(dg[1].trim(), (dg[2] || "").trim(), `${chapterNum}.${figNo}`)); return ` B${blocks.length - 1} `; }
    const sn = line.match(/^\s*\[\[snippet:([^:]+):([0-9]+-?[0-9]*)(?:\|([^\]]*))?\]\]\s*$/);
    if (sn) { blocks.push(renderSnippet(sn[1].trim(), sn[2].trim(), (sn[3] || "").trim())); return ` B${blocks.length - 1} `; }
    const as = line.match(/^\s*\[\[aside:(.+?)\]\]\s*$/);
    if (as) { blocks.push(`<aside class="mnote">${marked.parseInline(as[1].trim())}</aside>`); return ` B${blocks.length - 1} `; }
    return line;
  });
  let html = marked.parse(lines.join("\n"));
  html = html.replace(/<p> B(\d+) <\/p>/g, (_, i) => blocks[+i]);
  html = html.replace(/ B(\d+) /g, (_, i) => blocks[+i]);
  return html;
}

const allChapters = meta.parts.flatMap((p) => p.chapters.map((c) => ({ ...c, partLabel: p.label })));
const realChapters = allChapters.filter((c) => c.file);

function chnav(idx) {
  const prev = realChapters[idx - 1], next = realChapters[idx + 1];
  const prevH = prev ? `<a class="prev" href="${prev.slug}.html"><span class="dir">← Previous</span><span class="t">${prev.title}</span></a>` : `<a class="prev disabled"></a>`;
  const nextH = next ? `<a class="next" href="${next.slug}.html"><span class="dir">Next →</span><span class="t">${next.title}</span></a>` : `<a class="next" href="index.html"><span class="dir">Back →</span><span class="t">Contents</span></a>`;
  return `<nav class="chnav">${prevH}${nextH}</nav>`;
}

function page(title, bodyClass, inner, slug = "") {
  const lang = meta.lang || "en";
  const brand = meta.brand || meta.title || "XjMVVM";
  return `<!doctype html>
<html lang="${lang}"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title}</title>
<style>${FONT_CSS}${CSS}${READER_CSS}</style>
</head><body class="${bodyClass}" data-slug="${slug}">
<div class="topbar"><a class="brand" href="index.html">${brand.replace(/\s+/g, '<span class="dot">·</span>')}</a><span class="spacer"></span><a class="tnav" href="index.html">Contents</a></div>
${inner}
<script>${JS}</script>
<script>${READER_JS}</script>
</body></html>`;
}

// ---- build chapter pages ----
mkdirSync(`${ROOT}/site`, { recursive: true });
for (const file of readdirSync(`${ROOT}/site`)) {
  if (file.endsWith(".html")) rmSync(`${ROOT}/site/${file}`);
}
realChapters.forEach((c, i) => {
  const md = readFileSync(`${ROOT}/book/${c.file}`, "utf8");
  const inner = `<main class="wrap"><article class="prose">
<p class="chapter-kicker">${c.partLabel} · Chapter ${c.num}</p>
${renderChapter(md, c.num)}
${chnav(i)}
</article></main>`;
  writeFileSync(`${ROOT}/site/${c.slug}.html`, page(`${c.title} — ${meta.title}`, "chapter", inner, c.slug));
});

// ---- build contents (index) ----
let toc = "";
for (const part of meta.parts) {
  const items = part.chapters.map((c) => {
    const cls = c.file ? "" : "todo";
    const href = c.file ? `${c.slug}.html` : "#";
    const flag = c.file ? "" : `<span class="ch-flag">เร็ว ๆ นี้</span>`;
    return `<li><a class="${cls}" href="${href}"><span class="ch-num">${c.num}</span><span class="ch-text"><span class="ch-title">${c.title}</span> <span class="ch-sub">${c.sub || ""}</span></span>${flag}</a></li>`;
  }).join("\n");
  toc += `<section class="toc-part"><div class="part-label">${part.label}</div><h2>${part.title}</h2><p class="part-desc">${part.desc || ""}</p><ol class="toc">${items}</ol></section>\n`;
}
const index = `<main class="wrap">
<div class="book-hero"><h1>${meta.title}</h1><p class="tagline">${meta.subtitle}</p><p class="meta">${meta.version} · Developer Guide</p></div>
${toc}</main>`;
writeFileSync(`${ROOT}/site/index.html`, page(`${meta.title}`, "contents", index));

console.log(`Built ${realChapters.length} chapter page(s) + contents -> site/`);
