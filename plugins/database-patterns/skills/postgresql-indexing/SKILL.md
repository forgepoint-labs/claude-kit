---
name: postgresql-indexing
description: PostgreSQL index types and query performance — EXPLAIN for query planning, B-tree indexes, compound indexes, unique indexes, GIN indexes for full-text search with tsvector/tsquery, and when to create (or avoid) indexes. Use when a query is slow, when adding a new table, or when setting up full-text search.
---

# PostgreSQL indexes and query performance

Indexes are separate data structures that let PostgreSQL find rows without scanning every record. The tradeoff: faster reads, slightly slower writes (because indexes must be updated too), and more disk space.

## EXPLAIN — see what PostgreSQL does

Before optimizing, understand the current query plan:

```sql
EXPLAIN SELECT comment_id, user_id, time, LEFT(comment, 20)
FROM comments WHERE board_id = 39 ORDER BY time DESC LIMIT 40;
```

**Red flag:** `Seq Scan on comments` — this means PostgreSQL is reading every row (O(n) linear scan). On large tables this is very expensive.

**After indexing:** `Bitmap Heap Scan` or `Index Scan` — PostgreSQL is using the index to jump to matching rows directly.

## Creating indexes

### Basic index (B-tree, default)
```sql
CREATE INDEX ON comments (board_id);
```

This turns `Seq Scan` into an indexed lookup for any query filtering on `board_id`.

### Compound index
When two columns are frequently queried together:
```sql
CREATE INDEX ON comments (board_id, time);
```

A compound index on `(board_id, time)` is better than two separate indexes when queries filter on both columns simultaneously.

### Unique index
Enforce uniqueness and get a fast lookup:
```sql
CREATE UNIQUE INDEX username_idx ON users (username);
```

Duplicate inserts will now fail. The field is also indexed for fast searches.

### View existing indexes
```sql
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'comments';
```

## Full-text search

PostgreSQL has built-in full-text search — no Elasticsearch needed for most use cases.

### Basic search
```sql
SELECT comment_id, LEFT(comment, 50)
FROM comments
WHERE to_tsvector('english', comment) @@ to_tsquery('english', 'love');
```

- `to_tsvector` converts text into searchable normalized lexemes
- `to_tsquery` converts your search term into a query
- `@@` is the "matches" operator

### GIN index for full-text search
Without an index, PostgreSQL computes the tsvector for every row on every query. Fix:

```sql
CREATE INDEX comments_search_idx
ON comments USING GIN (to_tsvector('english', comment));
```

### Boolean operators in search
```sql
-- AND: both terms must appear
WHERE to_tsvector('english', comment) @@ to_tsquery('english', 'love & dog');

-- OR: either term
WHERE to_tsvector('english', comment) @@ to_tsquery('english', 'love | hate');
```

### When to graduate to Elasticsearch
PostgreSQL full-text search handles most search needs. Consider a dedicated search engine when you need: faceted filtering, typo tolerance / fuzzy matching, custom relevance tuning, or sub-second search across billions of documents.

## When to index

**Do index:**
- Columns used in `WHERE` clauses frequently (especially in hot paths)
- Foreign key columns (queries that JOIN on these columns)
- Columns used in `ORDER BY` with `LIMIT`
- Columns that need uniqueness constraints

**Don't index:**
- Columns rarely used in queries
- Small tables (sequential scan is already fast)
- Columns with very low cardinality (e.g. a boolean — index won't help much)
- Tables that are write-heavy and rarely queried

## Golden rules

- ✅ Run `EXPLAIN` before and after adding an index to verify the improvement.
- ✅ Index foreign key columns — JOINs use them.
- ✅ Use `UNIQUE` indexes to enforce data integrity.
- ✅ Use GIN for full-text search, not basic B-tree.
- ✅ Compound indexes for frequently co-queried columns.
- ❌ Don't index everything — each index slows writes and costs disk.
- ❌ Don't forget: altering indexes on large tables can take hours.
- ❌ Don't assume you need an index — measure first with EXPLAIN.

## Related skills

- `postgresql-querying` — SQL query patterns
- `postgresql-vector-search` — pgvector and RAG
- `database-selection` — when PostgreSQL is the right choice
