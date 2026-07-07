import hljs from "highlight.js";
import xojo from "./xojo.highlight.mjs";

hljs.registerLanguage("xojo", xojo);

const LANG_BY_EXT = {
  ts: "typescript",
  tsx: "typescript",
  js: "javascript",
  mjs: "javascript",
  json: "json",
  md: "markdown",
  sh: "bash",
  bash: "bash",
  zsh: "bash",
  dot: "dot",
  css: "css",
  html: "xml",
  xojo_code: "xojo",
  xojo_project: "xojo",
  xojo_window: "xojo",
  xojo_webpage: "xojo",
  xojo_screen: "xojo",
  xojo_menu: "xojo",
  xojo_toolbar: "xojo",
  xojo_script: "xojo",
};

const LANG_ALIASES = {
  xojo_code: "xojo",
  xojo_project: "xojo",
  xojo_window: "xojo",
  xojo_webpage: "xojo",
  xojo_screen: "xojo",
  xojo_menu: "xojo",
  xojo_toolbar: "xojo",
  xojo_script: "xojo",
  js: "javascript",
  mjs: "javascript",
  shell: "bash",
  zsh: "bash",
  html: "xml",
};

export function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

export function langForPath(path) {
  const ext = path.split(".").pop().toLowerCase();
  return LANG_BY_EXT[ext] || "plaintext";
}

export function normalizeLanguage(lang) {
  const key = String(lang || "").trim().toLowerCase().split(/\s+/)[0];
  if (!key) return "plaintext";
  return LANG_ALIASES[key] || key;
}

export function highlightCode(code, lang) {
  const language = normalizeLanguage(lang);
  try {
    return {
      html: hljs.highlight(String(code), { language, ignoreIllegals: true }).value,
      language,
    };
  } catch {
    return {
      html: escapeHtml(code),
      language: "plaintext",
    };
  }
}
