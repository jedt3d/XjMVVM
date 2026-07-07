#tag Interface
Protected Interface IPocketBaseTransport
	#tag Method, Flags = &h0
		Function Send(method As String, baseURL As String, path As String, body As String, authToken As String) As PocketBaseResponse

		End Function
	#tag EndMethod

End Interface
#tag EndInterface
