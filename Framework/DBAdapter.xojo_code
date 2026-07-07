#tag Module
Protected Module DBAdapter
	#tag Method, Flags = &h0, Description = "Returns a fresh SQLiteDatabase connection. Call Close() when done."
		Function Connect() As SQLiteDatabase
		  Var dataFolder As FolderItem = App.ExecutableFile.Parent.Child("data")
		  If Not dataFolder.Exists Then dataFolder.CreateFolder()
		  Var dbFile As FolderItem = dataFolder.Child("notes.sqlite")
		  Var db As New SQLiteDatabase
		  db.DatabaseFile = dbFile
		  db.Connect()
		  Return db
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = "Creates the database and schema on first run. Call once from App.Opening."
		Sub InitDB()
		  Var db As SQLiteDatabase = Connect()
		  db.ExecuteSQL("CREATE TABLE IF NOT EXISTS notes (" + _
		  "id INTEGER PRIMARY KEY AUTOINCREMENT, " + _
		  "title TEXT NOT NULL, " + _
		  "body TEXT, " + _
		  "created_at TEXT DEFAULT (datetime('now')), " + _
		  "updated_at TEXT DEFAULT (datetime('now')))")
		  db.ExecuteSQL("CREATE TABLE IF NOT EXISTS tags (" + _
		  "id INTEGER PRIMARY KEY AUTOINCREMENT, " + _
		  "name TEXT NOT NULL, " + _
		  "created_at TEXT DEFAULT (datetime('now')))")
		  db.ExecuteSQL("CREATE TABLE IF NOT EXISTS note_tags (" + _
		  "note_id INTEGER NOT NULL, " + _
		  "tag_id INTEGER NOT NULL, " + _
		  "PRIMARY KEY (note_id, tag_id))")
		  db.ExecuteSQL("CREATE TABLE IF NOT EXISTS users (" + _
		  "id INTEGER PRIMARY KEY AUTOINCREMENT, " + _
		  "username TEXT NOT NULL UNIQUE, " + _
		  "password_hash TEXT NOT NULL, " + _
		  "created_at TEXT DEFAULT (datetime('now')))")
		  db.ExecuteSQL("CREATE TABLE IF NOT EXISTS customers (" + _
		  "id INTEGER PRIMARY KEY AUTOINCREMENT, " + _
		  "owner_id TEXT, " + _
		  "first_name TEXT NOT NULL, " + _
		  "last_name TEXT NOT NULL, " + _
		  "email TEXT, " + _
		  "date_of_birth TEXT, " + _
		  "gender TEXT, " + _
		  "created_at TEXT DEFAULT (datetime('now')), " + _
		  "updated_at TEXT DEFAULT (datetime('now')))")
		  db.ExecuteSQL("CREATE INDEX IF NOT EXISTS idx_customers_name ON customers (last_name, first_name)")
		  db.ExecuteSQL("CREATE INDEX IF NOT EXISTS idx_customers_email ON customers (email)")
		  db.ExecuteSQL("CREATE INDEX IF NOT EXISTS idx_customers_owner_id ON customers (owner_id)")

		  // Migration: add user_id column to notes if missing
		  Var rs As RowSet = db.SelectSQL("PRAGMA table_info(notes)")
		  Var hasUserID As Boolean = False
		  While Not rs.AfterLastRow
		    If rs.Column("name").StringValue = "user_id" Then
		      hasUserID = True
		    End If
		    rs.MoveToNextRow()
		  Wend
		  rs.Close()
		  If Not hasUserID Then
		    db.ExecuteSQL("ALTER TABLE notes ADD COLUMN user_id INTEGER NOT NULL DEFAULT 0")
		  End If
		  db.ExecuteSQL("CREATE INDEX IF NOT EXISTS idx_notes_user_id ON notes (user_id)")

		  Var customerInfo As RowSet = db.SelectSQL("PRAGMA table_info(customers)")
		  Var hasOwnerID As Boolean = False
		  While Not customerInfo.AfterLastRow
		    If customerInfo.Column("name").StringValue = "owner_id" Then
		      hasOwnerID = True
		    End If
		    customerInfo.MoveToNextRow()
		  Wend
		  customerInfo.Close()
		  If Not hasOwnerID Then
		    db.ExecuteSQL("ALTER TABLE customers ADD COLUMN owner_id TEXT")
		  End If
		  db.ExecuteSQL("CREATE INDEX IF NOT EXISTS idx_customers_owner_id ON customers (owner_id)")

		  db.Close()
		End Sub
	#tag EndMethod

End Module
#tag EndModule
