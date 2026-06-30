import { codeToHtml } from "https://esm.sh/shiki@4.3.0/bundle/web";

const effectTheme = {
  name: "effect-deep-dive",
  type: "dark",
  colors: {
    "editor.background": "#171820",
    "editor.foreground": "#f1f0f4"
  },
  tokenColors: [
    { scope: ["comment", "punctuation.definition.comment"], settings: { foreground: "#8b8a96", fontStyle: "italic" } },
    { scope: ["keyword", "storage", "storage.type", "storage.modifier"], settings: { foreground: "#d5a4ff" } },
    { scope: ["string", "constant.other.symbol"], settings: { foreground: "#8be3aa" } },
    { scope: ["constant.numeric", "constant.language", "support.constant"], settings: { foreground: "#f0c66c" } },
    { scope: ["entity.name.type", "entity.name.class", "support.type", "support.class"], settings: { foreground: "#a8b8ff" } },
    { scope: ["entity.name.function", "support.function", "variable.function"], settings: { foreground: "#93d7ff" } },
    { scope: ["variable.parameter", "variable.other.readwrite"], settings: { foreground: "#f1f0f4" } },
    { scope: ["invalid", "invalid.illegal"], settings: { foreground: "#ff8f7d" } }
  ]
};

function languageOf(code) {
  const explicit = code.dataset.lang || code.closest("pre")?.dataset.lang;
  if (explicit) return explicit;
  const cls = Array.from(code.classList).find((name) => name.startsWith("language-"));
  return cls ? cls.slice("language-".length) : "ts";
}

async function highlight(code) {
  const pre = code.closest("pre");
  if (!pre || pre.dataset.shiki === "done") return;

  const lang = languageOf(code);
  const source = code.textContent.replace(/\n$/, "");
  const html = await codeToHtml(source, { lang, theme: effectTheme });
  const holder = document.createElement("template");
  holder.innerHTML = html.trim();
  const highlighted = holder.content.firstElementChild;
  highlighted.classList.add("edd-shiki");
  highlighted.dataset.lang = lang;
  highlighted.dataset.shiki = "done";
  pre.replaceWith(highlighted);
}

async function boot() {
  const blocks = Array.from(document.querySelectorAll("pre code"));
  await Promise.all(blocks.map((block) => highlight(block).catch((error) => {
    console.warn("Shiki highlight failed", error);
  })));
}

if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot, { once: true });
else boot();
