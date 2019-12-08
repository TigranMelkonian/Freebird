
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
        tabItem(
          "home",
          fluidRow(
            column(
              width = 6, align = "center",
              textInput("urltotokenize", "Insert URL to tokenize", " ")
            ),
            column(
              width = 3, align = "center", style = ("padding-top: 25px;"),
              actionButton("tokenizeactionbtn", "Tokenize")
            )
          ),
          fluidRow(
            column(
              12, infoBoxOutput("iboxtokenizedurl", width = 7),
              offset = 1, style = ("padding-top: 25px; padding-bottom: 25px")
            )
          )
        ),
        tabItem(
          "communitylinks",
          fluidRow(
            column(
              8,
              align = "center",
              dataTableOutput("comunitylinksoutputdf")
            ), 
            column(
              2, downloadButton("downloadcommunitylinks", "Download")),
            column(
              2, actionButton("datarefreshbtn", "Refresh", icon = icon("redo", lib = "font-awesome", "fa-1x")))
          )
        )
      )
    )
  )
