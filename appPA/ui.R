breatheLabelColoring = 'background-color:#75C443; color:white'
#breatheLabelColoring = 'background-color:green; color:white'

fluidPage({

  mainPanel(width = 12,
            # tags$head(
            #   tags$style(HTML(css.radio))
            # ),
            tags$head(
              includeScript('KeyHandler.js'),
              # includeScript('navigateToId.js'),   ### ESCAPE key to return.
              singleton(tags$head(tags$script(src = "pop_patch.js"))),
              #uiOutput('JSstopPopups'),
              tags$style(".popover{max-width: 100%; font-size:10px; color:blue}"),
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
            shinyDebuggingPanel::withDebuggingPanel(),

            # all ui components, layout, and element ordering for whole app
            # tabsetPanel(
            #   tabPanel("Map Tool",
            fluidRow(
              column(7,
                     fluidRow(
                       column(5,
                              div(style=breatheLabelColoring,
                                  popify(placement = 'right', title = 'Communities and Census Tracts',
                                         content = 'To search for an area: <br>click the box, press "delete" <br> and type your search string. ',
                                         el =
                                           selectInput("areaSelectorId", 'Communities and Census Tracts',
                                                       twt$areaField,
                                                       selected = twt$areaField[1])))),
                       column(4,

                              div(style=breatheLabelColoring,
                                  popify(title='Areas shown:',
                                         content=HTML(paste('"tracts":  <br>_____Show one tract.<hr>',
                                                            '"communities":',
                                                            ' <br>_____You pick one community in this tract,<br>',
                                                            ' and we show tracts for that community',
                                                            ' <hr>See "Community shares" checkbox for details'
                                         ) ),
                                         radioButtons("Id_ToggleTownTract", "Areas shown:",
                                                      choiceNames=c('communities', 'tracts'),
                                                      choiceValues=c('towns', 'twt'),
                                                      selected='twt')
                                  )
                              )),
                       column(3,
                              div(style=breatheLabelColoring,
                                  popify(title='Pittsburgh Neighborhood toggle',
                                         content='When "community" is selected, <br>should Pittsburgh be seen <br>as one "community", <br>or each neighborhood as an individual "community"?',

                                         checkboxInput('IdNbhds', 'See each Pgh nbhd?'
                                                       ,value = TRUE)
                                  ),
                                  popify(title='Selecting one community in a tract:',
                                         content=
                                           div(style='font-size:6px !important; container:body !important',
                                               HTML('With "Community shares?" = YES<br>  ____ show ALL tracts that include this community.<hr>With "Community shares?" = NO<br>   ____ show ONLY tracts where this is the only community.'
                                               )),
                                         checkboxInput("Id_townSharesCheckbox",
                                                       "Community shares?",value = TRUE)
                                  )
                              ))
                     ),
                     leafletOutput("map", height = 450),
                     br(),
                     fluidRow(#style='background:#75C443',  #  final rhs
                       column(width=4,
                              #div(
                              actionButton('IdAck', label='Acknowledgments',
                                           style=breatheLabelColoring)
                       ),
                       column(width=4,
                              actionButton(inputId='IdMapAdvice',
                                           style=breatheLabelColoring,
                                           label = 'Navigating the map')
                       ),
                       column(width = 2, offset = 0.5,
                              downloadButton("downloadData", "Export Data",
                                             style=breatheLabelColoring)
                       )
                     ) #fluidRow
              ), #  final rhs
              column(5,
                     div(style=paste(breatheLabelColoring, ';text-align:center'),
                         strong("Harm that excess PM2.5 did in this tract or community...")),
                     uiOutput('communityShown'),
                     fluidRow(
                       column(12, radioButtons(inputId='idFeature',
                                               label=NULL,
                                               choices=featureList,
                                               selected=featureList[1],
                                               inline=TRUE)
                       )),
                     uiOutput('UITotalOrRates'),
                     uiOutput('histTitle'),
                     fluidRow(
                       column(12, plotOutput(outputId="featurePlot",
                                             height=300)
                              # p("*All estimates are based on number of cases per 1,000 population annually"),
                              # p("**Performance IQ is a measure of intelligence related to problem solving skills."),
                       )
                     ),
                     uiOutput('IdUiForReferenceCommunity'),
                     div(style=breatheLabelColoring,
                         strong("Show information about this tract or community")),
                     span(style='font-size:9px',
                          actionButton('IdShowPM2.5',
                                       label=' PM2.5 avg in 2016'),
                          actionButton('IdShowPop', label='Total # of people'),
                          actionButton('IdShowCohort', label='# in the 2019 birth cohort')
                     )
              ))
            # ,
            #     fluidRow(
            #       #dataTableOutput("tabledemog"),
            #       dataTableOutput("tableest"), br(),
            #       textOutput("hotext"), br(),
            #       p("**Performance IQ is a measure of intelligence related to problem solving skills."))
  )

})


