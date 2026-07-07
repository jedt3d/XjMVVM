# XjMVVM PocketBase Backend

This directory contains the stock PocketBase production contract for XjMVVM.
The app still runs with the unmodified PocketBase executable; the repository
only owns migrations and smoke tooling.

## Directory Contract

- `pb_migrations/` is committed and versioned.
- `pb_data/` is runtime data and must stay ignored by Git.
- `pb_hooks/` is intentionally absent until a verified requirement needs server
  extension code.

## Current Collections

The production migration reuses PocketBase's `users` auth collection when it is
already present and creates it only if a fresh runtime does not provide one. It
then creates:

- `customers` base collection with required `owner`, `first_name`, and
  `last_name` fields.

Customer API rules enforce ownership:

```text
@request.auth.id != "" && owner = @request.auth.id
```

The same rule is used for list, view, create, update, and delete. Superusers
still bypass collection rules, as PocketBase defines.

## Local Proof

Run:

```bash
python3 tools/pocketbase_production_smoke.py --no-download
```

The smoke starts a temporary stock PocketBase instance, applies these
migrations, creates a superuser plus two auth users, and verifies:

- unauthenticated create is denied
- owner create/list/update/delete succeeds
- guest and second-user lists are empty
- second-user view/update of the owner's record is denied

This proves the backend contract. A separate compiled-Xojo runtime smoke is
still required to prove `URLConnection` behavior from the built app.
