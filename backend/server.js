const express = require("express");
const cors = require("cors");
const mysql = require("mysql2/promise");

const PORT = process.env.PORT || 3000;
const ALLOWED_ORIGINS = (process.env.CORS_ORIGIN || "*")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  ssl: { rejectUnauthorized: false },
});

async function ensureSchema() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS todos (
      id INT AUTO_INCREMENT PRIMARY KEY,
      text VARCHAR(500) NOT NULL,
      completed BOOLEAN NOT NULL DEFAULT FALSE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
}

const app = express();
app.use(
  cors({
    origin:
      ALLOWED_ORIGINS.length === 1 && ALLOWED_ORIGINS[0] === "*"
        ? "*"
        : ALLOWED_ORIGINS,
  })
);
app.use(express.json());

// Used by the ALB target group health check.
app.get("/health", (req, res) => res.status(200).json({ status: "ok" }));

app.get("/api/todos", async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT id, text, completed, created_at FROM todos ORDER BY created_at DESC"
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch todos" });
  }
});

app.post("/api/todos", async (req, res) => {
  const { text } = req.body;
  if (!text || !text.trim()) {
    return res.status(400).json({ error: "Task text is required" });
  }
  try {
    const [result] = await pool.query(
      "INSERT INTO todos (text, completed) VALUES (?, false)",
      [text.trim()]
    );
    const [rows] = await pool.query("SELECT * FROM todos WHERE id = ?", [
      result.insertId,
    ]);
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create todo" });
  }
});

app.put("/api/todos/:id", async (req, res) => {
  const { id } = req.params;
  const { text, completed } = req.body;
  try {
    const fields = [];
    const values = [];
    if (text !== undefined) {
      fields.push("text = ?");
      values.push(text);
    }
    if (completed !== undefined) {
      fields.push("completed = ?");
      values.push(completed);
    }
    if (fields.length === 0) {
      return res.status(400).json({ error: "Nothing to update" });
    }
    values.push(id);
    await pool.query(`UPDATE todos SET ${fields.join(", ")} WHERE id = ?`, values);
    const [rows] = await pool.query("SELECT * FROM todos WHERE id = ?", [id]);
    if (rows.length === 0) return res.status(404).json({ error: "Not found" });
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update todo" });
  }
});

app.delete("/api/todos/:id", async (req, res) => {
  try {
    await pool.query("DELETE FROM todos WHERE id = ?", [req.params.id]);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to delete todo" });
  }
});

ensureSchema()
  .then(() => {
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`todo-backend listening on :${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Failed to initialize DB schema", err);
    process.exit(1);
  });
