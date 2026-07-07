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

## What Is Not Yet Proven

This cycle does not yet prove a live network call from Xojo to PocketBase. The
next implementation cycle should add a concrete `URLConnection` transport and a
developer smoke script that:

1. starts stock PocketBase locally
2. creates or migrates the `customers` collection
3. authenticates with a test user or service account
4. runs list/create/update/delete through `CustomerRepositoryPocketBase`
5. records the exact PocketBase version and collection rules used for the test
