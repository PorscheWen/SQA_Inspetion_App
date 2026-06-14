const API = "";
let pollTimer = null;
let featuresCache = [];

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => document.querySelectorAll(sel);

function showToast(msg, isError = false) {
  const el = $("#toast");
  el.textContent = msg;
  el.className = "toast show" + (isError ? " error" : "");
  setTimeout(() => el.classList.remove("show"), 3200);
}

function switchTab(tabId) {
  $$(".tab-btn").forEach((b) => b.classList.toggle("active", b.dataset.tab === tabId));
  $$(".tab-panel").forEach((p) => p.classList.toggle("active", p.id === `panel-${tabId}`));
  if (tabId === "progress") refreshStatus();
  if (tabId === "results") refreshResults();
}

async function api(path, options = {}) {
  const res = await fetch(API + path, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || res.statusText);
  return data;
}

function getSelectedIds() {
  return [...document.querySelectorAll(".scenario-cb:checked")].map((el) => el.value);
}

function renderFeatures(features) {
  featuresCache = features;
  const container = $("#features-list");
  if (!features.length) {
    container.innerHTML = '<div class="empty-state"><p>找不到 .feature 檔案</p></div>';
    return;
  }

  container.innerHTML = features
    .map((feat) => {
      const scenariosHtml = feat.scenarios
        .map(
          (s) => `
        <li class="scenario-item">
          <input type="checkbox" class="scenario-cb" id="cb-${escapeAttr(s.id)}" value="${escapeAttr(s.id)}" checked />
          <label for="cb-${escapeAttr(s.id)}">
            <div class="title">${escapeHtml(s.title)}</div>
            <div class="tags">
              ${(s.tags || []).map((t) => `<span class="tag">@${escapeHtml(t)}</span>`).join("")}
              ${s.type === "outline" ? '<span class="tag outline">Scenario Outline</span>' : ""}
            </div>
          </label>
        </li>`
        )
        .join("");

      return `
      <article class="feature-card" data-feature="${escapeAttr(feat.file)}">
        <div class="feature-header">
          <input type="checkbox" class="feature-cb" data-feature="${escapeAttr(feat.file)}" checked />
          <div class="feature-title">
            <h3>${escapeHtml(feat.title)}</h3>
            <div class="meta">${escapeHtml(feat.file)} · ${feat.scenarios.length} 個 Scenario</div>
          </div>
        </div>
        <ul class="scenario-list">${scenariosHtml}</ul>
      </article>`;
    })
    .join("");

  container.querySelectorAll(".feature-cb").forEach((fcb) => {
    fcb.addEventListener("change", () => {
      const file = fcb.dataset.feature;
      container.querySelectorAll(".scenario-cb").forEach((scb) => {
        const card = scb.closest(".feature-card");
        if (card?.dataset.feature === file) scb.checked = fcb.checked;
      });
    });
  });
}

function escapeHtml(s) {
  const d = document.createElement("div");
  d.textContent = s;
  return d.innerHTML;
}

