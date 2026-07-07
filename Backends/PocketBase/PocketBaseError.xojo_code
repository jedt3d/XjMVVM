#tag Class
Protected Class PocketBaseError
	#tag Method, Flags = &h0
		Shared Function FromResponse(response As PocketBaseResponse) As PocketBaseError
		  Var result As New PocketBaseError()
		  result.Data = New Dictionary()

		  If response = Nil Then
		    result.Message = "PocketBase response was not available"
		    Return result
		  End If

		  result.StatusCode = response.StatusCode
		  result.Message = response.ErrorMessage

		  Try
		    If response.Body.Trim() <> "" Then
		      Var parsed As Dictionary = Dictionary(ParseJSON(response.Body))
		      If parsed.HasKey("message") Then result.Message = parsed.Value("message").StringValue
		      If parsed.HasKey("data") Then result.Data = Dictionary(parsed.Value("data"))
		    End If
		  Catch
		  End Try

		  If result.Message.Trim() = "" Then result.Message = "PocketBase request failed"
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsAuthFailure() As Boolean
		  Return StatusCode = 401
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsNotFound() As Boolean
		  Return StatusCode = 404
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsPermissionFailure() As Boolean
		  Return StatusCode = 403
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsValidationFailure() As Boolean
		  Return StatusCode = 400
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Data As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Message As String
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
