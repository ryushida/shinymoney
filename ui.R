fluidPage(navbarPage(
  title = "Personal Finance",
  tabPanel(
    "Expenses",

    sidebarPanel(
      helpText("Enter date and amount"),
      dateInput("expense_date", "Date", value = Sys.Date()),
      numericInput("expense_amount", "Amount", 0, min = 0, step = 0.01),
      selectInput("expense_account", "Account used", choices = c("")),
      selectInput("expense_category", "Category", choices = c("")),
      textInput("expense_note", "Notes", ""),
      actionButton("add_expense", "Add Expense"),
    ),

    mainPanel(tabsetPanel(
      tabPanel(
        "Expense Table",
        DT::dataTableOutput("expense_table")
      ),
      tabPanel(
        "Total Expenses by Date",
        plotOutput("expense_amount", click = "plot_click")
      ),
      tabPanel(
        "Expense Counts by Date",
        plotOutput("expense_count", click = "plot_click")
      ),
      tabPanel(
        "Expense by Category",
        plotOutput("expense_by_category", click = "plot_click")
      )
    ))
  ),
  tabPanel(
    "Config",

    tabsetPanel(
      tabPanel(
        "Expense Category",
        sidebarPanel(
          helpText("Enter Category"),
          textInput("category_name", "Category", ""),
          actionButton("add_category", "Add Category"),
        ),
        mainPanel(DT::dataTableOutput("expense_category_table"), )
      ),
      tabPanel(
        "Account",
        sidebarPanel(
          helpText("Add an account by entering the name and selecting a type"),
          textInput("account_name", "Name of Account", ""),
          selectInput("account_type", "Type of Account", choices = c("")),
          actionButton("add_account", "Add Account"),
        ),

        mainPanel(
          DT::dataTableOutput("account_table"),
        )
      ),
      tabPanel(
        "Account Type",
        sidebarPanel(
          helpText("Add an account type"),
          textInput("account_type_name", "Name of Account Type", ""),
          actionButton("add_account_type", "Add Account Type"),
        ),

        mainPanel(
          DT::dataTableOutput("account_type_table"),
        )
      )
    )
  )
))
