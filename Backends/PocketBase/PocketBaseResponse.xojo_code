#tag Class
Protected Class PocketBaseResponse
	#tag Method, Flags = &h0
		Sub Constructor(statusCode As Integer = 0, body As String = "", errorMessage As String = "")
		  Self.StatusCode = statusCode
		  Self.Body = body
		  Self.ErrorMessage = errorMessage
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsSuccess() As Boolean
		  Return ErrorMessage.Trim() = "" And StatusCode >= 200 And StatusCode < 300
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Body As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ErrorMessage As String
	#tag EndProperty

	#tag Property, Flags = &h0
		StatusCode As Integer
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
