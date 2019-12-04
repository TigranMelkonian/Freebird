#File to connect to Redshift
library(RMySQL)

mysql_credentials <- read.csv(paste0(CREDENTIALS_PATH, '/mysql_credentials.csv'), stringsAsFactors = F)

#Connect to redshift DB
conn <- dbConnect(MySQL(), user = mysql_credentials$user, password = mysql_credentials$password, host = mysql_credentials$host, port = 3306, dbname = mysql_credentials$dbname)
rs <- dbGetQuery(conn, 'set character set utf8')

#Checking the schema you are connected to
selectedDB <- dbGetQuery(conn,"SELECT DATABASE()")
print(paste("You are connected to the Schema: ",selectedDB))

