/* Generic quick-check quiz. Wires every .quiz on the page.
   Markup:
     <div class="quiz" data-ok="..." data-no="...">
       <p class="q">question</p>
       <div class="opts">
         <button data-answer="wrong">...</button>
         <button data-answer="correct">...</button>
       </div>
       <p class="feedback" aria-live="polite"></p>
     </div>
   data-ok / data-no may contain inline HTML (authored, trusted). */
(function () {
  "use strict";
  function wire(quiz) {
    var buttons = quiz.querySelectorAll(".opts button");
    var feedback = quiz.querySelector(".feedback");
    var ok = quiz.getAttribute("data-ok") || "<strong>Correct.</strong>";
    var no = quiz.getAttribute("data-no") || "<strong>Not quite.</strong>";
    buttons.forEach(function (button) {
      button.addEventListener("click", function () {
        buttons.forEach(function (b) { b.classList.remove("correct", "wrong"); });
        var right = button.dataset.answer === "correct";
        button.classList.add(right ? "correct" : "wrong");
        if (feedback) {
          feedback.className = "feedback " + (right ? "ok" : "no");
          feedback.innerHTML = right ? ok : no;
        }
      });
    });
  }
  function boot() {
    document.querySelectorAll(".quiz").forEach(function (q) { wire(q); });
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot);
  else boot();
})();
