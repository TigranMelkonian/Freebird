# ui
source("help_functions.R")
ui <-
  dashboardPage(
    skin = "black",
    dashboardHeader(
      title = "Tokenizer"
    ),
    dashboardSidebar(
      sidebarMenu(
        id = "sidebar", # id important for updateTabItems
        menuItem("Home", tabName = "home", icon = icon("home", lib = "font-awesome", "fa-1x")),
        menuItem("Community Links", tabName = "communitylinks", icon = icon("users", lib = "font-awesome", "fa-1x"))
      )
    ),
    dashboardBody(

      #################################################################################################
      #                                       Main Dashbaord Body                                    #
      ###############################################################################################
      tabItems(
        
        ############
        # Home tab#
        ##########
        
        tabItem(
          "home",
          fluidRow(
            #usr URL input text box
            column(
              width = 6, align = "center",
              textInput("urltotokenize", "Insert URL to tokenize", " ")
            ),
            #usr URL input action btn
            column(
              width = 3, align = "center", style = ("padding-top: 25px;"),
              actionButton("tokenizeactionbtn", "Tokenize")
            )
          ),
          #Shortned url output info box
          fluidRow(
            column(
              width = 12, infoBoxOutput("iboxtokenizedurl", width = 7),
              offset = 1, style = ("padding-top: 25px; padding-bottom: 25px")
            )
          )
        ),
        
        #########################
        # community link DF tab#
        #######################
        
        tabItem(
          "communitylinks",
          fluidRow(
            #Community links DF
            column(
              width = 8,
              align = "center",
              dataTableOutput("comunitylinksoutputdf")
            ),
            #Community links DF download btn
            column(
              width = 2, downloadButton("downloadcommunitylinks", "Download")
            ),
            #Community links DF refresh btn
            column(
              width = 2, actionButton("datarefreshbtn", "Refresh", icon = icon("redo", lib = "font-awesome", "fa-1x"))
            )
          )
        )
      )
    )
  )
