# PocketBase Adapter Proof

Cycle 2 proves that PocketBase can sit behind the same Customer MVVM boundary as
the fake repository. The key design adjustment is that `Customer.ID` is now a
string, which matches PocketBase record IDs while still allowing direct database
and SQLite adapters to convert local row IDs into stable string keys.

## Source Shape

The PocketBase slice lives under `Backends/PocketBase`:

- `IPocketBaseTransport` defines the HTTP boundary.
- `PocketBaseClient` carries the base URL, auth token, and transport.
- `PocketBaseQuery` builds paged, sorted, optionally filtered record-list query
  strings.
- `PocketBaseRecordMapper` maps PocketBase record dictionaries to `Customer`.
- `CustomerRepositoryPocketBase` implements `ICustomerRepository`.
- `FakePocketBaseTransport` lets XojoUnit tests prove the adapter without a live
  server.
- `PocketBaseURLConnectionTransport` is the concrete Xojo HTTP transport for
  runtime use.

The repository uses the stock PocketBase record endpoints:

- `GET /api/collections/customers/records`
- `GET /api/collections/customers/records/{id}`
- `POST /api/collections/customers/records`
- `PATCH /api/collections/customers/records/{id}`
- `DELETE /api/collections/customers/records/{id}`

## Verified Behaviors

The new `PocketBaseCustomerRepositoryTests` group proves these adapter behaviors:

- list/search builds a records endpoint request with `page`, `perPage`, `sort`,
  and `filter`
- PocketBase JSON list responses map into `Customer` objects
- create uses `POST` when `Customer.ID` is blank
- update uses `PATCH` when `Customer.ID` is present
- delete uses the record endpoint and forwards the auth token

The existing `CustomerCoreTests` still cover the shared ViewModels through the
fake repository after the ID contract changed from integer to string.

## What Is Now Proven

Cycle 3 adds the concrete `PocketBaseURLConnectionTransport`, and
`tools/pocketbase_smoke.py` proves the stock PocketBase side by:

1. starts stock PocketBase locally
2. creates or migrates the `customers` collection
3. runs create/list/view/update/delete through the records API
4. records the exact PocketBase version and temporary base URL used for the test

## What Is Not Yet Proven

A full live Xojo runtime call still needs a smoke path that runs
`CustomerRepositoryPocketBase` with `PocketBaseURLConnectionTransport` against
that stock PocketBase process, including a real auth flow once production
collection rules are chosen.
