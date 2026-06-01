---
name: postgresql-querying
description: PostgreSQL query patterns — SELECT with projections, WHERE filters, JOINs (INNER/LEFT/RIGHT/FULL OUTER), subqueries, GROUP BY, ORDER BY, JSONB querying with bracket notation and ->> operator, and parameterized queries to prevent SQL injection. Best fit for relational data with structured schemas that benefit from cross-table relationships. Use when writing or reviewing SQL queries, building API endpoints that read from Postgres, or debugging slow queries.
---

# PostgreSQL querying patterns

PostgreSQL is a relational database where data lives in tables with pre-defined schemas. Tables relate to each other via foreign keys, and SQL is the query language.

## Schema basics

```sql
CREATE TABLE users (
  user_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  username VARCHAR(25) UNIQUE NOT NULL,
  email VARCHAR(50) UNIQUE NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  last_login TIMESTAMP,
  created_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

- Use `GENERATED ALWAYS AS IDENTITY` for auto-incrementing IDs (not `SERIAL` — it's older and less spec-compliant)
- `NOT NULL` prevents omitted values; `UNIQUE` enforces no duplicates
- `DEFAULT CURRENT_TIMESTAMP` auto-fills on insert

## SELECT fundamentals

```sql
-- All columns, all rows
SELECT * FROM users;

-- Projection: only the columns you need
SELECT username, user_id FROM users LIMIT 15;

-- WHERE filter
SELECT username, email FROM users WHERE user_id = 150;

-- NULL checks
SELECT username FROM users WHERE last_login IS NULL LIMIT 10;

-- AND + date math
SELECT username, email, created_on FROM users
WHERE last_login IS NULL AND created_on < NOW() - interval '6 months'
LIMIT 10;

-- ORDER BY (ASC default, DESC for reverse)
SELECT user_id, email, created_on FROM users ORDER BY created_on DESC LIMIT 10;

-- COUNT
SELECT COUNT(*) FROM users;
SELECT COUNT(last_login) FROM users;  -- ignores NULLs
```

Always project only the columns you need — don't `SELECT *` in production code.

## INSERT / UPDATE / DELETE

```sql
-- Insert
INSERT INTO users (username, email, full_name)
VALUES ('btholt', 'lol@example.com', 'Brian Holt');

-- Update with RETURNING
UPDATE users SET last_login = NOW() WHERE user_id = 1 RETURNING *;
UPDATE users SET full_name = 'Brian Holt', email = 'new@example.com' WHERE user_id = 2 RETURNING *;

-- Delete
DELETE FROM users WHERE user_id = 1000;
```

Use single quotes for string values. Double quotes cause errors.

## Foreign keys

```sql
CREATE TABLE comments (
  comment_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
  board_id INT REFERENCES boards(board_id) ON DELETE CASCADE,
  comment TEXT NOT NULL,
  time TIMESTAMP
);
```

- `REFERENCES` creates a foreign key constraint
- `ON DELETE CASCADE` deletes child rows when the parent is deleted
- `ON DELETE SET NULL` nulls the FK column instead
- Omitting `ON DELETE` defaults to `NO ACTION` — blocks the parent delete

## JOINs

### INNER JOIN (most common — 95% of use cases)
Returns only rows that match in both tables:
```sql
SELECT comment_id, comments.user_id, users.username, time, LEFT(comment, 20) AS preview
FROM comments
INNER JOIN users ON comments.user_id = users.user_id
WHERE board_id = 39;
```

### LEFT JOIN
Includes all rows from the left table, even without matches in the right:
```sql
SELECT boards.board_name, COUNT(comment_id) AS comment_count
FROM comments
RIGHT JOIN boards ON boards.board_id = comments.board_id
GROUP BY boards.board_name
ORDER BY comment_count;
```

### JOIN types summary
- **INNER** — only matching rows (default, most used)
- **LEFT** — all rows from left table + matching from right
- **RIGHT** — all rows from right table + matching from left
- **FULL OUTER** — all rows from both, NULLs where no match
- **CROSS** — Cartesian product (every row × every row — rarely useful)
- **NATURAL** — auto-matches columns with same name (convenient but fragile)

## Subqueries

```sql
SELECT comment_id, user_id, LEFT(comment, 20)
FROM comments
WHERE user_id = (SELECT user_id FROM users WHERE full_name = 'Maynord Simonich');
```

The inner query must return exactly one row. For multiple results, use `IN` instead of `=`.

## GROUP BY + aggregation

```sql
SELECT boards.board_name, COUNT(*) AS comment_count
FROM comments
INNER JOIN boards ON boards.board_id = comments.board_id
GROUP BY boards.board_name
ORDER BY comment_count DESC
LIMIT 10;
```

## JSONB querying

Store schemaless data in a JSONB column for flexibility within a relational model:

```sql
-- Bracket notation (PostgreSQL 14+, returns JSON)
SELECT content['type'] FROM rich_content;

-- Extract as text with ->> (needed for comparisons)
SELECT DISTINCT content ->> 'type' FROM rich_content;

-- Filter on JSON values
SELECT content ->> 'type' AS content_type, comment_id
FROM rich_content
WHERE content ->> 'type' = 'poll';

-- Nested access: brackets to navigate, ->> to extract text
SELECT
  content['dimensions'] ->> 'height' AS height,
  content['dimensions'] ->> 'width' AS width
FROM rich_content
WHERE content['dimensions'] IS NOT NULL;
```

Operators:
- `->` returns JSON type (for chaining)
- `->>` returns text (for comparisons and display)
- `['key']` bracket notation (PG14+, returns JSON)
- `#>>` extracts text from a path

## Parameterized queries (SQL injection prevention)

**Always use parameterized queries** when incorporating user input:

```js
// ✅ Safe — parameterized
client.query(
  "SELECT * FROM comments WHERE board_id = $1",
  [req.query.search]
);

// ❌ Vulnerable — string interpolation
client.query(
  `SELECT * FROM comments WHERE board_id = ${req.query.search}`
);
```

An attacker can input `1; DROP TABLE users; --` to destroy your database. Parameterized queries prevent the database from interpreting user input as SQL commands.

## Node.js connection pattern

```js
import { Pool } from "pg";
const pool = new Pool({
  connectionString: "postgresql://user:pass@localhost:5432/mydb",
});

const client = await pool.connect();
const result = await client.query("SELECT * FROM users WHERE user_id = $1", [userId]);
client.release(); // return to pool — never use client.end()
```

Use connection pools — they reuse connections instead of constantly connecting/disconnecting.

## Golden rules

- ✅ Always use parameterized queries for user input.
- ✅ Project only the columns you need.
- ✅ Use `GENERATED ALWAYS AS IDENTITY` over `SERIAL`.
- ✅ `INNER JOIN` and `LEFT JOIN` cover 95% of join needs.
- ✅ Single quotes for string values in SQL.
- ✅ Use connection pools in application code.
- ❌ Don't `SELECT *` in production — specify columns.
- ❌ Don't interpolate user input into SQL strings.
- ❌ Don't forget `LIMIT` on exploratory queries.

## Related skills

- `postgresql-indexing` — EXPLAIN, index types, full-text search
- `postgresql-vector-search` — pgvector and RAG
- `database-selection` — when to choose PostgreSQL
