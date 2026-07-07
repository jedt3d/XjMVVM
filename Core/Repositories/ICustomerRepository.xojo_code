#tag Interface
Protected Interface ICustomerRepository
	#tag Method, Flags = &h0
		Function Count(searchTerm As String) As Integer

		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Delete(id As String)

		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindByID(id As String) As Customer

		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindPage(searchTerm As String, pageNumber As Integer, pageSize As Integer) As Customer()

		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Save(customer As Customer) As Customer

		End Function
	#tag EndMethod

End Interface
#tag EndInterface
