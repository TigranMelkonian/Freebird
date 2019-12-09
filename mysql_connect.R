# File to connect to local SQL Server


# Create an ephemeral in-memory RSQLite database
# & Connect to local MYSQLite DB 'rshinyappdata'
conn <- dbConnect(SQLite(), ":memory:")


# Connect to local MYSQLite DB 'rshinyappdata'
table_exists <- tryCatch({dbGetQuery(conn, "select 1 from tokenizedurl limit 1;")}, error = function(cond) {return(FALSE)})
if (table_exists != FALSE){
  next #R's version of continue
}else{
  dbSendStatement(conn, paste0("create table tokenizedurl (
            tokenizedurlid integer primary key autoincrement,
                               original_url varchar(255),
                               tokenized_url varchar(255),
                               created_date datetime);"))
}

# Expects: Data frame to push to DB and a DB table_name that already exists in SQLite DB 
#          and a MYSQLite conn
# Does: Inserts data to existing table one row at a time
# Returns: NA
insert_to_db_table <- function(db = conn, data, table_name = 'tokenizedurl') {
  for (i in 1:nrow(data)) {
    # Construct the update query by looping over the data fields
    query <- sprintf(
      'INSERT INTO %s (%s) VALUES ("%s");',
      table_name,
      paste(colnames(data), collapse = ", "),
      apply(data[i, ], 1, paste, collapse = '", "')
    )
    # Submit the update query
    dbGetQuery(db, query)
  }
}


# Expects: User input for original_url string and a MYSQLite conn
# Does: Inserts data to existing table one row at a time
# Returns: Boolean value determining the existence of user input original url in MYSQLite DB
url_exists_db <- function(db = conn, original_url) {
  query <- paste0("select tokenizedurlid from tokenizedurl where original_url = ", '"', original_url, '";')
  tokenizedurlid <- dbGetQuery(db, query)

  if (!is.na(tokenizedurlid$tokenizedurlid[1])) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}


# Expects: Data frameto push to DB and a DB table_name that already exists in SQLite DB and a MYSQLite conn
# Does: Retrieves tokenized url using users original url (Dependent on url_exists_db function)
# Returns: String of matched shortned url
get_tokenized_url <- function(db = conn, original_url) {
  query <- paste0("select tokenized_url from tokenizedurl where original_url = ", '"', original_url, '";')
  tokenizedurl <- as.character(dbGetQuery(db, query))
  return(tokenizedurl)
}


# Expects: Data frameto push to DB and a DB table_name that already exists in SQLite DB and a MYSQLite conn
# Does: Inserts data to existing table one row at a time
# Returns: Entire 'tokenizedurl' data table including original_url, tokenized_url, and created_date
get_tokenized_url_table <- function(db = conn) {
  query <- paste0("select original_url, tokenized_url, created_date from tokenizedurl")
  tokenizedurltable <- data.frame(dbGetQuery(conn, query))
  return(tokenizedurltable)
}
