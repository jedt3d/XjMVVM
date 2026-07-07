#tag Class
Protected Class CustomerCoreTests
Inherits TestGroup
	#tag Method, Flags = &h21
		Private Function SeedRepository() As FakeCustomerRepository
		  Var repo As New FakeCustomerRepository()
		  Call repo.Save(New Customer("Ada", "Lovelace", "ada@example.com"))
		  Call repo.Save(New Customer("Grace", "Hopper", "grace@example.com"))
		  Call repo.Save(New Customer("Katherine", "Johnson", "katherine@example.com"))
		  Return repo
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DetailViewModelRejectsInvalidCustomerTest()
		  Var repo As New FakeCustomerRepository()
		  Var vm As New CustomerDetailViewModel(repo)
		  Var c As New Customer("", "Lovelace", "ada@example.com")
		  
		  Assert.IsFalse(vm.Save(c), "Save should reject a missing first name")
		  Assert.IsTrue(vm.StatusMessage.IndexOf("First name") >= 0, "Status should explain validation failure")
		  Assert.AreEqual(0, repo.Count(""), "Invalid customers should not be saved")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DetailViewModelSavesValidCustomerTest()
		  Var repo As New FakeCustomerRepository()
		  Var vm As New CustomerDetailViewModel(repo)
		  Var c As New Customer("Ada", "Lovelace", "ada@example.com")
		  
		  Assert.IsTrue(vm.Save(c), "Save should accept a valid customer")
		  
		  Var saved As Customer = vm.Current()
		  Assert.IsNotNil(saved)
		  Assert.IsTrue(saved.ID > 0, "Repository should assign an ID")
		  Assert.AreEqual(1, repo.Count(""), "Repository should contain the saved customer")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ListViewModelLoadsPageTest()
		  Var repo As FakeCustomerRepository = SeedRepository()
		  Var vm As New CustomerListViewModel(repo)
		  
		  vm.LoadPage(1, 2)
		  Var customers() As Customer = vm.Customers()
		  
		  Assert.AreEqual(2, CType(customers.Count, Integer), "First page should return two customers")
		  Assert.AreEqual(3, vm.TotalCount(), "TotalCount should include all matching customers")
		  Assert.AreEqual("Ada", customers(0).FirstName)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ListViewModelSearchesCustomersTest()
		  Var repo As FakeCustomerRepository = SeedRepository()
		  Var vm As New CustomerListViewModel(repo)
		  
		  vm.SearchTerm = "grace"
		  vm.LoadPage(1, 10)
		  Var customers() As Customer = vm.Customers()
		  
		  Assert.AreEqual(1, CType(customers.Count, Integer), "Search should narrow the result set")
		  Assert.AreEqual("Hopper", customers(0).LastName)
		  Assert.AreEqual(1, vm.TotalCount())
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RepositoryDeletesCustomerTest()
		  Var repo As FakeCustomerRepository = SeedRepository()
		  Var customer As Customer = repo.FindByID(2)
		  Assert.IsNotNil(customer)
		  
		  repo.Delete(2)
		  
		  Assert.IsNil(repo.FindByID(2), "Deleted customer should not be returned")
		  Assert.AreEqual(2, repo.Count(""))
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Duration"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FailedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsRunning"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="NotImplementedCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PassedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StopTestOnFail"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
