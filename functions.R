get_id <- function(con, query, value, colname) {
  id <- dbSendQuery(con, query)
  dbBind(id, c(value))
  id <- dbFetch(id)[[colname]]
}


create_heatmap <- function(df) {
  ggplot(df, aes(week_of_month, -day_of_week, fill = sum)) +
    geom_tile() +
    facet_grid(df$year~df$month) +
    scale_fill_gradient(low = "#99FF99", high = "#006600") +
    labs(x = "Week of Months", y = "Day of Weeks")
}