function escapeAttr(s) {
  return s.replace(/"/g, "&quot;").replace(/</g, "&lt;");
}

async function loadFeatures() {
  try {
    const data = await api("/api/features");
    renderFeatures(data.features);
  } catch (e) {
    showToast("載入 Features 失敗: " + e.message, true);
  }
}

async function runSelected() {
  const ids = getSelectedIds();
  if (!ids.length) {
    showToast("請至少勾選一個 Scenario", true);
    return;
  }

  const btn = $("#btn-run");
  btn.disabled = true;
  try {
    await api("/api/run", {
      method: "POST",
      body: JSON.stringify({ scenarioIds: ids, configuration: "Release" }),
    });
    showToast("測試已開始，請切換至「執行進度」查看");
    switchTab("progress");
    startPolling();
  } catch (e) {
    showToast(e.message, true);
  } finally {
    btn.disabled = false;
  }
}

function statusLabel(status) {
  const map = {
    pending: "待執行",
    running: "執行中",
    passed: "通過",
    failed: "失敗",
    skipped: "跳過",
  };
  return map[status] || status;
}

function renderProgress(status) {
  const p = status.progress || {};
  const total = p.total || 0;
  const completed = p.completed || 0;
  const pct = total ? Math.round((completed / total) * 100) : 0;

  $("#stat-total").textContent = total;
  $("#stat-done").textContent = completed;
  $("#stat-pass").textContent = p.passed || 0;
  $("#stat-fail").textContent = p.failed || 0;
  $("#progress-bar").style.width = pct + "%";
  $("#progress-label").textContent =
    status.status === "idle"
      ? "尚未執行測試"
      : status.status === "running"
        ? `執行中… ${completed}/${total}（${pct}%）`
        : `已完成 ${completed}/${total}`;

  const tbody = $("#progress-tbody");
  const scenarios = status.scenarios || [];
  if (!scenarios.length) {
    tbody.innerHTML = '<tr><td colspan="4" class="empty-state">尚無執行紀錄</td></tr>';
  } else {
    tbody.innerHTML = scenarios
      .map(
        (s) => `
      <tr>
        <td>${escapeHtml(s.feature || "")}</td>
        <td>${escapeHtml(s.title)}</td>
        <td><span class="status-badge ${s.status}">${statusLabel(s.status)}</span></td>
        <td>${s.durationSec != null ? s.durationSec + "s" : "—"}</td>
      </tr>`
      )
      .join("");
  }

  const log = (status.logTail || []).join("\n");
  $("#log-tail").textContent = log || "（等待測試輸出…）";

  const reportBar = $("#progress-report-bar");
  if (reportBar) {
    const done = status.status === "completed" || status.status === "completed_with_failures";
    if (done) {
      reportBar.innerHTML = `
        <div class="report-banner">
          <span>測試已完成，可檢視 TestResult 報告（含操作步驟與截圖）</span>
          <a class="btn btn-primary btn-sm" href="/reports/TestResultReport.html" target="_blank" rel="noopener">開啟 TestResult 報告</a>
        </div>`;
      reportBar.hidden = false;
    } else {
      reportBar.hidden = true;
      reportBar.innerHTML = "";
    }
  }
}

async function refreshStatus() {
  try {
    const status = await api("/api/status");
    renderProgress(status);
    if (status.status === "running") startPolling();
    else stopPolling();
  } catch (e) {
    console.error(e);
  }
}

function renderResults(data) {
  const junit = data.junit;
  const container = $("#results-content");

  if (!junit) {
    container.innerHTML =
      '<div class="empty-state"><p>尚無測試結果</p><p>請先在「勾選 Features」勾選並執行測試</p></div>';
    return;
  }

  const s = junit.summary;
  const links = junit.reports || {};
  const testResultUrl = links.testResult || null;
  const cacheBust = junit.generatedAt ? encodeURIComponent(junit.generatedAt) : Date.now();

  container.innerHTML = `
    <div class="results-header">
      <div class="pass-rate-ring" style="--pct: ${s.passRate}">
        <span>${s.passRate}%</span>
      </div>
      <div>
        <p style="margin:0 0 0.5rem">共 ${s.total} 項 · 通過 ${s.passed} · 失敗 ${s.failed} · 跳過 ${s.skipped}</p>
        <div class="report-links">
          ${testResultUrl ? `<a class="report-link-primary" href="${testResultUrl}?t=${cacheBust}" target="_blank" rel="noopener">TestResult 報告（步驟+截圖）</a>` : ""}
          ${links.html ? `<a href="${links.html}?t=${cacheBust}" target="_blank" rel="noopener">ExtentReports HTML</a>` : ""}
          ${links.junit ? `<a href="${links.junit}?t=${cacheBust}" target="_blank" rel="noopener">JUnit XML</a>` : ""}
        </div>
        <p style="margin:0.5rem 0 0;font-size:0.8rem;color:var(--muted)">產生時間：${escapeHtml(junit.generatedAt || "")}</p>
      </div>
    </div>
    ${
      testResultUrl
        ? `
    <section class="report-embed-section">
      <div class="report-embed-header">
        <h2>TestResult 報告預覽</h2>
        <a class="btn btn-secondary btn-sm" href="${testResultUrl}?t=${cacheBust}" target="_blank" rel="noopener">新分頁開啟</a>
      </div>
      <iframe
        class="report-embed"
        src="${testResultUrl}?t=${cacheBust}"
        title="TestResult Report"
        loading="lazy"></iframe>
    </section>`
        : ""
    }
    <table class="status-table">
      <thead>
        <tr><th>測試名稱</th><th>狀態</th><th>耗時</th><th>訊息</th></tr>
      </thead>
      <tbody>
        ${junit.cases
          .map(
            (c) => `
          <tr>
            <td>${escapeHtml(c.name)}</td>
            <td><span class="status-badge ${c.status}">${statusLabel(c.status)}</span></td>
            <td>${c.durationSec}s</td>
            <td style="max-width:280px;overflow:hidden;text-overflow:ellipsis" title="${escapeAttr(c.message)}">${escapeHtml(c.message || "—")}</td>
          </tr>`
          )
          .join("")}
      </tbody>
    </table>`;
}

async function refreshResults() {
  try {
    const data = await api("/api/results");
    renderResults(data);
  } catch (e) {
    showToast("載入結果失敗: " + e.message, true);
  }
}

function startPolling() {
  if (pollTimer) return;
  pollTimer = setInterval(async () => {
    await refreshStatus();
    const status = await api("/api/status").catch(() => null);
    if (status && status.status !== "running") {
      stopPolling();
      refreshResults();
    }
  }, 1500);
}

function stopPolling() {
  if (pollTimer) {
    clearInterval(pollTimer);
    pollTimer = null;
  }
}

function selectAll(checked) {
  document.querySelectorAll(".scenario-cb, .feature-cb").forEach((el) => {
    el.checked = checked;
  });
}

function init() {
  $$(".tab-btn").forEach((btn) => {
    btn.addEventListener("click", () => switchTab(btn.dataset.tab));
  });

  $("#btn-run").addEventListener("click", runSelected);
  $("#btn-select-all").addEventListener("click", () => selectAll(true));
  $("#btn-select-none").addEventListener("click", () => selectAll(false));
  $("#btn-refresh-progress").addEventListener("click", refreshStatus);
  $("#btn-refresh-results").addEventListener("click", refreshResults);

  loadFeatures();
  refreshStatus();
}

document.addEventListener("DOMContentLoaded", init);
