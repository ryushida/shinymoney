library(tidyverse)

get_id <- function(con, query, value, colname) {
  id <- dbSendQuery(con, query)
  dbBind(id, c(value))
  id <- dbFetch(id)[[colname]]
}


create_heatmap <- function(df) {
  ggplot(add_day_text(df), aes(week_of_month, day_of_week_text, fill = sum)) +
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
