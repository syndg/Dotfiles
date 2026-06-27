/* Builds the left rail, the on-this-page TOC (with scroll-spy), the progress
   bar / print button, and the index rows — all from window.LESSONS (manifest.js).
   Vanilla, no framework. Include after manifest.js. */
(function () {
  "use strict";
  var EDD = window.LESSONS || { brand: {}, lessons: [], reference: [] };

  // ---- tiny DOM helpers (textContent keeps "&" etc. safe) ----
  function el(tag, attrs, text) {
    var n = document.createElement(tag);
    if (attrs) for (var k in attrs) if (attrs[k] != null) n.setAttribute(k, attrs[k]);
    if (text != null) n.textContent = text;
    return n;
  }
  function basename(p) { return p.split("/").pop(); }
  var here = basename(location.pathname);

  function navLink(item, root) {
    var a = el("a", { class: "navlink", href: root + item.file });
    if (basename(item.file) === here) a.setAttribute("aria-current", "page");
    a.appendChild(el("span", { class: "ix" }, item.id));
    a.appendChild(document.createTextNode(" " + item.title));
    return a;
  }
  function navGroup(label, items, root) {
    var nav = el("nav", { "aria-label": label });
    nav.appendChild(el("p", { class: "grouplabel" }, label));
    items.forEach(function (it) { nav.appendChild(navLink(it, root)); });
    return nav;
  }

  // ---- left rail (lesson + reference pages) ----
  function buildRail(rail) {
    var root = rail.getAttribute("data-root") || "";
    var kind = rail.getAttribute("data-kind") || "lesson";

    var brand = el("a", { class: "brand", href: root + (EDD.brand.home || "index.html") });
    brand.appendChild(el("b", null, EDD.brand.title || ""));
    brand.appendChild(el("span", null, EDD.brand.sub || ""));
    rail.appendChild(brand);

    // the page list (Lessons + Reference) is the only part that scrolls; the
    // TOC and progress below stay pinned. See `.railnav` in the stylesheet.
    var scroll = el("div", { class: "railnav" });
    if (EDD.lessons && EDD.lessons.length) scroll.appendChild(navGroup("Lessons", EDD.lessons, root));
    if (EDD.reference && EDD.reference.length) scroll.appendChild(navGroup("Reference", EDD.reference, root));
    rail.appendChild(scroll);

    rail.appendChild(el("hr"));

    // on-this-page TOC, derived from the page's <section id> elements
    var sections = document.querySelectorAll("main section[id]");
    var tocLinks = [];
    if (sections.length) {
      var toc = el("nav", { class: "toc", "aria-label": "On this page" });
      toc.appendChild(el("p", { class: "grouplabel" }, "On this page"));
      sections.forEach(function (s, i) {
        var h = s.querySelector(".h2 h2");
        var label = s.getAttribute("data-toc") || (h ? h.textContent : s.id);
        var a = el("a", { href: "#" + s.id }, label);
        if (i === 0) a.className = "active";
        toc.appendChild(a);
        tocLinks.push(a);
      });
      rail.appendChild(toc);
    }

    // progress (lessons) or a print button (reference)
    if (kind === "reference") {
      var btn = el("button", { class: "printbtn", type: "button" }, "⎙ Print / PDF");
      btn.addEventListener("click", function () { window.print(); });
      rail.appendChild(btn);
    } else {
      var pos = 0, total = EDD.lessons.length;
      EDD.lessons.forEach(function (l, i) { if (basename(l.file) === here) pos = i + 1; });
      if (pos && total) {
        var wrap = el("div", { class: "progress" });
        var lbl = el("div", { class: "lbl" });
        lbl.appendChild(el("span", null, "Progress"));
        lbl.appendChild(el("span", null, pos + " / " + total));
        var bar = el("div", { class: "bar" });
        bar.appendChild(el("i", { style: "width:" + (pos / total * 100) + "%" }));
        wrap.appendChild(lbl); wrap.appendChild(bar);
        rail.appendChild(wrap);
      }
    }

    if (tocLinks.length) wireScrollSpy(sections, tocLinks);
  }

  // ---- scroll-spy ----
  function wireScrollSpy(sections, links) {
    var byId = {};
    links.forEach(function (a) { byId[a.getAttribute("href").slice(1)] = a; });
    var spy = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) {
          links.forEach(function (a) { a.classList.remove("active"); });
          var link = byId[e.target.id];
          if (link) link.classList.add("active");
        }
      });
    }, { rootMargin: "-12% 0px -78% 0px", threshold: 0 });
    sections.forEach(function (s) { spy.observe(s); });
  }

  // ---- mobile drawer (off-canvas rail + top bar + scrim), vanilla ----
  function buildDrawer(rail) {
    if (!rail.id) rail.id = "rail";
    var root = rail.getAttribute("data-root") || "";

    var bar = el("div", { class: "topbar" });
    var brand = el("a", { class: "brand", href: root + (EDD.brand.home || "index.html") });
    brand.appendChild(el("b", null, EDD.brand.title || ""));
    bar.appendChild(brand);
    var btn = el("button", {
      class: "navtoggle", type: "button",
      "aria-label": "Open navigation", "aria-expanded": "false", "aria-controls": rail.id
    });
    btn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>';
    bar.appendChild(btn);

    var scrim = el("div", { class: "scrim" });
    document.body.appendChild(bar);
    document.body.appendChild(scrim);

    var last = null;
    function isOpen() { return document.body.classList.contains("nav-open"); }
    function open() {
      last = document.activeElement;
      document.body.classList.add("nav-open");
      btn.setAttribute("aria-expanded", "true");
      var first = rail.querySelector("a,button");
      if (first) first.focus();
    }
    function close() {
      document.body.classList.remove("nav-open");
      btn.setAttribute("aria-expanded", "false");
      if (last && last.focus) last.focus();
    }
    btn.addEventListener("click", function () { isOpen() ? close() : open(); });
    scrim.addEventListener("click", close);
    rail.addEventListener("click", function (e) {
      var a = e.target.closest && e.target.closest("a.navlink, .toc a, a.brand");
      if (a) close();
    });
    document.addEventListener("keydown", function (e) {
      if (!isOpen()) return;
      if (e.key === "Escape") { close(); return; }
      if (e.key !== "Tab") return;
      var f = rail.querySelectorAll("a[href],button:not([disabled])");
      if (!f.length) return;
      var first = f[0], lastEl = f[f.length - 1];
      if (e.shiftKey && document.activeElement === first) { lastEl.focus(); e.preventDefault(); }
      else if (!e.shiftKey && document.activeElement === lastEl) { first.focus(); e.preventDefault(); }
    });
    window.addEventListener("resize", function () { if (window.innerWidth > 900) close(); });
  }

  // ---- index rows (landing page) ----
  function fillList(container) {
    var which = container.getAttribute("data-list"); // "lessons" | "reference"
    var root = container.getAttribute("data-root") || "";
    var items = EDD[which] || [];
    items.forEach(function (it) {
      var a = el("a", { class: "row" + (which === "reference" ? " ref" : ""), href: root + it.file });
      a.appendChild(el("span", { class: "rn" }, it.id));
      var body = el("span", { class: "rbody" });
      body.appendChild(el("b", null, it.title));
      var blurb = el("span"); blurb.innerHTML = it.blurb || ""; // authored, trusted HTML
      body.appendChild(blurb);
      a.appendChild(body);
      a.appendChild(el("span", { class: "rgo" }, "→"));
      container.appendChild(a);
    });
    var count = document.querySelector('[data-count="' + which + '"]');
    if (count) count.textContent = items.length + (which === "lessons" ? " · sequential" : "");
  }

  // ---- boot ----
  function boot() {
    var rail = document.querySelector("[data-rail]");
    if (rail) { buildRail(rail); buildDrawer(rail); }
    var lists = document.querySelectorAll("[data-list]");
    lists.forEach(function (c) { fillList(c); });
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot);
  else boot();
})();
