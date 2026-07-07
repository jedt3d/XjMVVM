#tag Class
Protected Class PocketBaseCustomerRepositoryTests
Inherits TestGroup
	#tag Method, Flags = &h21
		Private Function NewRepository(transport As FakePocketBaseTransport) As CustomerRepositoryPocketBase
		  Var client As New PocketBaseClient("http://127.0.0.1:8090", transport, "test-token")
		  Return New CustomerRepositoryPocketBase(client, "customers")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteUsesRecordEndpointTest()
		  Var transport As New FakePocketBaseTransport()
		  transport.NextResponse = New PocketBaseResponse(204, "")
		  Var repo As CustomerRepositoryPocketBase = NewRepository(transport)

		  repo.Delete("abc123")

		  Assert.AreEqual("DELETE", transport.LastMethod)
		  Assert.AreEqual("/api/collections/customers/records/abc123", transport.LastPath)
		  Assert.AreEqual("test-token", transport.LastAuthToken)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FindPageMapsPocketBaseRecordsTest()
		  Var transport As New FakePocketBaseTransport()
		  transport.NextResponse = New PocketBaseResponse(200, "{""page"":1,""perPage"":10,""totalItems"":1,""items"":[{""id"":""abc123"",""first_name"":""Ada"",""last_name"":""Lovelace"",""email"":""ada@example.com""}]}")
		  Var repo As CustomerRepositoryPocketBase = NewRepository(transport)

		  Var customers() As Customer = repo.FindPage("ada", 1, 10)

		  Assert.AreEqual(1, CType(customers.Count, Integer), "Repository should map one PocketBase record")
		  Assert.AreEqual("abc123", customers(0).ID)
		  Assert.AreEqual("Ada", customers(0).FirstName)
		  Assert.AreEqual("GET", transport.LastMethod)
		  Assert.IsTrue(transport.LastPath.IndexOf("/api/collections/customers/records") = 0)
		  Assert.IsTrue(transport.LastPath.IndexOf("page=1") >= 0)
		  Assert.IsTrue(transport.LastPath.IndexOf("perPage=10") >= 0)
		  Assert.IsTrue(transport.LastPath.IndexOf("filter=") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveCreatesRecordWhenIDIsBlankTest()
		  Var transport As New FakePocketBaseTransport()
		  transport.NextResponse = New PocketBaseResponse(200, "{""id"":""new123"",""first_name"":""Grace"",""last_name"":""Hopper"",""email"":""grace@example.com""}")
		  Var repo As CustomerRepositoryPocketBase = NewRepository(transport)
		  Var customer As New Customer("Grace", "Hopper", "grace@example.com")

		  Var saved As Customer = repo.Save(customer)

		  Assert.IsNotNil(saved)
		  Assert.AreEqual("new123", saved.ID)
		  Assert.AreEqual("POST", transport.LastMethod)
		  Assert.AreEqual("/api/collections/customers/records", transport.LastPath)
		  Assert.IsTrue(transport.LastBody.IndexOf("""first_name"":""Grace""") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SavePatchesRecordWhenIDExistsTest()
		  Var transport As New FakePocketBaseTransport()
		  transport.NextResponse = New PocketBaseResponse(200, "{""id"":""abc123"",""first_name"":""Ada"",""last_name"":""Byron"",""email"":""ada@example.com""}")
		  Var repo As CustomerRepositoryPocketBase = NewRepository(transport)
		  Var customer As New Customer("Ada", "Byron", "ada@example.com")
		  customer.ID = "abc123"

		  Var saved As Customer = repo.Save(customer)

		  Assert.IsNotNil(saved)
		  Assert.AreEqual("PATCH", transport.LastMethod)
		  Assert.AreEqual("/api/collections/customers/records/abc123", transport.LastPath)
		  Assert.AreEqual("Byron", saved.LastName)
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
