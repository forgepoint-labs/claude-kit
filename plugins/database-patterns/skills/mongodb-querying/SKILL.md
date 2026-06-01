---
name: mongodb-querying
description: MongoDB query patterns — find/findOne, query operators ($gt/$lt/$in/$ne/$eq), logical operators ($and/$or/$not/$nor), sorts, projections, limits, cursors, and text search with $text. Best fit for unstructured or variably-shaped document data. Use when writing MongoDB queries, building API endpoints that read from Mongo, or debugging query results.
---

# MongoDB querying patterns

MongoDB is a document-based database. Data lives in collections of JSON-like documents with flexible schemas — no migration needed to add fields.

## Databases and collections

- A **database** groups related collections (like a spreadsheet file)
- A **collection** groups related documents (like a spreadsheet tab)
- A **document** is one object/record in a collection

```js
use adoption;        // switch to / create database
db.pets.insertOne({  // insert into "pets" collection (created on the fly)
  name: "Luna", type: "dog", breed: "Havanese", age: 14
});
```

## findOne — single document

```js
db.pets.findOne();                           // any document
db.pets.findOne({ index: 1337 });            // by field value
db.pets.findOne({ name: "Spot", type: "dog" }); // multiple conditions (implicit AND)
```

## find — multiple documents

```js
db.pets.find({ type: "dog" });              // returns a cursor (20 at a time)
db.pets.find({ type: "dog" }).limit(40);    // cap results
db.pets.find({ type: "dog" }).limit(40).toArray(); // dump all at once
```

Cursors return 20 results at a time. Use `it` in the shell to iterate, or `.toArray()` in code.

## Query operators

```js
db.pets.countDocuments({ type: "cat", age: { $gt: 12 } }); // senior cats

// Available operators
// $gt, $gte    — greater than, greater than or equal
// $lt, $lte    — less than, less than or equal
// $eq          — equals (usually implicit)
// $ne          — not equals
// $in          — value is in array
// $nin         — value is NOT in array
```

```js
db.pets.find({ type: { $ne: "dog" }, name: "Fido" }); // Fidos that aren't dogs
```

## Logical operators

```js
// AND: birds between 4 and 8 years
db.pets.find({
  type: "bird",
  $and: [{ age: { $gte: 4 } }, { age: { $lte: 8 } }]
});

// Also: $or, $nor, $not
```

Note: `$not` is a logical operator (negates a condition), `$ne` is a comparison operator (`!==`).

## Sorts

```js
db.pets.find({ type: "dog" }).sort({ age: -1 }); // descending
db.pets.find({ type: "dog" }).sort({ age: 1 });  // ascending
```

## Projections

Control which fields are returned:

```js
// Include only name and breed (plus _id by default)
db.pets.find({ type: "dog" }, { name: 1, breed: 1 });

// Exclude _id
db.pets.find({ type: "dog" }, { name: 1, breed: 1, _id: 0 });

// Exclude specific fields (include everything else)
db.pets.find({ type: "dog" }, { _id: 0 });
```

`1` / `true` = include, `0` / `false` = exclude. Don't mix include and exclude (except `_id`).

## Text search

Requires a text index first:

```js
db.pets.createIndex({ type: "text", breed: "text", name: "text" });

// Search (any match)
db.pets.find({ $text: { $search: "dog Havanese Luna" } });

// Sort by relevance
db.pets.find(
  { $text: { $search: "dog Havanese Luna" } },
  { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } });

// Exclude terms with -
db.pets.find({ $text: { $search: "-cat Luna" } });
```

Each collection can only have one text index.

## Node.js connection

```js
import { MongoClient } from "mongodb";
const client = new MongoClient("mongodb://localhost:27017");
await client.connect();

const db = client.db("adoption");
const collection = db.collection("pets");

const pets = await collection
  .find({ $text: { $search: searchTerm } }, { projection: { _id: 0 } })
  .sort({ score: { $meta: "textScore" } })
  .limit(10)
  .toArray();
```

## Golden rules

- ✅ Use `findOne` when you expect one result, `find` for multiple.
- ✅ Always use projections to limit returned fields.
- ✅ Use `.limit()` — don't fetch unbounded result sets.
- ✅ `countDocuments()` over deprecated `count()`.
- ✅ Use `$and`/`$or` explicitly for complex logic.
- ❌ Don't rely on document insertion order — use explicit sorts.
- ❌ Don't mix include/exclude in projections (except `_id`).
- ❌ Don't assume all documents have the same fields — MongoDB is schemaless.

## Related skills

- `mongodb-updates-aggregation` — writes, upserts, aggregation pipelines
- `database-selection` — when to choose MongoDB vs PostgreSQL
