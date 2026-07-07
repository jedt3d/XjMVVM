#tag Class
Protected Class PocketBaseAuthService
	#tag Method, Flags = &h0
		Sub Constructor(client As PocketBaseClient, authCollection As String = "users")
		  mClient = client
		  mAuthCollection = authCollection.Trim()
		  If mAuthCollection = "" Then mAuthCollection = "users"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AuthWithPassword(identity As String, password As String) As PocketBaseAuthSession
		  mLastError = Nil
		  If mClient = Nil Then
		    mLastError = PocketBaseError.FromResponse(New PocketBaseResponse(0, "", "PocketBase client is not configured"))
		    Return New PocketBaseAuthSession()
		  End If

		  Var body As New Dictionary()
		  body.Value("identity") = identity
		  body.Value("password") = password

		  Var response As PocketBaseResponse = mClient.Send("POST", "/api/collections/" + mAuthCollection + "/auth-with-password", GenerateJSON(body))
		  If response = Nil Or Not response.IsSuccess() Then
		    mLastError = PocketBaseError.FromResponse(response)
		    Return New PocketBaseAuthSession()
		  End If

		  Try
		    Var root As Dictionary = Dictionary(ParseJSON(response.Body))
		    Var record As Dictionary = Dictionary(root.Value("record"))
		    Var session As New PocketBaseAuthSession(root.Value("token").StringValue, record.Value("id").StringValue, FieldString(record, "email"))
		    mClient.AuthToken = session.Token
		    Return session
		  Catch
		    mLastError = PocketBaseError.FromResponse(New PocketBaseResponse(response.StatusCode, response.Body, "PocketBase auth response could not be parsed"))
		    Return New PocketBaseAuthSession()
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As PocketBaseError
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FieldString(record As Dictionary, key As String) As String
		  If record = Nil Then Return ""
		  If Not record.HasKey(key) Then Return ""

		  Var value As Variant = record.Value(key)
		  If value.IsNull Then Return ""
		  Return value.StringValue
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mAuthCollection As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mClient As PocketBaseClient
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastError As PocketBaseError
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
