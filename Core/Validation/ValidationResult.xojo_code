#tag Class
Protected Class ValidationResult
	#tag Method, Flags = &h0
		Sub AddError(message As String)
		  message = message.Trim()
		  If message.Length > 0 Then mMessages.Add(message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ErrorCount() As Integer
		  Return mMessages.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsValid() As Boolean
		  Return mMessages.Count = 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Messages() As String()
		  Return mMessages
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Summary() As String
		  Return String.FromArray(mMessages, "; ")
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mMessages() As String
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
