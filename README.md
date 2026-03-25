# memory-agent

A persistent memory agent for Urbit. Store, search, and retrieve tagged entries via HTTP API and pokes. Built for AI agents that need durable memory on a sovereign server.

## Features

- **Tagged entries** with optional keys — organize by category (`%daily`, `%soul`, `%preference`, etc.)
- **Search** — case-insensitive substring search across content, tags, and keys
- **Upsert** — update existing entries by tag+key, or insert if new
- **HTTP API** — read and search via standard HTTP endpoints
- **Filter** — query by tag, key, search term, with limit support
- **Stats** — entry and tag counts at a glance

## Quick Start

```
:: on your ship
|new-desk %memory
:: copy desk/ files to the new desk
|commit %memory
|install our %memory
```

## HTTP API

```bash
# List all entries
GET /apps/memory/api/entries

# Filter by tag
GET /apps/memory/api/entries?tag=daily

# Filter by tag and key
GET /apps/memory/api/entries?tag=daily&key=2026-03-25

# Search (case-insensitive substring)
GET /apps/memory/api/search?q=deployment

# Search within a tag
GET /apps/memory/api/search?q=compiler&tag=daily

# Stats
GET /apps/memory/api/stats

# Tags
GET /apps/memory/api/tags
```

## Write Actions (via poke)

```hoon
:: insert
:memory &memory-action [%put %daily `'2026-03-25' 'worked on search feature']

:: upsert (update if tag+key exists)
:memory &memory-action [%upsert %daily '2026-03-25' 'updated content here']

:: delete by id
:memory &memory-action [%del 0v1.abc.def]

:: delete by tag+key
:memory &memory-action [%del-key %daily '2026-03-25']

:: wipe all entries with tag
:memory &memory-action [%wipe %daily]
```

## Use Cases

- **AI agent memory** — store conversation logs, preferences, identity info
- **Personal knowledge base** — tagged notes searchable via HTTP
- **Cross-device sync** — your Urbit ship as the source of truth

## License

MIT
