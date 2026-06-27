/* Interactive widgets for the lesson kit. Generic, vanilla, no framework.
   Currently ships one widget: a step-through ("stepper"). Each widget is
   reduced-motion-safe and theme-aware (DOM widgets get the theme for free via
   CSS; canvas/SVG widgets should read tokens via getComputedStyle — see note).

   Stepper markup:
     <figure class="viz" data-viz="stepper" aria-label="...">
       <div class="viz-cap">caption</div>
       <div class="viz-stage">
         <div class="viz-step" data-note="explanation (may be HTML)">step content</div>
         <div class="viz-step" data-note="...">...</div>
       </div>
       <div class="viz-controls"></div>          <!-- controls are built here -->
       <div class="viz-note" aria-live="polite"></div>
     </figure>
   The stage reveals steps cumulatively: prior = .done, current = .active, later = .pending. */
(function () {
  "use strict";
  var reduce = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  function el(tag, attrs, text) {
    var n = document.createElement(tag);
    if (attrs) for (var k in attrs) if (attrs[k] != null) n.setAttribute(k, attrs[k]);
    if (text != null) n.textContent = text;
    return n;
  }

  function stepper(fig) {
    var steps = Array.prototype.slice.call(fig.querySelectorAll(".viz-step"));
    if (!steps.length) return;
    var note = fig.querySelector(".viz-note");
    var controls = fig.querySelector(".viz-controls") || fig.appendChild(el("div", { class: "viz-controls" }));
    var i = 0, timer = null;

    var prev  = el("button", { type: "button", "aria-label": "Previous step" }, "‹");
    var count = el("span", { class: "count" });
    var next  = el("button", { type: "button", "aria-label": "Next step" }, "›");
    var spacer = el("span", { class: "spacer" });
    var play  = el("button", { type: "button", class: "primary", "aria-label": "Play" }, "▶ Play");
    var reset = el("button", { type: "button", "aria-label": "Reset" }, "⟲");
    [prev, count, next, spacer].forEach(function (n) { controls.appendChild(n); });
    if (!reduce) controls.appendChild(play);          // no autoplay affordance under reduced-motion
    controls.appendChild(reset);

    function render() {
      steps.forEach(function (s, idx) {
        s.classList.toggle("active", idx === i);
        s.classList.toggle("done", idx < i);
        s.classList.toggle("pending", idx > i);
      });
      count.textContent = (i + 1) + " / " + steps.length;
      if (note) note.innerHTML = steps[i].getAttribute("data-note") || "";
      prev.disabled = i === 0;
      next.disabled = i === steps.length - 1;
    }
    function go(n) { i = Math.max(0, Math.min(steps.length - 1, n)); render(); }
    function stop() { if (timer) { clearInterval(timer); timer = null; play.textContent = "▶ Play"; play.classList.add("primary"); } }
    function playPause() {
      if (timer) { stop(); return; }
      if (i === steps.length - 1) go(0);
      play.textContent = "⏸ Pause"; play.classList.remove("primary");
      timer = setInterval(function () { if (i >= steps.length - 1) { stop(); return; } go(i + 1); }, 1100);
    }
    prev.addEventListener("click", function () { stop(); go(i - 1); });
    next.addEventListener("click", function () { stop(); go(i + 1); });
    reset.addEventListener("click", function () { stop(); go(0); });
    play.addEventListener("click", playPause);
    fig.addEventListener("keydown", function (e) {
      if (e.key === "ArrowRight") { stop(); go(i + 1); }
      else if (e.key === "ArrowLeft") { stop(); go(i - 1); }
    });
    render();
  }

  function boot() {
    document.querySelectorAll('figure.viz[data-viz="stepper"]').forEach(stepper);
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot);
  else boot();

  /* Building a canvas/SVG widget? Read the design tokens so it matches the theme and re-themes for
     free, and honor reduced-motion:
       var css = getComputedStyle(document.documentElement);
       var accent = css.getPropertyValue('--accent').trim();   // also --ok, --bad, --ink, --bg ...
       if (reduce) { drawFinalState(); } else { animate(); }
     Mount by a distinct data-viz name and give it keyboard-operable controls + a static fallback. */
})();
