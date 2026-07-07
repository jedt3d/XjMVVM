# SQLite Customer Repository

Cycle 4 adds `CustomerRepositorySQLite`, a local persistence adapter behind the
same `ICustomerRepository` used by the fake repository and PocketBase adapter.
That gives the Customer ViewModels one contract for three useful modes:

- fast unit tests with `FakeCustomerRepository`
- local desktop or mobile storage with `CustomerRepositorySQLite`
- remote multi-user storage with `CustomerRepositoryPocketBase`

## Schema Boundary

The repository owns an idempotent `EnsureSchema()` method and `DBAdapter.InitDB`
now creates the same `customers` table for the existing application database.
The table stores:

- `id`
- `first_name`
- `last_name`
- `email`
- `date_of_birth`
- `gender`
- `created_at`
- `updated_at`

SQLite row IDs are converted to strings so the domain model stays compatible
with PocketBase record IDs.

## Repository Behavior

`CustomerRepositorySQLite` supports:

- `FindPage(searchTerm, pageNumber, pageSize)`
- `Count(searchTerm)`
- `FindByID(id)`
- `Save(customer)`
- `Delete(id)`

Search uses a case-insensitive SQLite `LIKE` query over first name, last name,
and email. Pagination orders by last name and first name so desktop list views
and mobile list views receive a stable result order.

## Verification

The focused `CustomerSQLiteRepositoryTests` test group uses an in-memory
`SQLiteDatabase`, calls `EnsureSchema()`, and verifies:

- saves assign string IDs
- `FindByID` maps rows back to `Customer`
- search and count share the same filter
- the existing `CustomerListViewModel` can page through SQLite
- updates do not create duplicate rows
- deletes remove records

This is the local/offline proof boundary. The remaining production work is not
the CRUD shape; it is platform-specific database file placement, encryption or
backup policy where needed, sync conflict strategy, and migration versioning.
