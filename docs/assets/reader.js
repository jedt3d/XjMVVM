// reader.js — inline commenting with per-highlight marks + threaded replies.
// Active only when served by tools/serve.mjs (via /api/ping).
// • Highlight text → floating menu → comment. The exact span stays marked, colored by state:
//   green = your open comment (awaiting Claude), yellow = Claude replied (your turn), gray = resolved.
// • Click a highlight → only that thread. Click the gutter number → all threads in the block.
(function () {
  const SLUG = document.body.dataset.slug;
  const IS_CONTENTS_PAGE = document.body.classList.contains("contents");
  if (!SLUG && !IS_CONTENTS_PAGE) return;
  const SEL = ".prose > p, .prose > h2, .prose > h3, .prose > blockquote, .prose > ul, .prose > ol, .prose > figure, .prose > .note";
  const prose = document.querySelector(".prose");
  const isFigure = (b) => b.tagName === "FIGURE";
  const isDiagram = (b) => b.classList.contains("diagram");
  const isSnippet = (b) => b.classList.contains("snippet");
  const blockLabel = (b) => {
    if (isDiagram(b)) { const c = b.querySelector(".figcap"); return c ? "ไดอะแกรม: " + c.textContent.trim().slice(0, 60) : "ไดอะแกรม"; }
    if (isSnippet(b)) { const p = b.querySelector(".snip-path"); return p ? "โค้ด: " + p.textContent.trim() : "โค้ด"; }
    return b.textContent.trim().slice(0, 60);
  };
  const api = (p, o) => fetch("/api/" + p, o).then((r) => r.json());
  const esc = (s) => (s || "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  const fmt = (iso) => { try { return new Date(iso).toLocaleString("th-TH", { dateStyle: "medium", timeStyle: "short" }); } catch { return ""; } };

  let blocks = [], markers = [], byAnchor = {}, activeCard = null, activeAnchor = null, pop = null;

  function anchorBlocks() {
    blocks = Array.from(document.querySelectorAll(SEL)).filter((b) => !b.closest(".ccard"));
    blocks.forEach((b, i) => { b.dataset.anchor = SLUG + ":" + i; });
  }
  function group(comments) { byAnchor = {}; comments.forEach((c) => (byAnchor[c.anchor] = byAnchor[c.anchor] || []).push(c)); }
  const roots = (anchor) => (byAnchor[anchor] || []).filter((c) => !c.parentId).sort((a, b) => a.createdAt.localeCompare(b.createdAt));
  const subtree = (anchor, rootId) => {
    const all = byAnchor[anchor] || []; const ids = new Set([rootId]); let grew = true;
    while (grew) { grew = false; for (const c of all) if (c.parentId && ids.has(c.parentId) && !ids.has(c.id)) { ids.add(c.id); grew = true; } }
    return all.filter((c) => ids.has(c.id));
  };
  function stateOf(list) {
    const open = list.filter((c) => c.status !== "resolved");
    if (open.length === 0) return "gray";
    if (open.some((c) => c.author === "claude")) return "yellow";
    return "green";
  }
  // A highlight's state follows its ROOT: resolved root = gray (done); open root with an open Claude
  // reply = yellow (your turn); open root otherwise = green (awaiting Claude).
  function stateOfRoot(anchor, root) {
    if (root.status === "resolved") return "gray";
    const rep = subtree(anchor, root.id).filter((c) => c.id !== root.id && c.status !== "resolved");
    return rep.some((c) => c.author === "claude") ? "yellow" : "green";
  }
  function aggState(rootList, anchor) {
    const s = rootList.map((r) => stateOfRoot(anchor, r));
    return s.includes("green") ? "green" : s.includes("yellow") ? "yellow" : "gray";
  }

  // ---------- gutter badges ----------
  function buildMarkers() {
    markers.forEach((m) => m.remove()); markers = [];
    blocks.forEach((b) => {
      if (isFigure(b)) return; // figures use their own toolbar Comment button, not a gutter badge
      const list = byAnchor[b.dataset.anchor] || [];
      b.classList.toggle("blk-commented", list.length > 0);
      if (!list.length) return;
      const rs = roots(b.dataset.anchor);
      const st = aggState(rs, b.dataset.anchor);
      const resolved = rs.filter((r) => stateOfRoot(b.dataset.anchor, r) === "gray").length;
      const mk = document.createElement("button");
      mk.className = "cmk s-" + st; mk.type = "button"; mk.textContent = resolved + "/" + rs.length;
      mk.title = "ดูคอมเมนต์ทั้งหมดในย่อหน้านี้ (แก้แล้ว " + resolved + " จาก " + rs.length + " ไฮไลต์)";
      mk.addEventListener("click", (e) => { e.stopPropagation(); openAll(b); });
      prose.appendChild(mk); markers.push(mk); mk._block = b;
    });
    position();
  }
  function position() { markers.forEach((mk) => { mk.style.top = mk._block.offsetTop + "px"; }); }

  // ---------- persistent highlight marks ----------
  function clearHighlights(b) { b.querySelectorAll("mark.hl").forEach((m) => { m.replaceWith(document.createTextNode(m.textContent)); }); b.normalize(); }
  function offsetToRangeWrap(b, start, end, cls, hid) {
    const nodes = []; const w = document.createTreeWalker(b, NodeFilter.SHOW_TEXT, null);
    let n; while ((n = w.nextNode())) nodes.push(n);
    let idx = 0;
    for (const node of nodes) {
      const len = node.nodeValue.length, ns = idx, ne = idx + len; idx = ne;
      if (ne <= start || ns >= end) continue;
      if (node.parentElement.closest("mark.hl")) continue; // avoid overlap tangle
      const s = Math.max(0, start - ns), e = Math.min(len, end - ns);
      const r = document.createRange(); r.setStart(node, s); r.setEnd(node, e);
      const mk = document.createElement("mark"); mk.className = "hl " + cls; mk.dataset.hid = hid;
      try { r.surroundContents(mk); } catch (_) {}
    }
  }
  // Self-healing locator: whole-block comments never mark; otherwise use offsets ONLY if they still
  // point at the stored quote, else re-find the quote text. Stable across content edits / truncation.
  function locate(b, c) {
    if (c.scope === "block") return null;
    const text = b.textContent;
    if (Number.isInteger(c.start) && Number.isInteger(c.end) && c.start >= 0 && c.end > c.start && c.end <= text.length) {
      if (!c.quote || text.slice(c.start, c.end) === c.quote) return [c.start, c.end];
    }
    if (c.quote) { const i = text.indexOf(c.quote); if (i >= 0) return [i, i + c.quote.length]; }
    return null;
  }
  function highlightAll() {
    blocks.forEach((b) => {
      if (isDiagram(b)) return; // diagrams aren't text-highlighted
      clearHighlights(b);
      roots(b.dataset.anchor).forEach((c) => {
        const loc = locate(b, c); if (!loc) return;
        offsetToRangeWrap(b, loc[0], loc[1], "s-" + stateOfRoot(b.dataset.anchor, c), c.id);
      });
      b.querySelectorAll("mark.hl").forEach((m) => m.addEventListener("click", (e) => {
        e.stopPropagation(); openThread(b, m.dataset.hid);
      }));
    });
    position();
  }
  function rerender() { buildMarkers(); highlightAll(); refreshBlockButtons(); renderNodeStates(); }

  function blockOfNode(node) { let el = node && node.nodeType === 3 ? node.parentElement : node; while (el && el.parentElement !== prose) el = el.parentElement; return el && el.dataset && el.dataset.anchor !== undefined ? el : null; }
  function offsetsFor(b, range) { const pre = document.createRange(); pre.selectNodeContents(b); pre.setEnd(range.startContainer, range.startOffset); const start = pre.toString().length; return { start, end: start + range.toString().length }; }

  // ---------- floating selection menu ----------
  function makePopover() {
    pop = document.createElement("div"); pop.className = "selpop";
    pop.innerHTML = `<button data-a="comment" title="เพิ่มคอมเมนต์"><svg viewBox="0 0 24 24"><path d="M21 11.5a8.4 8.4 0 0 1-8.5 8.4 8.8 8.8 0 0 1-4-.9L3 20l1-3.9a8.4 8.4 0 1 1 17-4.6z"/></svg>คอมเมนต์</button><div class="arrow"></div>`;
    document.body.appendChild(pop);
    const btn = pop.querySelector("[data-a=comment]");
    btn.addEventListener("mousedown", (e) => e.preventDefault());
    btn.addEventListener("click", () => {
      const sel = window.getSelection(); if (!sel || sel.isCollapsed) return;
      const range = sel.getRangeAt(0); const block = blockOfNode(range.commonAncestorContainer);
      if (!block) { hidePop(); return; }
      const quote = sel.toString().trim(); const off = offsetsFor(block, range);
      hidePop(); sel.removeAllRanges(); openNew(block, quote, off);
    });
  }
  function showPopForSelection() {
    const sel = window.getSelection();
    if (!sel || sel.isCollapsed || !sel.toString().trim()) return hidePop();
    const node = sel.getRangeAt(0).commonAncestorContainer;
    const host = node.nodeType === 3 ? node.parentElement : node;
    const blk = blockOfNode(node);
    if (!host || !host.closest(".prose") || host.closest(".ccard") || !blk || isDiagram(blk)) return hidePop();
    const rect = sel.getRangeAt(0).getBoundingClientRect(); if (!rect || (!rect.width && !rect.height)) return hidePop();
    pop.classList.add("show");
    const pw = pop.offsetWidth, ph = pop.offsetHeight;
    let left = Math.max(8, Math.min(rect.right - pw, window.innerWidth - pw - 8));
    let top = rect.top - ph - 8, below = false; if (top < 8) { top = rect.bottom + 8; below = true; }
    pop.style.left = left + "px"; pop.style.top = top + "px"; pop.classList.toggle("below", below);
    pop.querySelector(".arrow").style.right = Math.max(10, Math.min(pw - 20, rect.right - left - 14)) + "px";
  }
  function hidePop() { if (pop) pop.classList.remove("show"); }

  // ---------- cards ----------
  async function postComment(anchor, quote, body, parentId, off, scope, node) {
    const payload = { chapter: SLUG, anchor, quote, body, parentId: parentId || null };
    if (off) { payload.start = off.start; payload.end = off.end; }
    if (scope) payload.scope = scope;
    if (node) payload.node = node;
    const c = await api("comments", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(payload) });
    (byAnchor[anchor] = byAnchor[anchor] || []).push(c); return c;
  }
  function shell(block, title, quote) {
    closeCard(); activeAnchor = block.dataset.anchor;
    const card = document.createElement("div"); card.className = "ccard";
    card.innerHTML = `<div class="chead">💬 ${title} <button class="x" title="ปิด">✕</button></div>` +
      (quote ? `<div class="quote">“${esc(quote.slice(0, 160))}${quote.length > 160 ? "…" : ""}”</div>` : "") +
      `<div class="thread"></div>`;
    block.insertAdjacentElement("afterend", card); activeCard = card;
    card.querySelector(".x").addEventListener("click", closeCard);
    return card;
  }
  function addComposer(card, place, onSave) {
    const c = document.createElement("div"); c.className = "compose";
    c.innerHTML = `<textarea placeholder="${place}"></textarea><div class="row"><span class="hint">Ctrl/⌘ + Enter</span><button class="save">บันทึก</button></div>`;
    card.appendChild(c);
    const ta = c.querySelector("textarea");
    const go = async () => { const v = ta.value.trim(); if (!v) return; await onSave(v); ta.value = ""; };
    c.querySelector(".save").addEventListener("click", go);
    ta.addEventListener("keydown", (e) => { if ((e.metaKey || e.ctrlKey) && e.key === "Enter") go(); });
    setTimeout(() => ta.focus(), 0);
  }
  function openNew(block, quote, off) {
    const anchor = block.dataset.anchor;
    const card = shell(block, "คอมเมนต์ใหม่", quote);
    addComposer(card, "พิมพ์คอมเมนต์ของคุณ… (บันทึกอัตโนมัติ)", async (v) => {
      await postComment(anchor, quote, v, null, off); rerender(); openThread(block, byAnchor[anchor][byAnchor[anchor].length - 1].id);
    });
  }
  function openThread(block, rootId) {
    const anchor = block.dataset.anchor;
    const root = (byAnchor[anchor] || []).find((c) => c.id === rootId); if (!root) return;
    if (activeCard && activeAnchor === anchor && activeCard.dataset.root === rootId) return closeCard();
    const card = shell(block, "คอมเมนต์", root.quote); card.dataset.root = rootId;
    const thread = card.querySelector(".thread");
    const list = subtree(anchor, rootId).sort((a, b) => a.createdAt.localeCompare(b.createdAt));
    const byParent = {}; list.forEach((c) => (byParent[c.parentId || "root"] = byParent[c.parentId || "root"] || []).push(c));
    (function walk(id, d) { const c = list.find((x) => x.id === id); if (c) thread.appendChild(renderComment(c, anchor, block, d)); (byParent[id] || []).forEach((k) => walk(k.id, d + 1)); })(rootId, 0);
    addComposer(card, "ตอบกลับในหัวข้อนี้…", async (v) => { await postComment(anchor, root.quote, v, rootId, null); rerender(); openThread(block, rootId); });
  }
  function openAll(block) {
    const anchor = block.dataset.anchor;
    if (activeCard && activeAnchor === anchor && activeCard.dataset.all === "1") return closeCard();
    const card = shell(block, "ทุกคอมเมนต์ในย่อหน้านี้", ""); card.dataset.all = "1";
    const thread = card.querySelector(".thread");
    const list = byAnchor[anchor] || [];
    const byParent = {}; list.forEach((c) => (byParent[c.parentId || "root"] = byParent[c.parentId || "root"] || []).push(c));
    roots(anchor).forEach((r) => {
      const sep = document.createElement("div"); sep.className = "thread-quote"; sep.textContent = "“" + (r.quote || "").slice(0, 90) + "”"; thread.appendChild(sep);
      (function walk(id, d) { const c = list.find((x) => x.id === id); if (c) thread.appendChild(renderComment(c, anchor, block, d)); (byParent[id] || []).forEach((k) => walk(k.id, d + 1)); })(r.id, 0);
    });
    addComposer(card, isFigure(block) ? "คอมเมนต์ทั้งบล็อกนี้…" : "คอมเมนต์ทั้งย่อหน้านี้…", async (v) => { await postComment(anchor, blockLabel(block), v, null, null, "block"); rerender(); openAll(block); });
  }
  function setupBlockButtons() {
    document.querySelectorAll("[data-comment-block]").forEach((btn) => {
      const fig = btn.closest("figure"); if (!fig) return;
      btn.addEventListener("click", (e) => { e.stopPropagation(); openAll(fig); });
    });
  }
  function refreshBlockButtons() {
    document.querySelectorAll("[data-comment-block]").forEach((btn) => {
      const fig = btn.closest("figure"); if (!fig) return;
      const rs = roots(fig.dataset.anchor), n = rs.length;
      const resolved = rs.filter((r) => stateOfRoot(fig.dataset.anchor, r) === "gray").length;
      btn.classList.toggle("has", n > 0);
      let cnt = btn.querySelector(".cnt"); if (cnt) cnt.remove();
      if (n > 0) { const s = document.createElement("span"); s.className = "cnt"; s.textContent = " " + resolved + "/" + n; btn.appendChild(s); }
    });
  }
  function closeCard() { if (activeCard) { activeCard.remove(); activeCard = null; activeAnchor = null; position(); } }

  function renderComment(c, anchor, block, depth) {
    const el = document.createElement("div");
    el.className = "cmt" + (depth ? " reply" : "") + (c.status === "resolved" ? " resolved" : "") + (c.author === "claude" ? " claude" : "");
    if (depth) el.style.marginLeft = Math.min(depth, 5) * 22 + "px";
    const who = c.author === "claude" ? "Claude" : "คุณ";
    el.innerHTML = `<div class="meta">` + (depth ? `<span class="rarrow">↳</span>` : "") +
      `<span class="who ${c.author}">${who}</span><span>${fmt(c.createdAt)}</span><span class="acts">` +
      (c.author === "claude" ? `<button data-a="up" class="fb${c.feedback === "up" ? " on-up" : ""}" title="ตอบนี้ดี">👍</button><button data-a="down" class="fb${c.feedback === "down" ? " on-down" : ""}" title="ตอบนี้ยังไม่ดี">👎</button>` : "") +
      `<button data-a="reply">ตอบกลับ</button><button data-a="resolve">${c.status === "resolved" ? "เปิดใหม่" : "ทำเสร็จ"}</button>` +
      (c.author === "reader" ? `<button data-a="edit">แก้ไข</button><button data-a="del">ลบ</button>` : "") +
      `</span></div><div class="txt">${esc(c.body)}</div>`;
    const up = el.querySelector("[data-a=up]"), down = el.querySelector("[data-a=down]");
    if (up || down) { const set = async (v) => { const nv = c.feedback === v ? null : v; const u = await api("comments/" + c.id, { method: "PATCH", headers: { "content-type": "application/json" }, body: JSON.stringify({ feedback: nv }) }); c.feedback = u.feedback; up.classList.toggle("on-up", c.feedback === "up"); down.classList.toggle("on-down", c.feedback === "down"); }; up.addEventListener("click", () => set("up")); down.addEventListener("click", () => set("down")); }
    el.querySelector("[data-a=reply]").addEventListener("click", () => {
      if (el.querySelector(".replybox")) return;
      const box = document.createElement("div"); box.className = "replybox";
      box.innerHTML = `<textarea placeholder="ตอบกลับ @${who}…"></textarea><div class="row"><button class="save">ตอบกลับ</button></div>`;
      el.appendChild(box); const rta = box.querySelector("textarea"); rta.focus();
      const send = async () => { const v = rta.value.trim(); if (!v) return; await postComment(anchor, c.quote, v, c.id, null); rerender(); reopen(block, anchor); };
      box.querySelector(".save").addEventListener("click", send);
      rta.addEventListener("keydown", (e) => { if ((e.metaKey || e.ctrlKey) && e.key === "Enter") send(); });
    });
    el.querySelector("[data-a=resolve]").addEventListener("click", async () => { await api("comments/" + c.id, { method: "PATCH", headers: { "content-type": "application/json" }, body: JSON.stringify({ status: c.status === "resolved" ? "open" : "resolved" }) }); c.status = c.status === "resolved" ? "open" : "resolved"; rerender(); reopen(block, anchor); });
    const eb = el.querySelector("[data-a=edit]");
    if (eb) eb.addEventListener("click", () => { const txt = el.querySelector(".txt"); const ta = document.createElement("textarea"); ta.value = c.body; ta.className = "editta"; txt.replaceWith(ta); ta.focus(); ta.addEventListener("blur", async () => { const u = await api("comments/" + c.id, { method: "PATCH", headers: { "content-type": "application/json" }, body: JSON.stringify({ body: ta.value }) }); c.body = u.body; const d = document.createElement("div"); d.className = "txt"; d.textContent = c.body; ta.replaceWith(d); }); });
    const db = el.querySelector("[data-a=del]");
    if (db) db.addEventListener("click", async () => { if (!confirm("ลบคอมเมนต์นี้?")) return; await api("comments/" + c.id, { method: "DELETE" }); byAnchor[anchor] = (byAnchor[anchor] || []).filter((x) => x.id !== c.id); rerender(); reopen(block, anchor); });
    return el;
  }
  function reopen(block, anchor) { // re-open whichever card mode was active
    const card = activeCard; if (!card) return;
    if (card.dataset.all) return openAll(block);
    if (card.dataset.node) { const g = findNode(block, card.dataset.node); return g ? openDiagramNode(block, g) : closeCard(); }
    if (card.dataset.root && byAnchor[anchor].some((c) => c.id === card.dataset.root)) return openThread(block, card.dataset.root);
    closeCard();
  }

  // ---------- diagram per-node commenting ----------
  const nodeIdOf = (g) => { const t = g.querySelector("title"); return t ? t.textContent.trim() : ""; };
  const nodeLabelOf = (g) => { const t = g.querySelector("text"); return (t ? t.textContent : nodeIdOf(g)).trim(); };
  const findNode = (fig, nid) => Array.from(fig.querySelectorAll("g.node")).find((g) => nodeIdOf(g) === nid) || null;
  function setupDiagrams() {
    document.querySelectorAll(".diagram").forEach((fig) => {
      const stage = fig.querySelector(".stage"); if (!stage || stage._nodesWired) return; stage._nodesWired = true;
      let d = null, moved = false;
      stage.addEventListener("pointerdown", (e) => { d = { x: e.clientX, y: e.clientY }; moved = false; });
      stage.addEventListener("pointermove", (e) => { if (d && Math.hypot(e.clientX - d.x, e.clientY - d.y) > 5) moved = true; });
      stage.addEventListener("pointerup", (e) => {
        if (d && !moved) { const el = document.elementFromPoint(e.clientX, e.clientY); const g = el && el.closest("g.node"); if (g) openDiagramNode(fig, g); }
        d = null;
      });
    });
  }
  function renderNodeStates() {
    document.querySelectorAll(".diagram").forEach((fig) => {
      const anchor = fig.dataset.anchor;
      fig.querySelectorAll("g.node").forEach((g) => g.classList.remove("nc-green", "nc-yellow", "nc-gray"));
      const groups = {};
      (byAnchor[anchor] || []).filter((c) => !c.parentId && c.node).forEach((c) => (groups[c.node] = groups[c.node] || []).push(c));
      Object.keys(groups).forEach((nid) => {
        const g = findNode(fig, nid); if (!g) return;
        g.classList.add("nc-" + aggState(groups[nid], anchor));
      });
    });
  }
  function openDiagramNode(fig, g) {
    const nid = nodeIdOf(g), label = nodeLabelOf(g), anchor = fig.dataset.anchor;
    if (activeCard && activeAnchor === anchor && activeCard.dataset.node === nid) return closeCard();
    const card = shell(fig, "บล็อก: " + label, label); card.dataset.node = nid;
    const thread = card.querySelector(".thread");
    const list = byAnchor[anchor] || [];
    const byParent = {}; list.forEach((c) => (byParent[c.parentId || "root"] = byParent[c.parentId || "root"] || []).push(c));
    list.filter((c) => !c.parentId && c.node === nid).sort((a, b) => a.createdAt.localeCompare(b.createdAt))
      .forEach((r) => (function walk(id, dep) { const c = list.find((x) => x.id === id); if (c) thread.appendChild(renderComment(c, anchor, fig, dep)); (byParent[id] || []).forEach((k) => walk(k.id, dep + 1)); })(r.id, 0));
    addComposer(card, "คอมเมนต์บล็อก “" + label + "” นี้…", async (v) => { await postComment(anchor, label, v, null, null, "node", nid); rerender(); openDiagramNode(fig, findNode(fig, nid) || g); });
  }

  function isContentsPage() {
    return IS_CONTENTS_PAGE;
  }

  function showReadOnlyHint() {
    if (!isContentsPage()) return;
    const h = document.createElement("div");
    h.className = "reader-off";
    h.innerHTML = 'โหมดอ่านอย่างเดียว — รัน <code>npm run read</code> เพื่อคอมเมนต์';
    document.body.appendChild(h);
    setTimeout(() => h.remove(), 6000);
  }

  async function init() {
    let ok = false; try { ok = (await api("ping")).ok; } catch { ok = false; }
    if (!ok) { showReadOnlyHint(); return; }
    if (!SLUG) return;
    document.body.classList.add("reader");
    anchorBlocks();
    const { comments } = await api("comments?chapter=" + encodeURIComponent(SLUG));
    group(comments); buildMarkers(); highlightAll(); makePopover(); setupBlockButtons(); refreshBlockButtons(); setupDiagrams(); renderNodeStates();
    document.addEventListener("selectionchange", () => { clearTimeout(window._selT); window._selT = setTimeout(showPopForSelection, 60); });
    document.addEventListener("mouseup", () => setTimeout(showPopForSelection, 10));
    document.addEventListener("scroll", hidePop, true);
    document.addEventListener("mousedown", (e) => { if (pop && !pop.contains(e.target)) hidePop(); });
    let rt; window.addEventListener("resize", () => { clearTimeout(rt); rt = setTimeout(position, 120); });
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(position);
    const tip = document.createElement("div"); tip.className = "reader-off"; tip.style.background = "#1481b8"; tip.textContent = "ไฮไลต์ข้อความเพื่อคอมเมนต์ · คลิกไฮไลต์เพื่อดูเฉพาะหัวข้อนั้น ✍️"; document.body.appendChild(tip); setTimeout(() => tip.remove(), 5000);
  }
  document.addEventListener("DOMContentLoaded", init);
})();
