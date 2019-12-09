# Server

server <- function(input, output, session) {
  
  
  #Shortned url output infobox
  output$iboxtokenizedurl <- renderInfoBox({
    if (tokenized_url() == "Example URL: http://bit.ly/38gMBMq" | tokenized_url() == "Please enter a valid URL!") {
      infoBox(
        title = tags$b(style = "font-size: 16px;", "Tokenized URL"), tags$p(style = "font-size: 26px;opacity: .5", tokenized_url()), icon = icon("list"),
        color = "black"
      )
    } else {
      infoBox(
        title = tags$b(style = "font-size: 16px;", "Tokenized URL"), tags$p(style = "font-size: 26px;", tokenized_url()), icon = icon("list"),
        color = "black"
      )
    }
  })

  
  #Community links DF output
  output$comunitylinksoutputdf <- renderDataTable({
    datatable(community_tokenized_urls(),
      options = list(
        paging = FALSE, scrollX = T, searching = TRUE, bInfo = FALSE,
        class = "cell-border hover compact",
        pageLength = 10000
      )
    )
  })

  
  #Community links DF download handler
  output$downloadcommunitylinks <- downloadHandler(
    filename = function() {
      paste0("community_links_", Sys.Date(), ".csv")
    },
    content = function(file) {
      data <- (community_tokenized_urls() %>%
        select("created_date", "original_url", "tokenized_url") %>%
        arrange(desc(created_date)))

      write.csv(data,
        file,
        row.names = F
      )
    }
  )
  
  #################################################################################################
  #                                       REACTIVE DATA UPDATE ELEMENTS                          #
  ###############################################################################################
  
  # Reactive expressions are smarter than regular R functions.
  # They cache their values and know when their values have become outdated.
  
  #Community links DF
  community_tokenized_urls <- eventReactive(input$datarefreshbtn, {
    tokenized_url_table <- get_tokenized_url_table()
    return(tokenized_url_table)
  }, ignoreNULL = FALSE)


  #Shortened URL infobox output
  tokenized_url <- eventReactive({
    input$tokenizeactionbtn
  }, {
    if (input$urltotokenize == "" | input$urltotokenize == " ") {
      output <- "Example URL: http://bit.ly/38gMBMq"
    } else {
      usr_input <- trimws(input$urltotokenize)
      updateTextInput(session, "urltotokenize", value = " ")
      exists_in_db <- url_exists_db(original_url = usr_input)
      valid <- is_valid_url_input(usr_input)
      if (!exists_in_db & valid) {
        output <- generate_shortened_url(original_url = usr_input)
        url_token_match_df <- data.frame(cbind(original_url = usr_input, tokenized_url = output, created_date = as.character(Sys.time())))
        insert_to_db_table(data = url_token_match_df, table_name = "tokenizedurl")
      } else if (exists_in_db) {
        output <- get_tokenized_url(original_url = usr_input)
      } else if (!valid) {
        output <- "Please enter a valid URL!"
      } else {
        output <- " "
      }
      return(output)
    }
  })
}
