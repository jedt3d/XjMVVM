# Direct Database

Direct database support is useful when a desktop app runs inside a trusted network, a managed enterprise desktop, or an environment where database credentials and network access can be controlled.

For most public or distributed desktop apps, prefer PocketBase REST or another server API. A direct database connection moves security responsibility into the client deployment.

## SQLite File

SQLite is the local-first path. The adapter opens a file, creates the Customer schema, and implements the repository contract.

[[snippet:Backends/SQLite/CustomerRepositorySQLite.xojo_code:11-20|Opening a SQLite file and returning a ready repository.]]

The schema is created in Xojo for the current sample framework:

[[snippet:Backends/SQLite/CustomerRepositorySQLite.xojo_code:63-83|SQLite Customer schema and indexes.]]

Use `SpecialFolder.ApplicationData` for writable per-user database files. Do not place runtime databases next to the app bundle.

## Generic SQL

The generic SQL repository works with Xojo's `Database` base class and a dialect object.

[[snippet:Backends/SQL/CustomerRepositorySQL.xojo_code:1-13|CustomerRepositorySQL receives a Database and optional dialect.]]

The dialect decides placeholder style, schema SQL, search predicates, and limit/offset syntax:

[[snippet:Backends/SQL/CustomerSQLDialect.xojo_code:35-98|Dialect helpers for generic, MySQL, ODBC, PostgreSQL, and SQLite styles.]]

For PostgreSQL, numbered placeholders are enabled:

```xojo
Var db As New PostgreSQLDatabase()
db.Host = "db.internal.example"
db.DatabaseName = "line_of_business"
db.UserName = "app_user"
db.Password = SecretStore.DatabasePassword()
db.Connect()

Var settings As CustomerBackendSettings
settings = CustomerBackendSettings.SQL(db, CustomerSQLDialect.PostgreSQL(), True)

mCustomerContext = New CustomerDesktopAppContext(settings)
```

## Query Pattern

The SQL repository uses parameterized calls for search, paging, and save operations.

[[snippet:Backends/SQL/CustomerRepositorySQL.xojo_code:82-138|Paging and saving Customers with parameterized SQL.]]

Keep this pattern. Do not concatenate user input into SQL. If a future database needs a different search operator or pagination style, add that behavior to `CustomerSQLDialect`.

## Production Guidance

Use direct SQL only when all of these are true:

- The desktop app runs in a trusted deployment environment.
- Credentials can be rotated without rebuilding the app.
- Network access to the database is restricted.
- The database role has least-privilege permissions.
- Schema changes are managed outside user-facing startup code.
- Error handling and offline behavior are acceptable for the business workflow.

SQLite remains the safer default for local-only storage. PocketBase REST remains the safer default for multi-user deployments.
