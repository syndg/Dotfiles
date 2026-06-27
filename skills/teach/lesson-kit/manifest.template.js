/* Copy to <workspace>/assets/manifest.js — THE single place you edit to add a lesson.
   The rail, index, and progress on every page build themselves from this. */
window.LESSONS = {
  brand: { title: "{{Workspace title}}", sub: "{{track label}}", home: "index.html" },

  // paths are relative to the SITE ROOT; nav.js prefixes them per page via data-root
  lessons: [
    { id: "0001", file: "lessons/0001-slug.html", title: "{{Short title}}", blurb: "{{one-line teaser, may contain inline HTML}}" }
    // add more lessons here; that is the only edit needed
  ],

  reference: [
    // { id: "↘", file: "reference/cheatsheet.html", title: "{{title}}", blurb: "{{...}}" }
  ]
};
