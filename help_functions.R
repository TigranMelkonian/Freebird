library(DT)
library(DBI)
library(httr)
library(shiny)
library(dplyr)
library(RSQLite)
library(devtools)
library(shinyWidgets)
library(shinydashboard)
CREDENTIALS_PATH <- paste0(getwd(), "/credentials/")
bitly_access_token <- read.csv(paste0(CREDENTIALS_PATH, "bitly_access_token.csv"), stringsAsFactors = F)
source("mysql_connect.R")
source("global.R")


#web app help function file
# Expects: bitly API authorization key & secret key
# Does: Establish authentication for accessing bitly API
#       & caches oauth access token in sys enviroment
# Returns: NA

url_shortner_auth <- function(key, secret, method = "bitly") {
  if (method == "bitly") {
    oauth_token <- oauth2.0_token(oauth_endpoint(
      authorize = "https://bitly.com/oauth/authorize",
      access = "https://api-ssl.bitly.com/oauth/access_token"
    ),
    oauth_app("bitly", key = key, secret = secret),
    cache = TRUE
    )
  }
  else {
    stop("Method '", method, "' not yet implemented!")
  }
  
  assign("oauth_token", oauth_token, envir = oauth_cache)
}

#call function above to establish authentication for accessing bitly API
url_shortner_auth(bitly_access_token$client_id, bitly_access_token$client_secret_id, method = "bitly")


# Expects: Original string url to shorten
# Does: Makes GET request to bitly API to retrieve shortned url
# Returns: Shortened url string
generate_shortened_url <- function(original_url, oauth = oauth_cache) {
  token <- get("oauth_token", envir = oauth)
  result <- GET("https://api-ssl.bit.ly/v3/shorten",
    query = list(
      access_token =
        token$credentials$access_token,
      longUrl = original_url
    )
  )
  if (result$status_code == 200) {
    shortened_url <- content(result)$data$url
  } else {
    shortened_url <- "Sorry, we have reached the token generation limit for today."
  }

  return(shortened_url)
}


# Expects: Original string url to validate
# Does: Converts url string to its domain then pings url
#       domain to determine if url is valid
# Returns: Boolean value depending on url validity
is_valid_url_input <- function(url) {
  is_valid <- tryCatch({
    pingr::ping_port(urltools::domain(url), port = 80, count = 1)
  }, error = function(cond) {
    return(FALSE)
  })
  if (is_valid != FALSE) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}


# Expects: NA
# Does: To run after any final updates were made to this Shiny App 
#       so that updates are reflected on version hosted on shiny.io server
# Returns: NA
update_shinyio <- function() {
  rsconnect::deployApp(paste0(getwd()))
}
