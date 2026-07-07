#tag Class
Protected Class PocketBaseURLConnectionTransport
Implements IPocketBaseTransport
	#tag Method, Flags = &h0
		Sub Constructor(timeoutSeconds As Integer = 30)
		  Self.TimeoutSeconds = timeoutSeconds
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildURL(baseURL As String, path As String) As String
		  Var root As String = baseURL.Trim()
		  Var endpoint As String = path.Trim()

		  If root.EndsWith("/") Then root = root.Left(root.Length - 1)
		  If endpoint = "" Then Return root
		  If Not endpoint.BeginsWith("/") Then endpoint = "/" + endpoint

		  Return root + endpoint
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Send(method As String, baseURL As String, path As String, body As String, authToken As String) As PocketBaseResponse
		  Var connection As New URLConnection()
		  connection.FollowRedirects = True
		  connection.RequestHeader("Accept") = "application/json"

		  If authToken.Trim() <> "" Then
		    connection.RequestHeader("Authorization") = "Bearer " + authToken.Trim()
		  End If

		  If body <> "" Then
		    connection.RequestHeader("Content-Type") = "application/json"
		    connection.SetRequestContent(body, "application/json")
		  End If

		  Try
		    Var responseBody As String = connection.SendSync(method.Uppercase(), BuildURL(baseURL, path), TimeoutSeconds)
		    Return New PocketBaseResponse(connection.HTTPStatusCode, responseBody)
		  Catch err As RuntimeException
		    Var message As String = err.Message
		    If message.Trim() = "" Then message = "PocketBase HTTP request failed"
		    Return New PocketBaseResponse(connection.HTTPStatusCode, "", message)
		  End Try
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		TimeoutSeconds As Integer = 30
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
