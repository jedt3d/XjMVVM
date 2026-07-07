migrate((app) => {
  let users
  try {
    users = app.findCollectionByNameOrId("users")
  } catch {
    users = new Collection({
      type: "auth",
      name: "users",
      listRule: "id = @request.auth.id",
      viewRule: "id = @request.auth.id",
      createRule: null,
      updateRule: "id = @request.auth.id",
      deleteRule: null,
      fields: [
        {
          name: "name",
          type: "text",
          required: false,
          max: 120,
        },
      ],
      passwordAuth: {
        enabled: true,
      },
    })
    app.save(users)
    users = app.findCollectionByNameOrId("users")
  }

  let ownerRule = '@request.auth.id != "" && owner = @request.auth.id'
  let customers = new Collection({
    type: "base",
    name: "customers",
    listRule: ownerRule,
    viewRule: ownerRule,
    createRule: ownerRule,
    updateRule: ownerRule,
    deleteRule: ownerRule,
    fields: [
      {
        name: "owner",
        type: "relation",
        required: true,
        maxSelect: 1,
        collectionId: users.id,
        cascadeDelete: true,
      },
      {
        name: "first_name",
        type: "text",
        required: true,
        max: 100,
      },
      {
        name: "last_name",
        type: "text",
        required: true,
        max: 100,
      },
      {
        name: "email",
        type: "email",
        required: false,
      },
      {
        name: "date_of_birth",
        type: "text",
        required: false,
        max: 40,
      },
      {
        name: "gender",
        type: "select",
        required: false,
        maxSelect: 1,
        values: ["unspecified", "female", "male", "nonbinary", "other"],
      },
    ],
    indexes: [
      "CREATE INDEX idx_customers_owner ON customers (owner)",
      "CREATE INDEX idx_customers_owner_name ON customers (owner, last_name, first_name)",
      "CREATE INDEX idx_customers_owner_email ON customers (owner, email)",
    ],
  })
  app.save(customers)
}, (app) => {
  try {
    app.delete(app.findCollectionByNameOrId("customers"))
  } catch {}
})
