(function () {
    const API_BASE = window.location.protocol.startsWith("http")
        ? ""
        : "http://localhost:6688";

    function ensureHttpManual() {
        if (!window.location.protocol.startsWith("http")) {
            const target = "http://localhost:6688/docs/index.html";
            if (confirm("請透過本機伺服器開啟操作手冊，才能一鍵執行 .bat。\n\n是否改開啟 " + target + " ？")) {
                window.location.href = target;
            }
            return false;
        }
        return true;
    }

    function showStatus(message, isError) {
        let box = document.getElementById("launch-status");
        if (!box) {
            box = document.createElement("div");
            box.id = "launch-status";
            box.className = "launch-status";
            document.body.appendChild(box);
        }
        box.textContent = message;
        box.classList.toggle("error", !!isError);
        box.classList.add("show");
        clearTimeout(box._hideTimer);
        box._hideTimer = setTimeout(() => box.classList.remove("show"), 5000);
    }

    async function launchBat(bat, args) {
        if (!ensureHttpManual()) return;

        const payload = { bat: bat };
        if (args && args.length) payload.args = args;

        try {
            const res = await fetch(API_BASE + "/api/launch-bat", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload),
            });
            const data = await res.json();
            if (!res.ok) {
                showStatus(data.error || "啟動失敗", true);
                return;
            }
            showStatus(data.message || "已啟動", false);
        } catch (err) {
            showStatus("無法連線操作手冊伺服器 (port 6688)。請先執行 開啟操作手冊.bat。", true);
        }
    }

    async function launchExe(exe) {
        if (!ensureHttpManual()) return;

        try {
            const res = await fetch(API_BASE + "/api/launch-exe", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ exe: exe }),
            });
            const data = await res.json();
            if (!res.ok) {
                showStatus(data.error || "啟動失敗", true);
                return;
            }
            showStatus(data.message || "已啟動", false);
        } catch (err) {
            showStatus("無法連線操作手冊伺服器 (port 6688)。請先執行 開啟操作手冊.bat。", true);
        }
    }

    function promptSingleTest() {
        const tc = prompt("請輸入 TC 編號（TC01 ~ TC10）", "TC01");
        if (!tc) return;
        const normalized = tc.trim().toUpperCase();
        if (!/^TC\d{2}$/.test(normalized) || parseInt(normalized.slice(2), 10) < 1 || parseInt(normalized.slice(2), 10) > 10) {
            showStatus("格式錯誤，請使用 TC01 ~ TC10", true);
            return;
        }
        launchBat("執行單一測試.bat", [normalized]);
    }

    function batNameFromHref(href) {
        if (!href) return null;
        const decoded = decodeURIComponent(href);
        const parts = decoded.split("/");
        const name = parts[parts.length - 1];
        if (!name.toLowerCase().endsWith(".bat")) return null;
        if (parts.length === 2 && parts[0] === "..") return name;
        return null;
    }

    function bindLaunchers() {
        document.querySelectorAll("[data-launch-bat]").forEach((el) => {
            el.addEventListener("click", (event) => {
                event.preventDefault();
                const bat = el.getAttribute("data-launch-bat");
                const argsRaw = el.getAttribute("data-launch-args");
                const args = argsRaw ? argsRaw.split(/\s+/).filter(Boolean) : [];
                if (bat === "執行單一測試.bat" && !args.length) {
                    promptSingleTest();
                    return;
                }
                launchBat(bat, args);
            });
        });

        document.querySelectorAll("[data-launch-exe]").forEach((el) => {
            el.addEventListener("click", (event) => {
                event.preventDefault();
                launchExe(el.getAttribute("data-launch-exe"));
            });
        });

        document.querySelectorAll('a.file-link[href$=".bat"]').forEach((el) => {
            const bat = batNameFromHref(el.getAttribute("href"));
            if (!bat) return;
            el.addEventListener("click", (event) => {
                event.preventDefault();
                if (bat === "執行單一測試.bat") {
                    promptSingleTest();
                    return;
                }
                launchBat(bat, []);
            });
            el.classList.add("launch-bat");
        });
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", bindLaunchers);
    } else {
        bindLaunchers();
    }
})();
