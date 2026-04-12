# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development Setup
```bash
docker compose up -d --build
docker compose exec app composer install
# Visit https://milty.localhost or http://localhost
# Optional: add `127.0.0.1 milty.localhost` to /etc/hosts
```

### PHP Dependencies
```bash
composer install                          # dev
composer install --no-dev --optimize-autoloader  # prod
```

### Linting & Static Analysis
```bash
composer cs:check    # check code style
composer cs:fix      # auto-fix code style
composer phpstan     # static analysis (level 5)
```

### Testing
```bash
composer paratest                                          # all tests (12 parallel processes)
composer paratest -- --processes=4 --testsuite core       # core suite only
composer paratest -- --processes=4 --testsuite data       # data suite only
composer phpunit <file_or_path>                           # single test file
```

### Production
```bash
docker compose -f deploy/docker-compose.prod.yml up -d
```

## Architecture

MiltyDraft is a Twilight Imperium draft tool — a PHP 8.2 app (no framework) with vanilla JS frontend, file-based JSON storage, and optional S3 support.

### Request Flow

```
index.php → Application (singleton)
  → HttpRequest parsing
  → Route matching (/app/routes.php)
  → RequestHandler instantiation
  → Command dispatch
  → HttpResponse
```

All routes are defined in `app/routes.php`. Each route maps to a `RequestHandler` in `app/Http/RequestHandlers/`. Handlers dispatch `Command` objects (in `app/Draft/Commands/`) that mutate domain state.

### Key Domain Concepts

- **Draft**: Central aggregate (`app/Draft/Draft.php`) — holds players, slices, faction pool, pick log
- **Slice**: A set of map tiles assigned to a player
- **TilePool**: Available tiles for slice generation, pulled from `data/tiles.json`
- **Secrets**: Per-draft admin tokens stored in the draft JSON, not exposed publicly

### Storage

The `DraftRepository` interface (`app/Draft/Repository/`) has two implementations:
- `LocalDraftRepository`: JSON files under `STORAGE_PATH` (default `data/drafts/`)
- `S3DraftRepository`: AWS S3 / DigitalOcean Spaces via Guzzle

Set `STORAGE=local` or `STORAGE=spaces` in `.env`.

### Frontend

Vanilla JS + jQuery in `/js/`. No build step — files are served directly. Cache busting via `VERSION` env var. Map rendering is handled by `js/generate-map.js`.

### Environment Variables (`.env`)
```
URL           # App base URL
STORAGE       # "local" or "spaces"
STORAGE_PATH  # Local JSON storage directory
ACCESS_KEY, ACCESS_SECRET, BUCKET, REGION  # S3 credentials
VERSION       # Cache-busting string
DEBUG         # true/false
```

### Testing Infrastructure

- `app/Testing/Factories/` — builders for domain objects in tests
- `app/Testing/Fakes/FakeDraftRepository` — in-memory repository for unit tests
- `data/test-drafts/` — fixture JSON files for integration tests
- CI runs `code-analysis` (PHPStan + CS) and `test-application` (paratest) on PRs
