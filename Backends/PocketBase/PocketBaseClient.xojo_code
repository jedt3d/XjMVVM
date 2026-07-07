#tag Class
Protected Class PocketBaseClient
	#tag Method, Flags = &h0
		Sub Constructor(baseURL As String, transport As IPocketBaseTransport, authToken As String = "")
		  mBaseURL = baseURL.Trim()
		  mTransport = transport
		  mAuthToken = authToken
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AuthToken() As String
		  Return mAuthToken
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AuthToken(Assigns value As String)
		  mAuthToken = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BaseURL() As String
		  Return mBaseURL
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Send(method As String, path As String, body As String = "") As PocketBaseResponse
		  If mTransport = Nil Then
		    Return New PocketBaseResponse(0, "", "PocketBase transport is not configured")
		  End If

		  Return mTransport.Send(method, mBaseURL, path, body, mAuthToken)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mAuthToken As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBaseURL As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTransport As IPocketBaseTransport
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
