library(tidyverse)
library(treemapify)

get_id <- function(con, query, value, colname) {
  id <- dbSendQuery(con, query)
  dbBind(id, c(value))
  id <- dbFetch(id)[[colname]]
}

account_exists <- function(con, query, id) {
  count <- dbFetch(dbSendQuery(con, query, id))
  exists <- ifelse(count > 0, TRUE, FALSE)
}

create_stacked_bar <- function(df) {
  df <- df %>% mutate(Values = "")
  ggplot(df, aes(Values, account_value / sum(account_value), fill = account_name)) +
    geom_col() +
    geom_text(aes(label = paste0(format(
      round(account_value / sum(account_value) * 100, 2), nsmall = 2
    ), "%")),
    position = position_stack(vjust = 0.5)) +
    coord_flip() +
    labs(y = "Proportions", fill = "Account Names")
}

create_category_weeks <- function(df) {
  df$date <- as.Date(df$date, format = "%Y-%m-%d")
  
  ggplot(df, aes(x = date, y = amount, color = category_name)) +
    geom_line() +
    geom_point() +
    theme_bw()
}

create_heatmap <- function(df) {
  ggplot(add_day_text(df), aes(week_of_month, day_of_week_text, fill = metric)) +
    geom_tile() +
    facet_grid(df$year~df$month) +
    scale_fill_gradient(low = "#99FF99", high = "#006600") +
    labs(x = "Week of Months", y = "Day of Weeks")
}

add_day_text <- function(df) {
  df2 <- df %>% mutate(
    day_of_week_text = case_when (
      day_of_week == 0 ~ "7:Sunday",
      day_of_week == 1 ~ "6:Monday",
      day_of_week == 2 ~ "5:Tuesday",
      day_of_week == 3 ~ "4:Wednesday",
      day_of_week == 4 ~ "3:Thursday",
      day_of_week == 5 ~ "2:Friday",
      day_of_week == 6 ~ "1:Saturday",
    )
  )
}


portfolio_bar <- function(df) {
  ggplot(df, aes(x = reorder(Description, Market.Value), y = Market.Value)) +
    geom_col() +
    coord_flip() +
    scale_x_discrete(label = function(x) stringr::str_trunc(x, 20)) +
    labs(title = "Market Values")
}

portfolio_treemap <- function(df) {
  df$Text <- df$Symbol
  df$Text <-
    paste(df$Text, " ", format(round(
      df$Market.Value / sum(df$Market.Value) * 100, 1
    ), nsmall = 1), "%", sep = "")
  
  ggplot(df, aes(area = Market.Value)) +
    geom_treemap() +
    geom_treemap_text(aes(label = paste(Text)), color = "white")
}


