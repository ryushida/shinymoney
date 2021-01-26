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
        plotOutput("expense_amount", click = "plot_click"),
        plotOutput("expense_amount_heatmap", click = "plot_click")
      ),
      tabPanel(
        "Expense Counts by Date",
        plotOutput("expense_count", click = "plot_click"),
        plotOutput("expense_count_heatmap", click = "plot_click")
      ),
      tabPanel(
        "Expense by Category",
        plotOutput("expense_by_category", click = "plot_click")
      )
    ))
  ),
  
  tabPanel(
    "Subscriptions",
    sidebarPanel(
      textInput("subscription_name", "Name", ""),
      numericInput("subscription_price", "Price per Year", value = 0, min = 0, step = 0.01),
      selectInput("subscription_category", "Category", choices = c("")),
      actionButton("add_subscription", "Add subscription")
    ),
    
    mainPanel(tabsetPanel(
      tabPanel(
        "Graph",
        plotOutput("subscription_values", click = "plot_click")
      ),
      tabPanel(
        "Table",
        DT::dataTableOutput("subscription_table")
      )
    ))
  ),
  
  tabPanel(
    "Net Worth",
    # Menu to update the current value of each Account
    sidebarPanel(
      selectInput("net_worth_account", "Account", choices = c("")),
      numericInput("account_current_value", "Current Account Value",
                   value = 0, min = 0, step = 0.01),
      actionButton("set_account_value", "Update Account Value"),
    ),
    
    mainPanel(tabsetPanel(
      tabPanel(
        "Account Values",
        plotOutput("account_values_graph", click = "plot_click")
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
