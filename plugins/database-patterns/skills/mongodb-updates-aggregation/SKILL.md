---
name: mongodb-updates-aggregation
description: MongoDB write operations and aggregation — insertOne/Many, updateOne/Many with $set/$inc/$unset, upsert, deleteOne/Many, bulkWrite, replaceOne, findOneAndUpdate, and aggregation pipelines ($match, $bucket, $sort, $group stages). Use when writing data to MongoDB, building batch operations, or deriving analytical insights from collections.
---

# MongoDB updates and aggregation

## Write operations

### Insert
```js
db.pets.insertOne({ name: "Luna", type: "dog", breed: "Havanese", age: 14 });
db.pets.insertMany([
  { name: "Fido", type: "dog", breed: "Beagle", age: 3 },
  { name: "Fluffy", type: "cat", breed: "Tabby", age: 5 }
]);
```

Always use `insertOne` / `insertMany` — the generic `insert` is deprecated.

### Update
```js
// Set a field
db.pets.updateOne(
  { type: "dog", name: "Luna", breed: "Havanese" },  // filter
  { $set: { owner: "Brian Holt" } }                   // update
);

// Increment a field across many documents
db.pets.updateMany(
  { type: "dog" },
  { $inc: { age: 1 } }
);
```

Update operators:
- `$set` — set field values
- `$inc` — increment/decrement a number
- `$unset` — remove a field
- `$push` / `$pull` — add/remove from arrays
- `$rename` — rename a field

### Upsert
Insert if not found, update if found:

```js
db.pets.updateOne(
  { type: "dog", name: "Sudo", breed: "Wheaten" },   // filter
  { $set: { type: "dog", name: "Sudo", breed: "Wheaten", age: 5, owner: "Sarah Drasner" } },
  { upsert: true }                                     // upsert flag
);
```

Provide a complete document with upsert — on the insert path you'll get incomplete documents otherwise.

### Replace
`replaceOne` replaces the entire document (deletes fields you omit):
```js
db.pets.replaceOne(
  { name: "Luna" },
  { name: "Luna", type: "dog", breed: "Havanese", age: 15 }
);
```

### Delete
```js
db.pets.deleteOne({ name: "Luna" });
db.pets.deleteMany({ type: "reptile", breed: "Havanese" });
```

### findOneAnd*
Atomic find + modify (returns the document as it was *before* the operation):

```js
db.pets.findOneAndUpdate(
  { name: "Luna" },
  { $set: { age: 15 } }
);
db.pets.findOneAndDelete({ name: "Luna" });
db.pets.findOneAndReplace({ name: "Luna" }, { /* full replacement doc */ });
```

### bulkWrite
Queue multiple operations to execute in order:

```js
db.pets.bulkWrite([
  { insertOne: { document: { name: "New Dog", type: "dog" } } },
  { updateOne: { filter: { name: "Fido" }, update: { $inc: { age: 1 } } } },
  { deleteOne: { filter: { name: "Old Cat" } } }
]);
```

## Indexes

```js
// Basic index
db.pets.createIndex({ name: 1 });

// Compound index
db.pets.createIndex({ type: 1, breed: 1 });

// Unique index
db.pets.createIndex({ index: 1 }, { unique: true });

// Check query performance
db.pets.find({ name: "Fido" }).explain("executionStats");
// Red flag: COLLSCAN (scanning every document)
// Good: IXSCAN (using an index)

// View indexes
db.pets.getIndexes();
```

## Aggregation pipelines

Chain stages to transform and analyze data. Each stage receives the output of the previous stage.

### Example: Dog age groups
```js
db.pets.aggregate([
  { $match: { type: "dog" } },           // filter to dogs only
  { $bucket: {
      groupBy: "$age",
      boundaries: [0, 3, 9, 15],          // 0-2, 3-8, 9-14
      default: "very senior",              // 15+
      output: { count: { $sum: 1 } }
  }},
  { $sort: { count: -1 } }               // most populated first
]);
```

### Common stages
- `$match` — filter documents (like `find`)
- `$group` — group by field and aggregate (`$sum`, `$avg`, `$max`, `$min`, `$count`)
- `$bucket` — group into numeric ranges
- `$sort` — order results
- `$limit` — cap results
- `$project` — reshape output (like projections)
- `$unwind` — flatten arrays into individual documents
- `$lookup` — join with another collection (like SQL JOIN)

### Group example
```js
db.pets.aggregate([
  { $group: {
      _id: "$type",
      count: { $sum: 1 },
      avgAge: { $avg: "$age" }
  }},
  { $sort: { count: -1 } }
]);
```

## Golden rules

- ✅ Use `insertOne`/`insertMany` — not deprecated `insert`.
- ✅ Use `updateOne`/`updateMany` — not deprecated `update`.
- ✅ Provide complete documents on upsert.
- ✅ Use `$inc` for counters — not `$set` with a pre-read value (races).
- ✅ Use `bulkWrite` for batch operations in code.
- ✅ Use `explain("executionStats")` to check index usage.
- ❌ Don't use `replaceOne` when you meant `updateOne` — replace deletes omitted fields.
- ❌ Don't skip indexes on fields you query frequently.
- ❌ Don't build aggregation pipelines without `$match` early — filter first to reduce data.

## Related skills

- `mongodb-querying` — find, query operators, text search
- `database-selection` — when to choose MongoDB
