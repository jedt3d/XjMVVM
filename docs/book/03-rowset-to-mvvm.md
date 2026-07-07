# From RowSet To MVVM

Many Xojo desktop apps begin with direct SQL in a Window event. That is normal. Xojo makes it easy:

```xojo
Sub SearchButton_Pressed()
  CustomerList.RemoveAllRows

  Var sql As String = "SELECT id, first_name, last_name, email FROM customers " + _
    "WHERE lower(first_name) LIKE ? OR lower(last_name) LIKE ? " + _
    "ORDER BY last_name, first_name"

  Var pattern As String = "%" + SearchField.Text.Trim.Lowercase + "%"
  Var rs As RowSet = App.DB.SelectSQL(sql, pattern, pattern)

  While Not rs.AfterLastRow
    CustomerList.AddRow(rs.Column("first_name").StringValue + " " + rs.Column("last_name").StringValue, _
      rs.Column("email").StringValue)
    CustomerList.RowTagAt(CustomerList.LastAddedRowIndex) = rs.Column("id").StringValue
    rs.MoveToNextRow()
  Wend

  rs.Close()
End Sub
```

This code is understandable, and for small tools it may be enough. The problem appears when the app grows:

- Search logic is trapped inside a Window.
- `RowSet` mapping is repeated in many places.
- Tests need a real database and a real Window.
- Switching to PocketBase REST means rewriting the screen.
- Validation, permissions, paging, and error handling become scattered.

XjMVVM does not ask Xojo developers to throw away standard classes, functions, SQL, or `RowSet`. It asks them to move each responsibility to a better place.

[[diagram:rowset-to-mvvm|How direct SQL Window code becomes model, repository, ViewModel, and composition code.]]

## Step 1: Keep SQL, But Move Mapping To A Model

The first improvement is not MVVM yet. It is simply: stop passing raw columns around your app.

```xojo
Private Function CustomerFromRow(rs As RowSet) As Customer
  Var c As New Customer()
  c.ID = rs.Column("id").StringValue
  c.FirstName = rs.Column("first_name").StringValue
  c.LastName = rs.Column("last_name").StringValue
  c.Email = rs.Column("email").StringValue
  Return c
End Function
```

XjMVVM keeps this idea in the SQL repository:

[[snippet:Backends/SQL/CustomerRepositorySQL.xojo_code:141-152|Mapping a RowSet into a Customer object.]]

This is the **Data Mapper** pattern in a very practical Xojo form: database rows become objects, and objects become database parameters.

## Step 2: Name The Database Operations

The Window usually does not need to know the SQL string. It needs to say:

```xojo
Find customers matching this search term.
Count customers matching this search term.
Save this customer.
Delete this customer.
```

That is why XjMVVM defines a repository contract:

[[snippet:Core/Repositories/ICustomerRepository.xojo_code:1-33|The repository contract names business persistence operations.]]

This is the **Repository** pattern. It gives the app a collection-like interface for Customer persistence without exposing SQL, HTTP, or file storage to the ViewModel.

## Step 3: Move RowSet Code Into A Repository Adapter

The SQL does not disappear. It moves behind `ICustomerRepository`.

[[snippet:Backends/SQL/CustomerRepositorySQL.xojo_code:82-110|The SQL repository owns search, paging, and RowSet iteration.]]

Things to notice:

- `SelectSQL` is still standard Xojo.
- `RowSet` is still standard Xojo.
- Parameterized SQL is still used.
- The Window no longer knows the query.
- The ViewModel can use the same method against SQLite, direct SQL, or PocketBase.

This is also the **Adapter** pattern. `CustomerRepositorySQL` adapts Xojo `Database` and `RowSet` behavior into the `ICustomerRepository` interface.

## Step 4: Put Screen Behavior In A ViewModel

After persistence has a contract, screen behavior can move out of the Window:

[[snippet:Core/ViewModels/CustomerListViewModel.xojo_code:15-38|The list ViewModel owns loading, paging, total count, and status.]]

This is the **MVVM** pattern:

- The **View** is the Window and controls.
- The **ViewModel** is `CustomerListViewModel`.
- The **Model** is `Customer`.

The ViewModel is not a UI control. It is a plain Xojo class that can be tested.

## Step 5: Make The Window Thin

The Window becomes a translator between controls and the ViewModel:

