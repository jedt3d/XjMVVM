// viewer.js — responsive pan/zoom for every inline-SVG diagram on the page.
// Each diagram is a .diagram figure containing a .stage > .canvas > svg and a .toolbar.
(function () {
  function initDiagram(fig) {
    const stage = fig.querySelector(".stage");
    const canvas = fig.querySelector(".canvas");
    const svg = canvas && canvas.querySelector("svg");
    const zoomLabel = fig.querySelector("[data-role=zoomlabel]");
    if (!stage || !svg) return;
    let scale = 1, tx = 0, ty = 0;
    const MIN = 0.15, MAX = 8;

    function natural() {
      const vb = svg.getAttribute("viewBox");
      if (vb) { const p = vb.split(/[ ,]+/).map(Number); return { w: p[2], h: p[3] }; }
      const r = svg.getBoundingClientRect(); return { w: r.width, h: r.height };
    }
    function apply() {
      canvas.style.transform = "translate(" + tx + "px," + ty + "px) scale(" + scale + ")";
      if (zoomLabel) zoomLabel.textContent = Math.round(scale * 100) + "%";
    }
    function fit() {
      const n = natural(), r = stage.getBoundingClientRect(), pad = 24;
      scale = Math.max(MIN, Math.min(MAX, Math.min((r.width - pad) / n.w, (r.height - pad) / n.h)));
      tx = (r.width - n.w * scale) / 2; ty = (r.height - n.h * scale) / 2; apply();
    }
    function reset() {
      const n = natural(), r = stage.getBoundingClientRect();
      scale = 1; tx = (r.width - n.w) / 2; ty = (r.height - n.h) / 2; apply();
    }
    function sizeSvg() { const n = natural(); svg.setAttribute("width", n.w); svg.setAttribute("height", n.h); }
    function zoomAt(px, py, f) {
      const ns = Math.max(MIN, Math.min(MAX, scale * f)), k = ns / scale;
      tx = px - (px - tx) * k; ty = py - (py - ty) * k; scale = ns; apply();
    }
    stage.addEventListener("wheel", function (e) {
      e.preventDefault(); const r = stage.getBoundingClientRect();
      zoomAt(e.clientX - r.left, e.clientY - r.top, e.deltaY < 0 ? 1.12 : 1 / 1.12);
    }, { passive: false });
    let dragging = false, lx = 0, ly = 0;
    stage.addEventListener("pointerdown", function (e) { dragging = true; lx = e.clientX; ly = e.clientY; stage.classList.add("grabbing"); stage.setPointerCapture(e.pointerId); });
    stage.addEventListener("pointermove", function (e) { if (!dragging) return; tx += e.clientX - lx; ty += e.clientY - ly; lx = e.clientX; ly = e.clientY; apply(); });
    stage.addEventListener("pointerup", function () { dragging = false; stage.classList.remove("grabbing"); });
    stage.addEventListener("pointercancel", function () { dragging = false; stage.classList.remove("grabbing"); });
    fig.querySelectorAll("button.tool").forEach(function (b) {
      b.addEventListener("click", function () {
        const r = stage.getBoundingClientRect(), a = b.dataset.act;
        if (a === "zoomin") zoomAt(r.width / 2, r.height / 2, 1.25);
        else if (a === "zoomout") zoomAt(r.width / 2, r.height / 2, 1 / 1.25);
        else if (a === "fit") fit();
        else if (a === "reset") reset();
      });
    });
    let rt; window.addEventListener("resize", function () { clearTimeout(rt); rt = setTimeout(fit, 150); });
    sizeSvg(); fit();
  }
  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".diagram").forEach(initDiagram);
  });
})();
