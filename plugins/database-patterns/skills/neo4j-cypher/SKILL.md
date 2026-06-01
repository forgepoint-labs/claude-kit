---
name: neo4j-cypher
description: Neo4j graph database patterns with Cypher query language — CREATE nodes and relationships, MATCH patterns with WHERE filters, variable-length paths, shortestPath, UNWIND, constraints, indexes, and EXPLAIN. Best for data defined by multi-hop relationships (social graphs, recommendation engines, fraud detection). Use when modeling or querying graph data, or evaluating whether a graph DB is needed.
---

# Neo4j and Cypher patterns

Neo4j is a graph database. Data is stored as **nodes** (entities) connected by **relationships** (edges). Both nodes and relationships can have **labels** and **properties**.

## When to use a graph database

- Complex, multi-hop relationships are the primary thing you query
- You need shortest path, degrees of separation, or network traversal
- Relationships themselves carry meaningful data
- Examples: social networks, recommendation engines, fraud detection, org charts

Graph databases are specialized — you'll almost always run one alongside a general-purpose DB.

## Core concepts

- **Node**: An entity — `(:Person {name: "Michael Cera"})`. Labels use `CapitalCase`.
- **Relationship**: A directed connection — `-[:ACTED_IN]->`. Types use `SCREAMING_CASE`.
- **Properties**: Key-value pairs on nodes or relationships — `{name: "Michael Cera", born: 1988}`

## CREATE

```cql
-- Create a node
CREATE (:Person {name: 'Michael Cera', born: 1988});

-- Create a node and return it
CREATE (m:Movie {title: 'Scott Pilgrim vs the World', released: 2010}) RETURN m;

-- Create a relationship between existing nodes
MATCH (Michael:Person), (ScottVsWorld:Movie)
WHERE Michael.name = "Michael Cera" AND ScottVsWorld.title = "Scott Pilgrim vs the World"
CREATE (Michael)-[:ACTED_IN {roles: ["Scott Pilgrim"]}]->(ScottVsWorld);
```

The `:` before a label is critical — without it, it's a variable, not a label.

## MATCH + RETURN

```cql
-- Find a node by property
MATCH (p {name: "Michael Cera"}) RETURN p;

-- Find with label
MATCH (p:Person {name: "Michael Cera"}) RETURN p;

-- Find through relationships
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE m.title = "Scott Pilgrim vs the World"
RETURN p, m;

-- Find costars (two hops through a shared movie)
MATCH (p:Person)-[:ACTED_IN]->(Movie)<-[:ACTED_IN]-(q:Person)
WHERE p.name = "Aubrey Plaza" AND q.name <> "Aubrey Plaza"
RETURN q.name;

-- Find costars younger than a person
MATCH (p:Person)-[:ACTED_IN]->(Movie)<-[:ACTED_IN]-(q:Person)
WHERE p.name = "Aubrey Plaza" AND q.born > p.born
RETURN q.name;
```

- `<>` is "not equals" in Cypher
- Direction arrows (`->`, `<-`) are optional in queries if you don't care about direction

## Aggregation

```cql
-- Count nodes by label
MATCH (n) RETURN DISTINCT labels(n), count(*);

-- Count relationships by type
MATCH (n)-[r]->() RETURN type(r), count(*);

-- Costars ranked by shared movies
MATCH (Keanu:Person)-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(Costar:Person)
WHERE Keanu.name = "Keanu Reeves"
RETURN DISTINCT Costar.name, count(*)
ORDER BY count(*) DESC, Costar.name;
```

## Shortest path

```cql
-- Find shortest path between two people
MATCH path = shortestPath(
  (Bacon:Person {name: "Kevin Bacon"})-[*]-(Keanu:Person {name: "Keanu Reeves"})
)
RETURN path;

-- Just the length
RETURN length(path);

-- Readable path (names and titles)
MATCH path = shortestPath(
  (First:Person {name: "Kevin Bacon"})-[*..5]-(Second:Person {name: "Keanu Reeves"})
)
UNWIND nodes(path) AS node
RETURN coalesce(node.name, node.title) AS text;
```

- `[*]` = unbounded variable-length path (can be slow on large graphs)
- `[*..5]` = max 5 hops (bounded — use this in production)
- `UNWIND` expands a list into individual rows
- `coalesce` returns the first non-null value

## Variable-length paths

```cql
-- Extended network: people within 4 hops via ACTED_IN
MATCH (Halle:Person)-[:ACTED_IN*1..4]-(Recommendation:Person)
WHERE Halle.name = "Halle Berry"
RETURN DISTINCT Recommendation.name
ORDER BY Recommendation.name;

-- Any relationship type within 4 hops
MATCH (Halle:Person)-[*1..4]-(Recommendation:Person)
WHERE Halle.name = "Halle Berry"
RETURN DISTINCT Recommendation.name;
```

## Constraints and indexes

```cql
-- Unique constraint
CREATE CONSTRAINT FOR (a:Person) REQUIRE a.name IS UNIQUE;
CREATE CONSTRAINT FOR (a:Movie) REQUIRE a.title IS UNIQUE;

-- Index for performance
CREATE INDEX FOR (p:Person) ON (p.born);

-- Check query plan
EXPLAIN MATCH (p:Person) WHERE p.born = 1967 RETURN p;

-- View indexes
SHOW INDEXES;
```

## Node.js connection

```js
import neo4j from "neo4j-driver";
const driver = neo4j.driver("bolt://localhost:7687");

const session = driver.session();
const result = await session.run(
  `MATCH path = shortestPath(
    (First:Person {name: $person1})-[*]-(Second:Person {name: $person2})
  )
  UNWIND nodes(path) as node
  RETURN coalesce(node.name, node.title) as text`,
  { person1: "Kevin Bacon", person2: "Keanu Reeves" }
);

const path = result.records.map(record => record.get("text"));
await session.close();
```

- Use parameterized queries (`$person1`, `$person2`) — same injection risk as SQL
- Close sessions when done to return connections to the pool
- Neo4j uses the `bolt` protocol (not HTTP)

## Golden rules

- ✅ Use `CapitalCase` for node labels, `SCREAMING_CASE` for relationship types.
- ✅ Bound variable-length paths (`[*1..5]`) — unbounded paths can be very expensive.
- ✅ Use parameterized queries for user input.
- ✅ Close sessions after use.
- ✅ Use `EXPLAIN` to check query plans.
- ✅ Add indexes on properties you filter by frequently.
- ❌ Don't use Neo4j as your primary transactional database — pair it with Postgres/Mongo.
- ❌ Don't forget the `:` before labels — `(:Person)` not `(Person)`.
- ❌ Don't use `<>` as "not equals" in WHERE if you mean `IS NULL` — they're different.

## Related skills

- `database-selection` — when to choose a graph database
