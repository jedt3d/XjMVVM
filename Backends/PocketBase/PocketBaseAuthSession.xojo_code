#tag Class
Protected Class PocketBaseAuthSession
	#tag Method, Flags = &h0
		Sub Constructor(token As String = "", recordID As String = "", email As String = "")
		  Self.Token = token
		  Self.RecordID = recordID
		  Self.Email = email
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsValid() As Boolean
		  Return Token.Trim() <> "" And RecordID.Trim() <> ""
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Email As String
	#tag EndProperty

	#tag Property, Flags = &h0
		RecordID As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Token As String
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
