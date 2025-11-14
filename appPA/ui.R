fluidPage({

  mainPanel(width = 12,
            shinyDebuggingPanel::withDebuggingPanel(),
            tags$head(
              # style tags used throughout app
              tags$style(type="text/css",
                          "a{
                            color:#8a100b;
                            background-color:transparent;
                          }
                          .nav li a:focus, .nav li a:hover {
                            color: #FFF;
                            background-color: #8a100b
                          }
                          .nav > li > a:focus, .nav > li >a:hover {
                            color: #FFF;
                            text-decoration: underline;
                            background-color: #8a100b
                          }
                          .container-fluid{
                            min-width:400px;
                          }
                          div.datatables{
                            min-width:182px;
                          }
                          #downloadData{
                            color:#FFFFFF;
                            background-color:#b29d6c;
                            font-weight:bold;
                          }
                          #town{
                            background-color:#b29d6c;
                            width:320px;
                          }
                          .leaflet-top.leaflet-left{
                            z-index: 250;
                          }
                          .form-group.shiny-input-container{
                            margin:auto;
                            text-align:center;
                            display: inherit;
                          }
                          .col-sm-7 .form-group.shiny-input-container{
                            display: table-row;
                          }
                         @media only screen and (max-width: 700px) {
                            #comptable{
                              display:none;
                            }
                         }"
              )
            ),
            # all ui components, layout, and element ordering for whole app
            tabsetPanel(
              tabPanel("Map Tool",
                fluidRow(
                  column(7, selectInput("town", "Select a town by clicking it or typing it in here: ",
                                        PAtownnames,
                                        selected = PAtownnames[1]),
                  leafletOutput("map", height = 450), br(),
                          fluidRow(
                            column(width=8, p("Note you can zoom in and out by scrolling over the map or using the buttons in the top left. You can also move around by clicking and dragging.")),
                            column(width = 2, offset = 0.5, downloadButton("downloadData", "Export Data"), br(), br()))),
                  column(5, dataTableOutput("tabledemog"),
                         dataTableOutput("tableest"), br(),
                         textOutput("hotext"), br(),
                         p("**Performance IQ is a measure of intelligence related to problem solving skills.")))),
              tabPanel("Comparison Tool",
                fluidRow(
                  column(6, selectInput("townleft", "Select a town to analyze: ", PAtownnames, selected = "Abington")),
                  column(6, selectInput("townright", "Select a town to compare against: ", PAtownnames, selected = "Acton"))),
                fluidRow(
                  column(6, dataTableOutput("tabledemogleft"), class="col-xs-6"),
                  column(6, dataTableOutput("tabledemogright"), class="col-xs-6")),
                fluidRow(
                  column(6, dataTableOutput("tablepoprateleft"), dataTableOutput("tableIQleft"), class="col-xs-6"),
                  column(6, dataTableOutput("tablepoprateright"), dataTableOutput("tableIQright"), class="col-xs-6")),
                fluidRow(
                  column(12, plotOutput("comptable", height=300), br(),
                        p("*All estimates are based on number of cases per 1,000 population annually"),
                        p("**Performance IQ is a measure of intelligence related to problem solving skills."),
                        br())
                ))))
})


