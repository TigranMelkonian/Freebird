#File to connect to Redshift
CREDENTIALS_PATH <- paste0(getwd(), '/credentials/')
library(RMySQL)


mysql_credentials <- read.csv(paste0(CREDENTIALS_PATH, 'mysql_credentials.csv'), stringsAsFactors = F)

#Connect to redshift DB
conn <- dbConnect(MySQL(), user = mysql_credentials$user, password = mysql_credentials$password, host = mysql_credentials$host, port = mysql_credentials$port, dbname = mysql_credentials$dbname)
rs <- dbGetQuery(conn, 'set character set utf8')

#Checking the schema you are connected to
selectedDB <- dbGetQuery(conn,"SELECT DATABASE()")
print(paste("You are connected to the Schema: ",selectedDB))


#Expects: Data frameto push to DB and a DB table_name that already exists in local DB
#DOes: Inserts data to existing table one row at a time
#Returns: NA
update_db_table <- function(db = conn, data, table_name) {
  
 for (i in 1:nrow(data)){
  # Construct the update query by looping over the data fields
    query <- sprintf(
      "INSERT INTO %s (%s) VALUES ('%s');",
      table_name, 
      paste(colnames(data), collapse = ", "),
      apply(data[i,], 1, paste, collapse="', '")
    )
  # Submit the update query
  dbGetQuery(conn, query)
 }
}
