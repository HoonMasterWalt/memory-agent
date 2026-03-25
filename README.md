# %memory — persistent memory agent for Urbit

a sovereign, scryable memory store for AI agents running on Urbit. any agent on any ship can store and retrieve structured memory entries through pokes and HTTP reads.

## what it does

- **tag + key storage**: entries have a tag (`@tas`) and optional key (`@t`), plus freeform content
- **HTTP read API**: authenticated endpoints return JSON
- **poke writes**: `%put`, `%del`, `%wipe`, `%import` via `%memory-action` mark
- **scry support**: read entries and tags via standard Gall scry paths

## install

copy the desk contents to a desk on your ship:

```
|new-desk %memory
```

copy all files from `desk/` into the `%memory` desk, then:

```
|commit %memory
|revive %memory
```

## API

### HTTP endpoints

| method | path | description |
|--------|------|-------------|
| GET | `/apps/memory/api/entries` | all entries, sorted by updated (newest first) |
| GET | `/apps/memory/api/tags` | list of all tags |

### poke actions

poke `%memory` with mark `%memory-action`:

| action | shape | description |
|--------|-------|-------------|
| `%put` | `[%put tag=@tas key=(unit @t) content=@t]` | insert a new entry |
| `%del` | `[%del id=@uv]` | delete by id |
| `%del-key` | `[%del-key tag=@tas key=@t]` | delete by tag + key (stub) |
| `%wipe` | `[%wipe tag=@tas]` | delete all entries with tag |
| `%import` | `[%import entries=(list [tag=@tas key=(unit @t) content=@t])]` | bulk import |

### scry paths

| path | returns |
|------|---------|
| `/x/entries/all` | all entries as JSON |
| `/x/tags` | all tags as JSON |

## entry structure

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

## design

entries are identified by `@uv` (random ID from `eny.bowl`). tags are `@tas` knots — agents invent whatever tags they need. keys are optional `@t` cords for sub-categorization within a tag.

the agent is local-only. no networking, no gossip. memory is private.

built for [OpenClaw](https://github.com/openclaw/openclaw) agents running on [Tlon Messenger](https://tlon.io).

## license

MIT
