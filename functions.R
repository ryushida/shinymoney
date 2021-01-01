get_id <- function(con, query, value, colname) {
  id <- dbSendQuery(con, query)
  dbBind(id, c(value))
  id <- dbFetch(id)[[colname]]
}