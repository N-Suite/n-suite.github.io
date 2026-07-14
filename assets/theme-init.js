// 白飛びを防止するため、テーマの初期化は外部スクリプト

(function () {
    const darkMode = window.matchMedia("(prefers-color-scheme: dark)");

    apply();
    darkMode.addEventListener("change", () => apply());

    function apply() {
        if (darkMode.matches) document.documentElement.classList.add("dark");
        else document.documentElement.classList.remove("dark");
    }
})();
