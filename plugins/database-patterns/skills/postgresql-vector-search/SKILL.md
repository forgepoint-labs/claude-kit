---
name: postgresql-vector-search
description: Vector search with pgvector for RAG (retrieval-augmented generation) — embedding models (Ollama nomic-embed-text, OpenAI text-embedding-3-small), storing vectors in PostgreSQL, the <=> cosine distance operator, and when RAG helps or hurts. Use when building RAG pipelines, adding semantic search, or evaluating whether vector search is needed.
---

# PostgreSQL vector search (pgvector)

pgvector adds vector data types and distance operators to PostgreSQL, enabling semantic/similarity search directly in your relational database — no Pinecone or separate vector DB needed.

## When to use vector search

- **RAG (retrieval-augmented generation)**: Search a database of context before sending a query to an LLM. Example: product recommendations, support ticket solutions, documentation lookup.
- **Semantic similarity**: Find items with similar meaning, not just matching keywords. "pushing to prod on Friday is a nightmare" clusters with "weekend deployment downtime" even though they share no keywords.
- **Recommendation engines**: Find similar items based on content embeddings.

## Setup

```sql
-- Enable the extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Add a vector column (dimension depends on your embedding model)
ALTER TABLE comments ADD COLUMN embedding vector(768);   -- nomic-embed-text
-- ALTER TABLE comments ADD COLUMN embedding vector(1536); -- OpenAI text-embedding-3-small
```

Use the pgvector Docker image to get the extension pre-installed:
```bash
docker run --name my-postgres -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 -d pgvector/pgvector:pg18-trixie
```

## Embedding models

You need an embedding model to convert text into vectors. Two common choices:

**Ollama (local, free)**:
- Model: `nomic-embed-text` (768 dimensions, ~273MB)
- API: `POST http://localhost:11434/api/embed`
- Good for: development, privacy-sensitive data, no API costs

**OpenAI (cloud)**:
- Model: `text-embedding-3-small` (1536 dimensions)
- API: `POST https://api.openai.com/v1/embeddings`
- Good for: production, higher quality embeddings

**VoyageAI** is another option (recommended by Anthropic).

**Critical**: Use the same embedding model consistently. You cannot mix vectors from different models — they have different dimensions and meaning.

## Generating and storing embeddings

```js
// Ollama example
const res = await fetch("http://localhost:11434/api/embed", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ model: "nomic-embed-text", input: texts }),
});
const { embeddings } = await res.json();

// Store in Postgres
const vectorStr = `[${embeddings[0].join(",")}]`;
await client.query(
  "UPDATE comments SET embedding = $1 WHERE comment_id = $2",
  [vectorStr, commentId]
);
```

## Querying — cosine distance

```sql
SELECT comment, embedding <=> '[<your vectors>]' AS distance
FROM comments
ORDER BY distance
LIMIT 15;
```

- `<=>` is cosine distance (0 = identical, 2 = opposite)
- Lower distance = more similar
- You must embed your search query with the same model before searching

### Find similar to an existing record (no model call needed)
```sql
SELECT comment, embedding <=> (
  SELECT embedding FROM comments WHERE comment_id = 1
) AS distance
FROM comments
WHERE comment_id != 1
ORDER BY distance
LIMIT 15;
```

## RAG workflow

1. **Embed** all your content into the database (batch job, run once + on updates)
2. **On query**: embed the user's search string with the same model
3. **Search**: use `<=>` to find the most similar records
4. **Feed context**: pass the top results as context to your LLM
5. **Generate**: LLM responds with knowledge of your specific data

## When RAG hurts

RAG is not a silver bullet:

- **Bad retrieval is worse than no retrieval.** If your database has poor or irrelevant content, you're feeding noise into the LLM that actively steers it wrong.
- **LLMs are smart enough without it.** Sometimes the LLM already knows the answer. Test without RAG first.
- **Fine-tuning is different.** If you need to change how a model *behaves* (tone, reasoning style), that's fine-tuning, not RAG. RAG adds context; it doesn't change behavior.
- **Cost**: RAG adds latency (embedding + DB query), token cost (more context per query), and infrastructure complexity. Make sure the benefit outweighs this.

**Start without RAG. Add it when you have evidence it improves results.** You can always add it later.

## Golden rules

- ✅ Use the same embedding model for storage and search.
- ✅ Re-embed content when it changes (don't serve stale embeddings).
- ✅ Use pgvector in Postgres — eliminates the need for a separate vector DB in most cases.
- ✅ Test RAG quality before shipping — measure if retrieval actually improves LLM responses.
- ✅ Batch embed on initial load; embed new/updated content incrementally.
- ❌ Don't mix vectors from different models.
- ❌ Don't assume RAG makes everything better — it can make things worse.
- ❌ Don't skip the "does this actually help?" evaluation.

## Related skills

- `postgresql-querying` — SQL fundamentals
- `postgresql-indexing` — EXPLAIN and indexing
- `database-selection` — when PostgreSQL + pgvector vs a dedicated vector DB