```xojo
Private Sub ReloadCustomers()
  mListVM.SearchTerm = SearchField.Text
  mListVM.LoadPage(1, 50)

  CustomerList.RemoveAllRows
  For Each c As Customer In mListVM.Customers()
    CustomerList.AddRow(c.FullName(), c.Email)
    CustomerList.RowTagAt(CustomerList.LastAddedRowIndex) = c.ID
  Next

  StatusLabel.Text = mListVM.StatusMessage
End Sub
```

This is still normal Xojo code. It is just organized so the Window does not become the whole application.

## Step 6: Choose The Backend At The App Boundary

Once the ViewModel depends on `ICustomerRepository`, the app can select a backend during startup:

[[snippet:Composition/CustomerDesktopAppContext.xojo_code:43-64|The desktop composition root selects the concrete repository.]]

This is the **Composition Root** pattern. Object construction and backend selection happen at the app boundary instead of inside every Window.

The factory method is here:

[[snippet:Composition/CustomerRepositoryFactory.xojo_code:1-39|Factory methods construct repository adapters.]]

This is a **Factory** pattern. It centralizes construction of adapters, transports, clients, and schema setup.

## Design Patterns Used In XjMVVM

Design patterns are names for code shapes. They are useful because they let developers discuss architecture without re-explaining every class.

| Pattern | Where XjMVVM Uses It | Why It Helps Xojo Apps |
| --- | --- | --- |
| MVVM | `CustomerListViewModel`, `CustomerDetailViewModel`, Windows that call them | Moves screen behavior out of event handlers |
| Repository | `ICustomerRepository` | Gives persistence a business-facing contract |
| Adapter | `CustomerRepositorySQLite`, `CustomerRepositorySQL`, `CustomerRepositoryPocketBase` | Wraps SQLite, RowSet, and REST behind the same interface |
| Data Mapper | `CustomerFromRow`, PocketBase record mapper | Converts backend records to plain Xojo models |
| Factory | `CustomerRepositoryFactory` | Centralizes construction of backend adapters |
| Dependency Injection | ViewModels receive `ICustomerRepository` in constructors | Makes ViewModels testable and backend-independent |
| Strategy | `CustomerSQLDialect` | Lets SQL placeholder and paging behavior vary by database |
| Composition Root | `CustomerDesktopAppContext` | Keeps startup/backend decisions out of Windows |
| Validation Result | `ValidationResult` and `CustomerValidator` | Returns business validation feedback without tying it to UI controls |

## Patterns Not Used On Purpose

XjMVVM does not use an ORM. It still uses standard Xojo `Database`, `SQLiteDatabase`, `RowSet`, dictionaries, and classes.

XjMVVM does not use Active Record for Customer. A `Customer` does not save itself. This is deliberate: saving belongs to repositories so the same model can be used with SQLite, direct SQL, fake data, or PocketBase.

XjMVVM does not require automatic data binding. Xojo desktop apps can keep explicit event handlers and still benefit from MVVM.

XjMVVM does not hide backend selection in a global service locator. The app creates a context and asks that context for ViewModels.

## Translation Table For Existing Xojo Code

| Current Xojo Habit | XjMVVM Equivalent |
| --- | --- |
| SQL string in a button event | SQL inside a repository adapter |
| `RowSet` loop in a Window | `CustomerFromRow` mapper inside repository |
| ListBox rows as the only data model | `Customer` model objects |
| Repeated validation in several controls | `CustomerValidator` and ViewModel save flow |
| `App.DB` used from every Window | Repository created by composition root |
| One backend assumed forever | Backend settings choose fake, SQLite, SQL, or PocketBase |
| Manual testing through the UI only | ViewModel tests with fake repositories plus backend smokes |

## The Practical Migration Path

Do not rewrite everything at once. Move one feature:

1. Pick one Window with direct SQL.
2. Create a model class for the rows it displays.
3. Extract `RowSet` mapping into a function.
4. Define a repository interface with the operations the Window needs.
5. Move the SQL into a repository implementation.
6. Create a ViewModel that depends on the interface.
7. Change the Window to call the ViewModel.
8. Add fake repository tests.
9. Add SQLite, direct SQL, or PocketBase adapter tests.

This path respects how Xojo developers already work. It keeps the useful parts of direct SQL and `RowSet`, then wraps them in patterns that make a production app easier to grow.
