#tag Class
Protected Class Customer
	#tag Method, Flags = &h0
		Sub Constructor(firstName As String = "", lastName As String = "", email As String = "")
		  Self.FirstName = firstName
		  Self.LastName = lastName
		  Self.Email = email
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clone() As Customer
		  Var copy As New Customer(FirstName, LastName, Email)
		  copy.ID = ID
		  copy.DateOfBirth = DateOfBirth
		  copy.Gender = Gender
		  Return copy
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FullName() As String
		  Var value As String = FirstName.Trim() + " " + LastName.Trim()
		  Return value.Trim()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToDictionary() As Dictionary
		  Var d As New Dictionary()
		  d.Value("id") = ID
		  d.Value("first_name") = FirstName
		  d.Value("last_name") = LastName
		  d.Value("email") = Email
		  d.Value("date_of_birth") = DateOfBirth
		  d.Value("gender") = Gender
		  Return d
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		DateOfBirth As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Email As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FirstName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Gender As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LastName As String
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
