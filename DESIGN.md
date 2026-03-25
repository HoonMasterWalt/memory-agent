# Memory Agent — Design

## Overview

A persistent memory agent for Urbit that stores long-term memory, preferences, and state as sovereign data. Designed for OpenClaw agents but usable by anything that can poke/scry.

## Architecture

- **Local only.** No gossip, no networking. Memory is private.
- **Tag + key model.** Flexible categorization without rigid schemas.
- **Scryable.** Any agent or tool can read memory via standard Gall scry.
- **HTTP API.** OpenClaw (or any HTTP client) reads and writes via Eyre.
- **Import/export.** Bulk migration of existing memory files.

## Data Model

```hoon
+$  entry
  $:  id=@uv
      created=@da
      updated=@da
      tag=@tas
      key=(unit @t)
      content=@t
  ==
```

### Tags (conventions, not enforced)

| Tag | Key | Purpose |
|-----|-----|---------|
| %daily | date string | Daily log entries |
| %memory | ~ or topic | Long-term curated memory |
| %preference | pref name | User/agent preferences |
| %identity | field name | Identity information |
| %soul | ~ or section | Personality/behavior notes |
| %note | title | General knowledge |

Agents can invent any tag. No schema enforcement.

### Actions

```hoon
+$  action
  $%  [%put tag=@tas key=(unit @t) content=@t]
      [%del id=@uv]
      [%del-key tag=@tas key=@t]
      [%wipe tag=@tas]
      [%import entries=(list [tag=@tas key=(unit @t) content=@t])]
  ==
```

- `%put` — upsert. If tag+key match an existing entry, update it. Otherwise create new.
- `%del` — delete by ID.
- `%del-key` — delete by tag+key combo.
- `%wipe` — delete all entries with a given tag.
- `%import` — bulk insert (for migration).

### Scry Paths

| Path | Returns | Description |
|------|---------|-------------|
| /x/entries/all | (list entry) | Everything |
| /x/entries/tag/[tag] | (list entry) | All entries with tag |
| /x/entries/tag/[tag]/key/[key] | (unit entry) | Specific entry |
| /x/entries/id/[id] | (unit entry) | Entry by ID |
| /x/entries/since/[da] | (list entry) | Updated after date |
| /x/tags | (set @tas) | All tags in use |
| /x/export | json | Full export as JSON |

### HTTP API

**Read:**
- `GET /apps/memory/api/entries` — all entries
- `GET /apps/memory/api/entries?tag=daily` — filter by tag
- `GET /apps/memory/api/entries?tag=daily&key=2026-03-24` — specific entry
- `GET /apps/memory/api/entries?since=~2026.3.24` — recent changes
- `GET /apps/memory/api/tags` — list tags
- `GET /apps/memory/api/export` — full JSON export

**Write:**
- `POST /apps/memory/api/action` — JSON body with action

### OpenClaw Sync Flow

1. Agent starts session → GET /entries?since=[last-sync-time]
2. Populate local MEMORY.md and working files from entries
3. Work locally during session (fast reads/writes)
4. Periodically + on shutdown → POST /action with %put for changed entries
5. Ship is source of truth. Local files are cache.

If VPS dies: new instance pulls memory from ship, agent continues.

## Files

- `sur/memory.hoon` — types
- `app/memory.hoon` — agent
- `lib/memory-json.hoon` — JSON encoding/decoding
- `mar/memory-action.hoon` — action mark
- `desk.bill` — agent list
