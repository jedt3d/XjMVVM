# Production PocketBase

Cycle 6 finishes the first production PocketBase backend contract. The backend
still uses stock PocketBase; XjMVVM owns migrations, smoke tooling, auth/error
helpers, and documentation.

## Files Added

- `pocketbase/pb_migrations/20260708041000_xjmvvm_production_customers.js`
- `pocketbase/README.md`
- `tools/pocketbase_production_smoke.py`
- `PocketBaseAuthService`
- `PocketBaseAuthSession`
- `PocketBaseError`

## Auth Model

The migration reuses PocketBase's `users` auth collection when it already
exists and creates it only if a fresh runtime does not provide one. Xojo logs in
through:

```text
POST /api/collections/users/auth-with-password
```

`PocketBaseAuthService.AuthWithPassword` sends `identity` and `password`, parses
the returned token and auth record ID, stores the token on `PocketBaseClient`,
and returns a `PocketBaseAuthSession`.

## Customer Ownership

`Customer` now has optional `OwnerID`.

- PocketBase maps `Customer.OwnerID` to the `owner` relation field.
- SQLite stores it as `owner_id`.
- Fake repositories clone it without applying rules.

The production `customers` collection has this rule for list, view, create,
update, and delete:

```text
@request.auth.id != "" && owner = @request.auth.id
```

That means a client must be authenticated and must submit its own auth record ID
as `owner` when creating a Customer.

## Error Contract

`PocketBaseError.FromResponse` parses PocketBase JSON error responses into:

- `StatusCode`
- `Message`
- `Data`

It also classifies common cases:

- `IsValidationFailure()` for HTTP 400
- `IsAuthFailure()` for HTTP 401
- `IsPermissionFailure()` for HTTP 403
- `IsNotFound()` for HTTP 404

ViewModels can later translate these into user-facing status messages without
depending on raw JSON response bodies.

## Smoke Proof

Run:

```bash
python3 tools/pocketbase_production_smoke.py --no-download
```

The local proof uses cached official PocketBase `0.39.5`, applies the checked-in
migration, creates a temporary superuser and two users, then verifies:

- unauthenticated create is denied
- owner create succeeds
- owner list returns one record
- guest list returns zero records
- second-user list returns zero records
- second-user view/update of the owner's record is denied
- owner update/delete succeeds

Latest local evidence:

```json
{
  "status": "ok",
  "base_url": "http://127.0.0.1:8100",
  "owner_list_total": 1,
  "guest_list_total": 0,
  "other_list_total": 0,
  "updated_last_name": "Byron"
}
```

## Remaining Boundary

This phase proves the production PocketBase backend contract. The next boundary
is still a compiled Xojo runtime smoke that calls the production PocketBase
instance through `PocketBaseURLConnectionTransport`.
