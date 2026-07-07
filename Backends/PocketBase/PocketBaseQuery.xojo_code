#tag Class
Protected Class PocketBaseQuery
	#tag Method, Flags = &h0
		Sub Constructor(pageNumber As Integer = 1, pageSize As Integer = 30)
		  Page = pageNumber
		  PerPage = pageSize
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EncodeComponent(value As String) As String
		  Var encoded As String = value
		  encoded = encoded.ReplaceAll("%", "%25")
		  encoded = encoded.ReplaceAll(" ", "%20")
		  encoded = encoded.ReplaceAll("#", "%23")
		  encoded = encoded.ReplaceAll("&", "%26")
		  encoded = encoded.ReplaceAll("+", "%2B")
		  encoded = encoded.ReplaceAll("=", "%3D")
		  encoded = encoded.ReplaceAll("?", "%3F")
		  encoded = encoded.ReplaceAll("'", "%27")
		  encoded = encoded.ReplaceAll("""", "%22")
		  encoded = encoded.ReplaceAll("(", "%28")
		  encoded = encoded.ReplaceAll(")", "%29")
		  Return encoded
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToQueryString() As String
		  Var parts() As String
		  Var pageValue As Integer = Page
		  Var perPageValue As Integer = PerPage

		  If pageValue < 1 Then pageValue = 1
		  If perPageValue < 1 Then perPageValue = 30

		  parts.Add("page=" + pageValue.ToString())
		  parts.Add("perPage=" + perPageValue.ToString())

		  If Sort.Trim() <> "" Then parts.Add("sort=" + EncodeComponent(Sort.Trim()))
		  If Filter.Trim() <> "" Then parts.Add("filter=" + EncodeComponent(Filter.Trim()))

		  Return "?" + String.FromArray(parts, "&")
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Filter As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Page As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		PerPage As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Sort As String
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
