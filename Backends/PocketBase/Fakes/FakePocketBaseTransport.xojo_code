#tag Class
Protected Class FakePocketBaseTransport
Implements IPocketBaseTransport
	#tag Method, Flags = &h0
		Sub Constructor()
		  NextResponse = New PocketBaseResponse(200, "{}")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Send(method As String, baseURL As String, path As String, body As String, authToken As String) As PocketBaseResponse
		  LastMethod = method
		  LastBaseURL = baseURL
		  LastPath = path
		  LastBody = body
		  LastAuthToken = authToken
		  SendCount = SendCount + 1

		  If NextResponse = Nil Then Return New PocketBaseResponse(204, "")
		  Return NextResponse
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		LastAuthToken As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LastBaseURL As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LastBody As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LastMethod As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LastPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		NextResponse As PocketBaseResponse
	#tag EndProperty

	#tag Property, Flags = &h0
		SendCount As Integer
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
