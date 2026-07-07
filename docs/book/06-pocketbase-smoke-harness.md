# PocketBase Smoke Harness

Cycle 3 adds a disposable stock-PocketBase smoke script:

```bash
python3 tools/pocketbase_smoke.py
```

The script does not require a checked-in PocketBase binary. It first looks for
`POCKETBASE_BIN`, then `pocketbase` on `PATH`, then a cached official release,
and otherwise downloads the official PocketBase release for the current
platform into `~/.cache/xjmvvm-pocketbase`.

## What It Proves

The smoke test starts PocketBase with temporary `pb_data` and `pb_migrations`
directories, applies a JavaScript migration that creates a public test-only
`customers` collection, and then exercises:

- create customer record
- list customer records
- view customer record by ID
- update customer record
- delete customer record

The run removes the temporary data directory afterward unless `--keep-temp` is
provided.

## Latest Local Evidence

The first local run used PocketBase `0.39.5` on macOS ARM64 and returned:

```json
{
  "status": "ok",
  "base_url": "http://127.0.0.1:8099",
  "listed_total": 1,
  "updated_last_name": "Byron"
}
```

## Boundaries

This proves that stock PocketBase can host the `customers` collection contract
used by the XjMVVM adapter. It does not yet prove that a compiled Xojo app made
the live call, so the next runtime check should drive the same CRUD path through
`PocketBaseURLConnectionTransport`.

## Production Harness

The production backend proof now lives in:

```bash
python3 tools/pocketbase_production_smoke.py --no-download
```

Unlike the disposable public harness, this script uses the checked-in
`pocketbase/pb_migrations` directory and proves authenticated owner-only access
rules with two users.
