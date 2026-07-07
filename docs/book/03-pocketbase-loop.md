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

## Current Cycle 2 Proof

Cycle 2 adds `CustomerRepositoryPocketBase` behind `ICustomerRepository`.
The proof is intentionally transport-injected, so request paths, JSON mapping,
token forwarding, create/update/delete decisions, and ViewModel compatibility can
be tested without requiring every developer machine to have a PocketBase process
running.

The next proof should add the concrete `URLConnection` transport and run it
against a stock PocketBase executable with a real `customers` collection.
