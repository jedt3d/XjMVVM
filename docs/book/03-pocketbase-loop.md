# PocketBase Loop

PocketBase is the preferred REST backend for the reboot. It should run as the
stock backend first, before the Xojo framework depends on any customized server
code.

## Adapter Boundary

The Xojo side now starts with a small REST adapter layer:

- `PocketBaseClient`
- `PocketBaseRecordMapper`
- `PocketBaseQuery`
- `PocketBaseResponse`
- `IPocketBaseTransport`
- `PocketBaseURLConnectionTransport`
- `FakePocketBaseTransport`

Domain repositories such as `CustomerRepositoryPocketBase` should sit on top of
that adapter layer and satisfy the same interface as SQLite and direct database
repositories.

## Reality Proof

The PocketBase loop is real only when it can prove:

1. PocketBase starts as-is.
2. The Customer collection schema and access rules are defined.
3. Xojo can authenticate and store the session/token safely per platform.
4. Xojo can list, create, update, delete, page, filter, and handle expected
   errors through the repository interface.
5. The same ViewModel tests pass against the fake repository and against a
   smoke-test PocketBase repository.

The first implementation should keep backend customization out of scope until
this compatibility proof passes.

## Current Proof

Cycle 2 added `CustomerRepositoryPocketBase` behind `ICustomerRepository`.
Cycle 3 added `PocketBaseURLConnectionTransport` and
`tools/pocketbase_smoke.py`. The adapter proof is intentionally
transport-injected, so request paths, JSON mapping, token forwarding,
create/update/delete decisions, and ViewModel compatibility can be tested
without requiring every unit test to start a PocketBase process.

The smoke harness now starts stock PocketBase, creates a disposable
`customers` collection, and proves the record API shape with real
create/list/view/update/delete calls. The next REST proof should run the same
path from compiled Xojo code through `PocketBaseURLConnectionTransport`.

## Production Contract

Cycle 6 adds a checked-in `pocketbase/pb_migrations` contract and a production
smoke harness. The production `customers` collection is no longer public: every
record has a required `owner` relation to the authenticated `users` record, and
list/view/create/update/delete all use:

```text
@request.auth.id != "" && owner = @request.auth.id
```

The backend is still stock PocketBase. The repository owns migrations and smoke
proofs, not a custom backend fork.
