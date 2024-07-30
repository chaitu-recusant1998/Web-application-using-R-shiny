server <- function(input, output, session) {
  # parsing data from the uploaded excel ----------------

  # read the uploaded data
  rawData <- reactive({
    req(input$rosterFile$datapath) # wait for a file to be uploaded

    read_excel(input$rosterFile$datapath) # read the file when uploaded
  })

  # get the grades from the uploaded data
  grades <- reactive({
    req(rawData()) # wait for rawData to be initialized

    grades <- rawData()[14:nrow(rawData()),] # create a data.frame of grades from rawData
    colnames(grades) <- as.character(rawData()[13,]) # add appropriate columns names to the data.frame

    grades <- grades[,1:6] # only keep relevant columns
    indexOf9 <- which(str_detect(grades$`Grade Input`, pattern = "9$")) # detect marks with 9 as the last digit e.g 79, 89 etc.
    grades$`Grade Input` <- as.numeric(grades$`Grade Input`) # convert marks to numerical values from characters
    grades$`Grade Input`[indexOf9] <- grades$`Grade Input`[indexOf9] + 1 # rounding up marks with 9 as the last digit

    grades
  })

  # get the academic year from the uploaded data
  academicYear <- reactive({
    req(rawData()) # wait for rawData to be initialized
    str_extract(as.character(rawData()[2,3]), pattern = "[[:digit:]]*\\/[[:digit:]]*")
  })

  # get the module code from the uploaded data
  moduleCode <- reactive({
    req(rawData()) # wait for rawData to be initialized
    paste0(str_extract(as.character(rawData()[3,3]), pattern = "^.{3}"), " ", as.character(rawData()[4,3]))
  })

  # get the module title from the uploaded data
  moduleTitle <- reactive({
    req(rawData()) # wait for rawData to be initialized
    as.character(rawData()[5,3])
  })

  # get the total students from the uploaded data
  totalStudents <- reactive({
    req(grades()) # wait for grades to be initialized
    nrow(grades())
  })

  # get the total absent from the uploaded data
  totalAbsent <- reactive({
    req(grades()) # wait for grades to be initialized
    nrow(grades() %>% filter(is.na(`Grade Input`)))
  })

  # get the average of marks from the uploaded data
  avgMark <- reactive({
    req(grades()) # wait for grades to be initialized
    round(mean(grades()$`Grade Input`, na.rm = T), 2)
  })

  # get the SD of marks from the uploaded data
  stdMark <- reactive({
    req(grades()) # wait for grades to be initialized
    round(sd(grades()$`Grade Input`, na.rm = T), 2)
  })

  # data input fields -----------------
  output$inputFieldsBox <- renderUI({
    box(
      width = 12, title = NULL, status = "primary", solidHeader = FALSE, collapsible = FALSE,
      fluidRow(
        column(
          width = 3,
          textInput(inputId = "academicYear", label = "Acadmic Year:", value = academicYear())
        ),
        column(
          width = 3,
          textInput(inputId = "moduleCode", label = "Module Code:", value = moduleCode())
        ),
        column(
          width = 3,
          textInput(inputId = "moduleTitle", label = "Module Title:", value = moduleTitle())
        ),
        column(
          width = 3,
          selectInput(inputId = "examSession", label = "Exam Session:", choices = month.name, selected = NULL, multiple = FALSE)
        )
      ),
      fluidRow(
        column(
          width = 3,
          numericInput(inputId = "level", label = "Level:", min = 0, max = Inf, value = 1)
        ),
        column(
          width = 3,
          numericInput(inputId = "CATSpoints", label = "CATS Points:", min = 0, max = Inf, value = 20)
        ),
        column(
          width = 3,
          selectInput(inputId = "moduleCoOrdinator", label = "Module Co-ordinator:", choices = coordinators, selected = NULL, multiple = FALSE)
        ),
        column(
          width = 3,
          selectInput(inputId = "semester", label = "Semester:", choices = c("Autumn", "Spring"), selected = NULL, multiple = FALSE)
        )
      )
    )
  })

  assessmentComponents <- dtedit(
    input, output,
    name = 'assessmentComponentsTable',
    thedata = data.frame(
      `Component Name` = c("Datacamp", "Practical Assesment", "Written Assesment"),
      `Percentage` = c(5, 25, 70),
      `Type` = c("Online assessment", "2-hour assessment", "3-hour assessment")
    ),
    show.copy = FALSE,
    datatable.options = list(
      dom = "t",
      pageLength = 10
    )
  )

  output$assessmentComponentsTableBox <- renderUI({
    req(rawData()) # wait for rawData to be initialized
    # create a box UI
    box(
      width = 12, title = "Assesment Components", status = "primary", solidHeader = FALSE, collapsible = FALSE, # styling the box
      uiOutput('assessmentComponentsTable') # show the editable data table here
    )
  })

  output$generateButton <- renderUI({
    req(rawData())
    downloadButton(outputId = "generateReport", label = "Generate Report", class = "btn-success")
  })

  output$generateReport <- downloadHandler(
    filename = "grade_report.pdf", # name of the downloaded file
    # define the content that should be downloaded
    content = function(file) {
      # first get the grades data.frame
      grades <- grades()
      # add a column for each assessment component and calculate marks obtained for each
      for(name in assessmentComponents$thedata$Component.Name) {
        grades <- grades %>% mutate(!!name := (assessmentComponents$thedata$Percentage[assessmentComponents$thedata$Component.Name == name]/100)*`Grade Input`)
      }
      # give the assessment component columns proper name
      assesmentCols <- 7:ncol(grades)
      # add a new column named "Elements Failed"
      grades$`Elements Failed` <- 0
      # check how many components each student has failed
      for(col in assesmentCols) {
        name <- colnames(grades[,col])
        passmark <- (assessmentComponents$thedata$Percentage[assessmentComponents$thedata$Component.Name == name]/2)
        grades$`Elements Failed`[which(grades[,col] < passmark)] <- grades$`Elements Failed`[which(grades[,col] < passmark)] + 1
      }
      # create a new column named "Result"
      grades$Result <- ifelse(grades$`Elements Failed` == 0, "Passed", "Failed")

      # call the render function on the report.Rmd with all the required parameters
      # to generate the pdf report
      render(
        "report.Rmd",
        output_dir = "./",
        output_format = pdf_document(),
        output_file = "grade_report.pdf",
        # supplying the necessary parameters as a named list
        params = list(
          grades = grades,
          assesmentComponents = assessmentComponents$thedata,
          academicYear = academicYear(),
          moduleCode = moduleCode(),
          moduleTitle = moduleTitle(),
          totalStudents = totalStudents(),
          totalAbsent = totalAbsent(),
          avgMark = avgMark(),
          stdMark = stdMark(),
          examSession = input$examSession,
          level = input$level,
          CATSpoints = input$CATSpoints,
          moduleCoOrdinator = input$moduleCoOrdinator,
          semester = input$semester
        )
      )

      file.copy("./grade_report.pdf", file)
    }
  )
}
