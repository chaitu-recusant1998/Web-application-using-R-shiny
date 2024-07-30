ui <- dashboardPage(
  title = "Module Reports",

  # header section of the dashboard
  header = dashboardHeader(
    title = tags$img(src = "img/Picture1.png"), # show the logo in the title section
    titleWidth = "400px" # make the title section 400 pixels wide
  ),

  sidebar = dashboardSidebar(
    # create the sidebar navigation menu
    sidebarMenu(
      id = "sidebar",
      # adding the Generate Report tab to the sidebar navigation menu
      menuItem(
        text = "Generate Report", # the text that shows up in the navigation menu
        tabName = "generateReport" # the unique identifier for this tab
      )
    ),
    width = "400px"
  ),

  body = dashboardBody(
    # adding custom CSS styles to make adjustments to the header section
    # to show the logo properly
    tags$style("
               .main-header {min-height: 80px;}
               .main-header .logo {min-height: 80px;}
               .navbar {min-height: 80px}
               .main-sidebar {padding-top: 80px !important}
               .logo img {height: 80px}
               .sidebar-toggle {line-height: 50px; font-size: large}
               "),
    add_busy_bar(), # add busy indicator add the top of the app
    # start defining contents for tabs
    tabItems(
      # contents for generate report tab
      tabItem(
        tabName = "generateReport",
        # create a row and column layout
        fluidRow(
          column(
            offset = 3, width = 6,
            # creating a box UI element
            box(
              width = 12, title = "Upload Data", solidHeader = TRUE, collapsible = FALSE, status = "primary", # styling the box
              fileInput(inputId = "rosterFile", label = NULL) # creating a file input
            )
          )
        ),
        withSpinner(uiOutput("inputFieldsBox"), type = 8), # show the "inputFieldBox" which is dynamically created in the server server section
        withSpinner(uiOutput("assessmentComponentsTableBox"), type = 8), # show the "assessmentComponentsTableBox" which is dynamically created in the server server section
        div(
          uiOutput("generateButton"), # show the "generateButton" which is dynamically created in the server server section
          style = "text-align: center;" # centering the button in the screen
        )
      )
    )
  )
)
