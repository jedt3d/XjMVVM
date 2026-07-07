// snippet.mjs — render a code snippet pulled straight from the XjMVVM source.
// Real line numbers (CSS counters, so they don't get copy-pasted), syntax highlighting,
// and a header that links to the file at that line via the VS Code URL scheme.
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import hljs from "highlight.js";

// READ_ROOT: where the build reads source from. By default this is the XjMVVM
// repository root, one level above docs/. Override with XJMVVM_REPO_READ.
// HOST_ROOT: path used in vscode:// jump-links. Override with XJMVVM_REPO_HOST.
const HERE = dirname(fileURLToPath(import.meta.url));
const READ_ROOT = process.env.XJMVVM_REPO_READ || resolve(HERE, "../..");
const HOST_ROOT = process.env.XJMVVM_REPO_HOST || READ_ROOT;

const LANG_BY_EXT = { ts: "typescript", tsx: "typescript", js: "javascript", mjs: "javascript",
  json: "json", md: "markdown", sh: "bash", bash: "bash", zsh: "bash", dot: "dot", css: "css",
  html: "xml", xojo_code: "plaintext", xojo_project: "plaintext", xojo_window: "plaintext" };

function langFor(path) {
  const ext = path.split(".").pop().toLowerCase();
  return LANG_BY_EXT[ext] || "plaintext";
}

// Split highlight.js output into per-line HTML, re-opening any spans that cross a newline.
function splitHighlighted(html) {
  const lines = html.split("\n");
  const out = [];
  const open = [];
  for (const line of lines) {
    const prefixed = open.join("") + line;
    const re = /<span[^>]*>|<\/span>/g;
    let m;
    while ((m = re.exec(line))) {
      if (m[0] === "</span>") open.pop();
      else open.push(m[0]);
    }
    out.push(prefixed + "</span>".repeat(open.length));
  }
  return out;
}

// Strip the common leading indentation shared by every non-blank line, so a snippet
// pulled from deep inside a nested file starts flush-left while keeping relative indents.
function dedent(lines) {
  const indents = lines.filter((l) => l.trim().length).map((l) => l.match(/^[\t ]*/)[0]);
  if (!indents.length) return lines;
  let common = indents[0];
  for (const w of indents.slice(1)) {
    let i = 0;
    while (i < common.length && i < w.length && common[i] === w[i]) i++;
    common = common.slice(0, i);
    if (!common) break;
  }
  if (!common) return lines;
  return lines.map((l) => (l.startsWith(common) ? l.slice(common.length) : l.trim() === "" ? "" : l));
}

function vscodeLink(relPath, line) {
  const abs = `${HOST_ROOT}/${relPath}`;
  return `vscode://file${encodeURI(abs)}:${line}`;
}

// renderSnippet("packages/ai/src/types.ts", "453-465", "caption")
export function renderSnippet(relPath, range, caption = "") {
  const [startStr, endStr] = String(range).split("-");
  const start = parseInt(startStr, 10);
  const end = parseInt(endStr ?? startStr, 10);
  const full = readFileSync(`${READ_ROOT}/${relPath}`, "utf8").split("\n");
  const slice = dedent(full.slice(start - 1, end)).join("\n");

  const lang = langFor(relPath);
  let highlighted;
  try {
    highlighted = hljs.highlight(slice, { language: lang, ignoreIllegals: true }).value;
  } catch {
    highlighted = slice.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }
  const rows = splitHighlighted(highlighted)
    .map((l) => `<span class="cl">${l.length ? l : "&nbsp;"}</span>`)
    .join("");

  const rangeLabel = end > start ? `${start}–${end}` : `${start}`;
  const link = vscodeLink(relPath, start);
  const cap = caption ? `<span class="snip-cap">${caption}</span>` : "";

  return `<figure class="snippet">
  <figcaption class="snip-head">
    <a class="snip-loc" href="${link}" title="Open this file at line ${start} in VS Code">
      <svg class="snip-ic" viewBox="0 0 24 24" aria-hidden="true"><path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/></svg>
      <span class="snip-path">${relPath}</span><span class="snip-lines">:${rangeLabel}</span>
    </a>
    ${cap}
    <button class="snip-cmt" data-comment-block title="Comment on this whole block, or highlight lines to comment on a narrower span"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M21 11.5a8.4 8.4 0 0 1-8.5 8.4 8.8 8.8 0 0 1-4-.9L3 20l1-3.9a8.4 8.4 0 1 1 17-4.6z"/></svg>Comment</button>
  </figcaption>
  <div class="snip-body"><pre class="code lang-${lang}" style="counter-reset: ln ${start - 1};"><code>${rows}</code></pre></div>
</figure>`;
}
