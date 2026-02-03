source('coloring.R')

# margin and height do not help.
#breatheLabelColoring = 'background-color:green; color:white'

fluidPage(
  useKeys(),
  keysInput("keys", c("O", "H", "B")),
  {
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
                       column(3,

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
                       column(4,
                              div(style=breatheLabelColoring,
                                  popify(title='Pittsburgh Neighborhood toggle',
                                         content='When "community" is selected, <br>should Pittsburgh be seen <br>as one "community", <br>or each neighborhood as an individual "community"?',

                                         checkboxInput('IdNbhds',
                                                       'Individual Pittsburgh neighborhoods?'
                                                       #'See each Pgh nbhd?'
                                                       ,value = TRUE)
                                  ),
                                  popify(title='Selecting one community in a tract:',
                                         content=
                                           div(style='font-size:6px !important; container:body !important',
                                               HTML('With "Community can overlap?" = YES<br>  ____ show ALL tracts that include this community.<hr>With "Community can overlap?" = NO<br>   ____ show ONLY tracts where this is the only community.'
                                               )),
                                         checkboxInput("Id_townSharesCheckbox",
                                                       'Community can overlap?'
                                                       #"Community shares?"
                                                       ,value = TRUE)
                                  )
                              ))
                     ),
                     leafletOutput("map", height = 450),
                     br(),
                     fluidRow(
                       column(width=4,
                              #div(
                              actionButton('IdAck', label='Acknowledgments',
                                           style=leftSideButtonStyle)
                       ),
                       column(width=4,
                              actionButton(inputId='IdMapAdvice',
                                           style=leftSideButtonStyle,
                                           label = 'Navigating the map')
                       ),
                       column(width = 2, offset = 0.5,
                              downloadButton("downloadData", "Export Data",
                                             style=leftSideButtonStyle)
                       )
                     ) #fluidRow
              ), #  left half
              column(5,
                     div(style=paste(breatheLabelColoring, ';text-align:center'),
                         strong("Harm that excess PM2.5 did in this tract or community...")),
                     uiOutput('communityShown'),
                     fluidRow(
                       column(12, uiOutput('uiFeatureList')
                       )),
                     uiOutput('UITotalOrRates'),
                     uiOutput('histTitle'),
                     fluidRow(
                       column(12,
                              div(  ### this div does not help! but popover works now.
                                id='IdfeaturePlotforpopover',
                                  plotOutput(outputId="featurePlot",
                                             height=300)
                              )

                       )
                     ),
                     fluidRow(column(offset=1, 11, uiOutput('IdUiForReferenceCommunity'))),
                     div(style=paste(breatheLabelColoring, ';text-align:center'),
                         strong("Show information about this tract or community")),
                     div(style='text-align: center; margin:auto',
                          actionButton(style=rightSideButtonStyle,
                                       'IdShowPM2.5',
                                       label=' PM2.5 avg in 2016'),
                           actionButton(style=rightSideButtonStyle,
                                        'IdShowPop', label='Total # of people'),
                          actionButton(style=rightSideButtonStyle,
                                       'IdShowCohort', label='# in the 2019 birth cohort')
                     )
              )  # end of right side
            )  # end of the entire page, in one Fluidrow
    )  # end of mainPanel
})


