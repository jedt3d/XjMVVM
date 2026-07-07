# PocketBase Production

PocketBase is the preferred REST backend shape for XjMVVM because it can run as a stock executable while the repository owns migrations, smoke tests, and Xojo client adapters.

[[diagram:pocketbase-security|PocketBase auth and owner-only Customer access.]]

## Backend Contract

The `pocketbase` directory commits the production server contract:

- `pb_migrations/` is versioned.
- `pb_data/` is runtime data and must not be committed.
- `pb_hooks/` is not required for the current Customer contract.
- The `customers` collection belongs to a `users` auth record through `owner`.
- Collection rules require the authenticated user to own the record.

The owner rule is:

```text
@request.auth.id != "" && owner = @request.auth.id
```

## Migration

The migration creates or reuses `users`, creates `customers`, adds fields, and creates useful owner/name/email indexes.

[[snippet:pocketbase/pb_migrations/20260708041000_xjmvvm_production_customers.js:30-85|PocketBase Customer collection with owner-only rules and indexes.]]

Keep business authorization in PocketBase rules whenever possible. Keep UI convenience decisions in Xojo.

## Xojo Client

The PocketBase client separates base URL, transport, token, and requests:

[[snippet:Backends/PocketBase/PocketBaseClient.xojo_code:3-36|PocketBaseClient delegates requests to a transport and includes the current auth token.]]

Authentication writes the token back into the client:

[[snippet:Backends/PocketBase/PocketBaseAuthService.xojo_code:11-39|Password authentication produces a session and stores the token on the client.]]

That lets the repository send authenticated record requests without the ViewModel knowing about bearer tokens.

## Repository Adapter

The Customer PocketBase repository translates repository calls into Records API calls:

[[snippet:Backends/PocketBase/CustomerRepositoryPocketBase.xojo_code:49-88|FindPage and Save over the PocketBase Records API.]]

The adapter owns query filters, record parsing, and API path construction. The ViewModel still sees only Customers.

## Login Flow

A desktop login flow should look like this:

```xojo
Var transport As New PocketBaseURLConnectionTransport(30)
Var client As New PocketBaseClient(ServerURLField.Text, transport)
Var auth As New PocketBaseAuthService(client)

Var session As PocketBaseAuthSession
session = auth.AuthWithPassword(EmailField.Text, PasswordField.Text)

If Not session.IsAuthenticated() Then
  MessageBox(auth.LastError().Message)
  Return
End If

Var settings As CustomerBackendSettings
settings = CustomerBackendSettings.PocketBase(client.BaseURL(), session.Token)
App.CustomerContext = New CustomerDesktopAppContext(settings)
```

Store the token according to the security policy of the finished app. Do not hard-code production tokens in source files.

## Production Smoke Proof

The smoke harness starts stock PocketBase with temporary data, applies the committed migrations, creates a superuser and two users, and verifies that only the owner can create, list, update, and delete the Customer record.

[[snippet:tools/pocketbase_production_smoke.py:105-172|The owner-only production smoke assertions.]]

Run it locally with:

```bash
python3 tools/pocketbase_production_smoke.py
```

This proves the backend rule contract. It does not replace compiled desktop testing for URLConnection behavior, login UI, token storage, or platform-specific network failures.
