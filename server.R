library(DBI)

source("functions.R", local = TRUE)

function(input, output, session) {
  config <- config::get()

  con <- dbConnect(
    RPostgres::Postgres(),
    dbname = config$database_name,
    host = config$database_host,
    port = config$database_port,
    user = config$database_user,
    password = config$database_password,
    bigint = "numeric"
  )

  #
  # Tables
  #
  q_account_type_table <- "SELECT account_type FROM account_type"
  output$account_type_table <- DT::renderDataTable(
    dbFetch(dbSendQuery(con, q_account_type_table))
  )

  q_account_table <- "SELECT account.account_name, account_type.account_type
                      FROM account
                      JOIN account_type
                      ON account.account_type_id = account_type.account_type_id"

  output$account_table <-
    DT::renderDataTable(dbFetch(dbSendQuery(con, q_account_table)))


  q_expense_category_table <- "SELECT * FROM expense_category"
  output$expense_category_table <-
    DT::renderDataTable(dbFetch(dbSendQuery(con, q_expense_category_table)))

  q_expense_table <- "SELECT expense.expense_id, expense.date,
                             account.account_name, expense.amount,
                             expense_category.category_name, expense.note
                      FROM expense
                      JOIN expense_category
                      ON expense.category_id = expense_category.category_id
                      JOIN account
                      ON expense.account_id = account.account_id
                      ORDER BY date"
  output$expense_table <-
    DT::renderDataTable(dbFetch(dbSendQuery(con, q_expense_table)))


  #
  # selectInput options
  #
  q_account_type <- "SELECT account_type FROM account_type"
  q_expense_account <- "SELECT account_name FROM account"
  q_expense_category <- "SELECT category_name FROM expense_category"
  q_account_names <- "SELECT account_name FROM account"

  observe({
    updateSelectInput(session, "account_type",
      choices = dbFetch(dbSendQuery(con, q_account_type))
    )
    updateSelectInput(session, "expense_account",
      choices = dbFetch(dbSendQuery(con, q_expense_account))
    )

    updateSelectInput(session, "expense_category",
      choices = dbFetch(dbSendQuery(con, q_expense_category))
    )
    
    updateSelectInput(session, "subscription_category",
      choices = dbFetch(dbSendQuery(con, q_expense_category))
    )
    
    updateSelectInput(session, "net_worth_account",
      choices = dbFetch(dbSendQuery(con, q_account_names)))
  })


  #
  # Add
  #
  observeEvent(input$add_account_type, {
    q_insert_account_type <- "INSERT INTO account_type (account_type_id, account_type)
                              VALUES (DEFAULT, $1)"
    dbSendQuery(con, q_insert_account_type, c(input$account_type_name))
  })
  observeEvent(input$add_account, {
    # Return account_type_id of existing account type
    q_account_type <- "SELECT account_type_id
                       FROM account_type
                       WHERE account_type = $1"
    account_type_id <- get_id(con, q_account_type, input$account_type, "account_type_id")

    q_account <- "INSERT INTO Account (account_id, account_name, account_type_id)
                  VALUES(DEFAULT, $1, $2)"
    dbSendQuery(
      con, q_account,
      c(input$account_name, as.double(account_type_id))
    )
  })

  observeEvent(input$add_expense, {
    q_account_id <- "SELECT account_id
                     FROM account
                     WHERE account_name = $1"
    account_id <- get_id(con, q_account_id, input$expense_account, "account_id")

    q_category_id <- "SELECT category_id
                      FROM expense_category
                      WHERE category_name = $1"
    category_id <- get_id(con, q_category_id, input$expense_category, "category_id")

    q_expense <- "INSERT INTO expense (expense_id, date, account_id, amount, category_id, note)
                  VALUES (DEFAULT, $1, $2, $3, $4, $5)"
    dbSendQuery(
      con,
      q_expense,
      c(
        as.character(input$expense_date, "%Y-%m-%d"),
        account_id,
        input$expense_amount,
        category_id,
        input$expense_note
      )
    )
  })
  
  observeEvent(input$add_subscription, {
    q_category_id <- "SELECT category_id
                      FROM expense_category
                      WHERE category_name = $1"
    category_id <- get_id(con, q_category_id, input$subscription_category, "category_id")
    
    
    q_subscription <- "INSERT INTO subscription (subscription_id,
                                                 subscription_name,
                                                 category_id,
                                                 subscription_price)
                       VALUES (DEFAULT, $1, $2, $3)"
    dbSendQuery(con, q_subscription, c(input$subscription_name, category_id,
                                       input$subscription_price))
    
    
  })

  observeEvent(input$add_category, {
    q_category <- "INSERT INTO expense_category (category_id, category_name)
                   VALUES (DEFAULT, $1)"
    dbSendQuery(con, q_category, c(input$category_name))
  })
  
  observeEvent(input$set_account_value, {
    
    q_get_account_id <- "SELECT account_id
                         FROM account
                         WHERE account_name = $1"
    account_id <- get_id(con, q_get_account_id, input$net_worth_account, "account_id")
    
    # Check if account_value is entered already
    q_check_account_value <- "SELECT COUNT(*)
                              FROM account_value
                              WHERE account_id = $1"
    existing_account <- account_exists(con, q_check_account_value, account_id)
    
    if (existing_account) {
      q_update_value <- "UPDATE account_value SET account_value = $1
                         WHERE account_id = $2"
      dbSendQuery(con, q_update_value, c(input$account_current_value, account_id))
    } else {
      q_value <- "INSERT INTO account_value (account_id, account_value)
                  VALUES ($1, $2)"
      dbSendQuery(con, q_value, c(account_id, input$account_current_value))
    }
    
  })


  #
  # Plots
  #
  q_expense <- 'SELECT "date",
            		DATE_PART(\'year\', "date") AS year,
                DATE_PART(\'month\', "date") AS month,
            		DATE_PART(\'week\', "date") AS week_number,
            		to_char("date", \'W\') as week_of_month,
                EXTRACT(dow FROM "date") AS day_of_week,
                SUM(amount) as metric
                FROM expense
                GROUP BY "date"'

  expense_amounts <- reactive({
    dbFetch(dbSendQuery(con, q_expense))
  })

  output$expense_amount_heatmap <- renderPlot({
    create_heatmap(expense_amounts())
  })
  
  output$expense_amount <- renderPlot({
    plot(expense_amounts()$date, expense_amounts()$metric,
         xlab = "Date", ylab = "Amount")
  })


  q_expense_counts <- 'SELECT "date",
                    		DATE_PART(\'year\', "date") AS year,
                        DATE_PART(\'month\', "date") AS month,
                        DATE_PART(\'week\', "date") AS week_number,
                        to_char("date", \'W\') as week_of_month,
                        EXTRACT(dow FROM "date") AS day_of_week,
                    		COUNT(*) as metric
                        FROM expense
                        GROUP BY "date"'

  expense_counts <- reactive({
    dbFetch(dbSendQuery(con, q_expense_counts))
  })
  
  output$expense_count_heatmap <- renderPlot({
    create_heatmap(expense_counts())
  })

  output$expense_count <- renderPlot({
    plot(expense_counts()$date, expense_counts()$metric,
         ylim = c(0,max(expense_counts()$metric)),
         xlab = "Date", ylab = "Count")
  })


  q_expense_by_categories <- "SELECT expense_category.category_name, SUM(amount)
                              FROM expense
                              JOIN expense_category
                              ON expense.category_id = expense_category.category_id
                              GROUP BY expense_category.category_name"

  expense_by_categories <- reactive({
    dbFetch(dbSendQuery(con, q_expense_by_categories))
  })

  output$expense_by_category <- renderPlot({
    barplot(expense_by_categories()$sum,
            names.arg = expense_by_categories()$category_name,
            xlab = "Category", ylab = "Amount")
  })
  
  q_account_values <- "SELECT account.account_name, account_value.account_value
                        FROM account_value
                        LEFT JOIN account
                        ON account_value.account_id = account.account_id"
  
  account_values <- reactive({
    dbFetch(dbSendQuery(con, q_account_values))
  })
  
  output$account_values_graph <- renderPlot({
    create_stacked_bar(account_values())
  })
  
  q_all_subscriptions <- "SELECT subscription_name as name,
                                 subscription_price as price
                          FROM subscription
                          ORDER BY price"
  
  subscription_values <- reactive({
    dbFetch(dbSendQuery(con, q_all_subscriptions))
  })
  
  output$subscription_table <-
    DT::renderDataTable(dbFetch(dbSendQuery(con, q_all_subscriptions)))
  
  output$subscription_values <- renderPlot({
    ggplot(subscription_values(), aes(x = reorder(name, price), y = price)) +
      geom_col() +
      coord_flip() +
      labs(x = "", y = "Yearly Price")
  })
  
  q_week <- "SELECT expense.date,
                    expense.amount,
                    expense_category.category_name
             FROM expense
             JOIN expense_category
             ON expense.category_id = expense_category.category_id"
  
  date_expenses <- reactive({
    dbFetch(dbSendQuery(con, q_week))
  })
  
  output$expense_week <- renderPlot({
    create_category_weeks(date_expenses())
  })
  
  q_net_worth_value <- "SELECT to_char(round(SUM(account_value), 2),
                                       'fm999,999,999,999.99')
                        FROM account_value"
  
  output$net_worth_value <- renderText({
    unlist(dbFetch(dbSendQuery(con, q_net_worth_value)))
  })
  
  observeEvent(input$import_csv, {
    if (!is.null(input$csv_input)) {
      file <- input$csv_input
      
      df <- read.csv(file$datapath, skip = 3)
      df <- df[df[, "Symbol"] != "Account Total", ]
      df$Market.Value <- str_sub(df$Market.Value, 2)
      df$Market.Value <- as.numeric(df$Market.Value)
      
      output$portfolio_graph <- renderPlot({
        portfolio_bar(df)
      })
      
      output$portfolio_graph2 <- renderPlot({
        portfolio_treemap(df)
      })
      
      output$portfolio_table <- DT::renderDataTable(df, options = list(
        autoWidth = TRUE,
        scrollX = TRUE,
        fixedHeader = TRUE,
        fixedColumns = list()
      ))
    }
  })
  

}
