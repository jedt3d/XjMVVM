# MVVM Core

The core is the part a developer should trust before choosing a backend. It contains the business object, validation, repository contract, and ViewModels.

## Customer Model

The Customer model is deliberately plain. It carries data, can clone itself, can format a display name, and can convert to a dictionary for adapters that need structured fields.

[[snippet:Core/Models/Customer.xojo_code:11-40|Customer cloning, display name, and dictionary mapping.]]

Prefer this style for new domain models. Keep them small, predictable, and easy to copy. Avoid making the model reach into a database or API client.

## Validation

Validation belongs outside the Window. The detail screen asks the ViewModel to save; the ViewModel asks the validator whether the Customer is acceptable.

[[snippet:Core/Validation/CustomerValidator.xojo_code:1-24|Customer validation used before persistence.]]

For production apps, add rules here when they are business rules. Add UI-only rules in the Window only when the rule is truly about presentation, such as disabling a button until a required field is typed.

## Repository Contract

Every backend adapter implements the same contract:

[[snippet:Core/Repositories/ICustomerRepository.xojo_code:1-33|The persistence contract used by Customer ViewModels.]]

This interface is the main stability point. Adding a backend should not require a new ViewModel. Adding a ViewModel should not require knowing whether data comes from PocketBase, SQLite, direct SQL, or a fake test repository.

## List ViewModel

The list ViewModel owns paging, search text, total count, and status messages.

[[snippet:Core/ViewModels/CustomerListViewModel.xojo_code:15-38|CustomerListViewModel loads one page through the repository contract.]]

The Window decides how to render `mCustomers`. The ViewModel decides how to ask for them.

## Detail ViewModel

The detail ViewModel owns load and save behavior. It validates first, then delegates persistence.

[[snippet:Core/ViewModels/CustomerDetailViewModel.xojo_code:35-58|CustomerDetailViewModel.Save validates and then persists.]]

This is the core pattern for every business edit screen:

```xojo
Function SaveButtonPressed() As Boolean
  Var c As New Customer(FirstNameField.Text, LastNameField.Text, EmailField.Text)
  c.ID = mCurrentCustomerID
  c.OwnerID = mCurrentOwnerID

  If Not mDetailVM.Save(c) Then
    MessageBox(mDetailVM.StatusMessage)
    Return False
  End If

  StatusLabel.Text = mDetailVM.StatusMessage
  Return True
End Function
```

The button handler reads fields, creates a model, calls the ViewModel, and displays the result. It does not decide where the record is saved.

## ViewModel Testing

Because the ViewModels depend on `ICustomerRepository`, tests can use a fake repository:

```xojo
Sub ListViewModelLoadsFirstPageTest()
  Var repo As New FakeCustomerRepository()
  Var vm As New CustomerListViewModel(repo)

  vm.LoadPage(1, 2)

  Assert.AreEqual(2, vm.Customers().Count)
  Assert.AreEqual(3, vm.TotalCount())
End Sub
```

Use this when a test is about screen behavior. Use SQLite, direct SQL, or PocketBase smokes only when the test is about the adapter or backend contract.
