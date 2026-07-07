# URLConnection Transport

Cycle 3 adds `PocketBaseURLConnectionTransport`, the first concrete HTTP
transport for the PocketBase adapter. It implements `IPocketBaseTransport`, so
the existing `PocketBaseClient` and `CustomerRepositoryPocketBase` do not need
to know whether requests are handled by a fake test transport or real network
I/O.

## Transport Contract

The transport is intentionally small:

- joins `baseURL` and PocketBase API paths
- sets `Accept: application/json`
- sets `Authorization: Bearer <token>` when an auth token is present
- sends JSON bodies with `SetRequestContent(..., "application/json")`
- calls `URLConnection.SendSync`
- maps `HTTPStatusCode`, response body, and runtime exceptions into
  `PocketBaseResponse`

This keeps PocketBase repository tests focused on request semantics and record
mapping, while the concrete Xojo HTTP mechanics remain replaceable.

## Current Verification

The transport is compile-verified through Xojo Analyze. Runtime verification is
partially proven by the stock PocketBase smoke harness, which verifies the
server-side record API shape. The remaining proof boundary is a compiled Xojo
runtime smoke, because the Xojo IDE Analyze command confirms the class compiles
but does not perform a live network request.

## Runtime Companion

The repository now includes `tools/pocketbase_smoke.py`, which starts stock
PocketBase in a temporary directory, creates a test `customers` collection, and
exercises create/list/view/update/delete through the same record endpoint shape
used by `CustomerRepositoryPocketBase`.

That script proves the PocketBase side of the contract. A future Xojo runtime
smoke should drive `CustomerRepositoryPocketBase` with
`PocketBaseURLConnectionTransport` directly.
