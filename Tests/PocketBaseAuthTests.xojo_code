#tag Class
Protected Class PocketBaseAuthTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub AuthWithPasswordStoresTokenTest()
		  Var transport As New FakePocketBaseTransport()
		  transport.NextResponse = New PocketBaseResponse(200, "{""token"":""token123"",""record"":{""id"":""user123"",""email"":""ada@example.com""}}")
		  Var client As New PocketBaseClient("http://127.0.0.1:8090", transport)
		  Var service As New PocketBaseAuthService(client)

		  Var session As PocketBaseAuthSession = service.AuthWithPassword("ada@example.com", "correct-password")

		  Assert.IsTrue(session.IsValid(), "Auth session should contain token and record id")
		  Assert.AreEqual("user123", session.RecordID)
		  Assert.AreEqual("token123", client.AuthToken())
		  Assert.AreEqual("POST", transport.LastMethod)
		  Assert.AreEqual("/api/collections/users/auth-with-password", transport.LastPath)
		  Assert.IsTrue(transport.LastBody.IndexOf("""identity"":""ada@example.com""") >= 0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AuthWithPasswordCapturesValidationErrorTest()
		  Var transport As New FakePocketBaseTransport()
		  transport.NextResponse = New PocketBaseResponse(400, "{""status"":400,""message"":""An error occurred while submitting the form."",""data"":{""password"":{""code"":""validation_required"",""message"":""Missing required value.""}}}")
		  Var client As New PocketBaseClient("http://127.0.0.1:8090", transport)
		  Var service As New PocketBaseAuthService(client)

		  Var session As PocketBaseAuthSession = service.AuthWithPassword("ada@example.com", "")
		  Var err As PocketBaseError = service.LastError()

		  Assert.IsFalse(session.IsValid(), "Failed auth should return an invalid session")
		  Assert.IsNotNil(err)
		  Assert.IsTrue(err.IsValidationFailure(), "HTTP 400 should be classified as validation failure")
		  Assert.IsTrue(err.Data.HasKey("password"), "Field errors should be preserved")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PocketBaseErrorClassifiesPermissionFailuresTest()
		  Var err As PocketBaseError = PocketBaseError.FromResponse(New PocketBaseResponse(403, "{""status"":403,""message"":""The authorized record model is not allowed to perform this action."",""data"":{}}"))

		  Assert.IsTrue(err.IsPermissionFailure(), "HTTP 403 should be classified as permission failure")
		  Assert.AreEqual("The authorized record model is not allowed to perform this action.", err.Message)
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
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsRunning"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="NotImplementedCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PassedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StopTestOnFail"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
