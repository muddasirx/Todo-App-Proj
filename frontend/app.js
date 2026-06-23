// Point this at your ALB-backed API. Change if you used a different
// api_subdomain in Terraform, or for local testing against localhost:3000.
const API_BASE = "https://api.muhammadmuddasir.cloud";

const els = {
  input: document.getElementById("taskInput"),
  addBtn: document.getElementById("addBtn"),
  list: document.getElementById("taskList"),
  empty: document.getElementById("emptyState"),
  countQueued: document.getElementById("countQueued"),
  countShipped: document.getElementById("countShipped"),
  statusText: document.getElementById("statusText"),
  connDot: document.getElementById("connDot"),
};

function setConnection(ok) {
  els.connDot.classList.toggle("offline", !ok);
  els.statusText.textContent = ok
    ? `connected — ${API_BASE.replace("https://", "")}`
    : `cannot reach api — ${API_BASE.replace("https://", "")}`;
}

function timeAgo(dateString) {
  const seconds = Math.floor((Date.now() - new Date(dateString)) / 1000);
  if (seconds < 60) return "just now";
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  return `${Math.floor(hours / 24)}d ago`;
}

function render(todos) {
  els.list.innerHTML = "";
  els.empty.style.display = todos.length === 0 ? "block" : "none";

  let queued = 0;
  let shipped = 0;

  for (const todo of todos) {
    if (todo.completed) shipped++;
    else queued++;

    const li = document.createElement("li");
    li.className = "task-row" + (todo.completed ? " is-shipped" : "");

    const toggle = document.createElement("button");
    toggle.className = "task-row__toggle";
    toggle.type = "button";
    toggle.setAttribute(
      "aria-label",
      todo.completed ? "mark as queued" : "mark as shipped"
    );
    toggle.innerHTML =
      '<svg viewBox="0 0 16 16" fill="none"><path d="M3 8.5l3 3 7-7" stroke="#0b0e14" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    toggle.addEventListener("click", () => toggleTodo(todo));

    const body = document.createElement("div");
    body.className = "task-row__body";

    const text = document.createElement("div");
    text.className = "task-row__text";
    text.textContent = todo.text;

    const meta = document.createElement("div");
    meta.className = "task-row__meta";
    meta.textContent = `#${todo.id} · ${todo.completed ? "shipped" : "queued"} · ${timeAgo(todo.created_at)}`;

    body.appendChild(text);
    body.appendChild(meta);

    const del = document.createElement("button");
    del.className = "task-row__delete";
    del.type = "button";
    del.textContent = "rm";
    del.setAttribute("aria-label", "delete task");
    del.addEventListener("click", () => deleteTodo(todo.id));

    li.appendChild(toggle);
    li.appendChild(body);
    li.appendChild(del);
    els.list.appendChild(li);
  }

  els.countQueued.textContent = queued;
  els.countShipped.textContent = shipped;
}

async function loadTodos() {
  try {
    const res = await fetch(`${API_BASE}/api/todos`);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const todos = await res.json();
    setConnection(true);
    render(todos);
  } catch (err) {
    setConnection(false);
    console.error("Failed to load todos", err);
  }
}

async function addTodo() {
  const text = els.input.value.trim();
  if (!text) return;
  els.input.value = "";
  try {
    const res = await fetch(`${API_BASE}/api/todos`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text }),
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    await loadTodos();
  } catch (err) {
    setConnection(false);
    console.error("Failed to add todo", err);
  }
}

async function toggleTodo(todo) {
  try {
    const res = await fetch(`${API_BASE}/api/todos/${todo.id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ completed: !todo.completed }),
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    await loadTodos();
  } catch (err) {
    setConnection(false);
    console.error("Failed to update todo", err);
  }
}

async function deleteTodo(id) {
  try {
    const res = await fetch(`${API_BASE}/api/todos/${id}`, { method: "DELETE" });
    if (!res.ok && res.status !== 204) throw new Error(`HTTP ${res.status}`);
    await loadTodos();
  } catch (err) {
    setConnection(false);
    console.error("Failed to delete todo", err);
  }
}

els.addBtn.addEventListener("click", addTodo);
els.input.addEventListener("keydown", (e) => {
  if (e.key === "Enter") addTodo();
});

loadTodos();
setInterval(loadTodos, 15000);
