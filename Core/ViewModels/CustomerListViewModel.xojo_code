#tag Class
Protected Class CustomerListViewModel
	#tag Method, Flags = &h0
		Sub Constructor(repository As ICustomerRepository)
		  mRepository = repository
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Customers() As Customer()
		  Return mCustomers
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadPage(pageNumber As Integer, pageSize As Integer)
		  mCustomers.RemoveAll
		  mTotalCount = 0
		  StatusMessage = ""
		  
		  If mRepository = Nil Then
		    StatusMessage = "No customer repository"
		    Return
		  End If
		  
		  If pageSize <= 0 Then
		    StatusMessage = "Page size must be greater than zero"
		    Return
		  End If
		  
		  Var page() As Customer = mRepository.FindPage(SearchTerm, pageNumber, pageSize)
		  For Each c As Customer In page
		    mCustomers.Add(c)
		  Next
		  
		  mTotalCount = mRepository.Count(SearchTerm)
		  StatusMessage = "Loaded " + mCustomers.Count.ToString + " customer(s)"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TotalCount() As Integer
		  Return mTotalCount
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mCustomers() As Customer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRepository As ICustomerRepository
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTotalCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		SearchTerm As String
	#tag EndProperty

	#tag Property, Flags = &h0
		StatusMessage As String
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
