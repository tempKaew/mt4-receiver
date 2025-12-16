import sqlite3 from "sqlite3";
import { dirname } from "path";
import { mkdirSync } from "fs";
import { config } from "./config.js";

// Ensure database directory exists
const dbDir = dirname(config.DB_PATH);
mkdirSync(dbDir, { recursive: true });

// Initialize database
const db = new sqlite3.Database(config.DB_PATH);

// Create table
db.run(`
  CREATE TABLE IF NOT EXISTS mt4_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    acc_number INTEGER NOT NULL,
    payload TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    sent INTEGER DEFAULT 0,
    UNIQUE(acc_number)
  )
`);

// Database functions
export function upsertQueue(payload) {
  return new Promise((resolve, reject) => {
    const accNumber = payload.acc_number;
    if (!accNumber) {
      reject(new Error("acc_number is required"));
      return;
    }

    // Use INSERT OR REPLACE for upsert functionality
    db.run(
      `
      INSERT OR REPLACE INTO mt4_queue (acc_number, payload, updated_at, sent) 
      VALUES (?, ?, CURRENT_TIMESTAMP, 0)
    `,
      [accNumber, JSON.stringify(payload)],
      function (err) {
        if (err) reject(err);
        else resolve({ acc_number: accNumber, id: this.lastID });
      }
    );
  });
}

export function getPending(limit = 50) {
  return new Promise((resolve, reject) => {
    db.all(
      "SELECT * FROM mt4_queue WHERE sent = 0 LIMIT ?",
      [limit],
      (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      }
    );
  });
}

export function markSent(ids = []) {
  if (ids.length === 0) return Promise.resolve();
  return new Promise((resolve, reject) => {
    const placeholders = ids.map(() => "?").join(",");
    db.run(
      `UPDATE mt4_queue SET sent=1 WHERE id IN (${placeholders})`,
      ids,
      (err) => {
        if (err) reject(err);
        else resolve();
      }
    );
  });
}

export default db;
