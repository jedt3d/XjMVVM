# Repository Composition

Cycle 5 adds `CustomerRepositoryFactory` under `Composition/`. The factory is
the first app-boundary helper for choosing a Customer backend without changing
the shared ViewModels.

## Factory Methods

The factory currently exposes:

- `NewFake()`
- `NewSQLite(db, ownsConnection)`
- `NewSQLiteFile(dbFile)`
- `NewPocketBase(baseURL, authToken, collectionName, timeoutSeconds)`

Each method returns a concrete repository that also satisfies
`ICustomerRepository`, so callers can keep the type specific when they need
adapter-only lifecycle behavior such as `CustomerRepositorySQLite.Close()`, or
pass it straight into `CustomerListViewModel` and `CustomerDetailViewModel`.

## Production Role

This module should stay near the application boundary. Domain models and
ViewModels should depend on `ICustomerRepository`, while startup code chooses
the concrete repository based on platform, environment, user account state, or
offline mode.

For a desktop line-of-business app, the first production choices are likely:

- fake repository for tests and previews
- SQLite file repository for local/offline storage
- PocketBase repository for server-backed multi-user storage

Future platform projects can add their own composition modules if Xojo desktop,
iOS, and Android need different file locations, token storage, or sync policy.

## Verification

`CustomerRepositoryFactoryTests` proves that:

- the fake factory repository can save customers
- the SQLite factory repository creates its schema and saves customers
- the PocketBase factory returns a repository configured with
  `PocketBaseURLConnectionTransport`

The PocketBase factory test does not make a network call. Live REST proof stays
in the stock PocketBase smoke harness and the future compiled-Xojo runtime
smoke.
