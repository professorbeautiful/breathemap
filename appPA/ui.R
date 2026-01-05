fluidPage({

  mainPanel(width = 12,
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
                           column(7,
                                  div(style='color:yellow; background-color:green',
                                      popify(placement = 'right', title = 'Towns and Census Tracts',
                                             content = 'To search for an area: <br>click the box, press "delete" <br> and type your search string. ',
                                             el =
                                               selectInput("areaSelectorId", 'Towns and Census Tracts',
                                                           twt$areaField,
                                                           selected = twt$areaField[1])))),
                           column(2,

                                    div(style='color:yellow; background-color:green',
                                        popify(title='Area shown:',
                                               content=paste('If "towns" is selected,<br>',
                                                             'and "Town shares" is checked, <br>',
                                                             'then if there is more than one town in this tract,',
                                                             '<br> you pick a town,<br> ',
                                                             'then we show all tracts  intersecting with that town.'
                                               ),
                                               radioButtons("townToggleId", "Area shown:",
                                                   choiceNames=c('towns ', 'tracts'),
                                                   choiceValues=c('towns', 'twt'),
                                                   selected='twt')
                                             )
                                  )),
                           column(3,
                                  div(style='color:yellow; background-color:green',
                                      popify(title='Pittsburgh Neighborhood toggle',
                                             content='When "town" is selected, <br>should Pittsburgh be seen <br>as one "town", <br>or as separate neighborhoods?',

                                             checkboxInput('IdNbhds', 'See each Pgh nbhd?'
                                                           ,value = TRUE)
                                      ),
                                      popify(title='Selecting one town in a tract:',
                                             content=
                                                div(style='font-size:6px !important; container:body !important',
                                                HTML('With Town shares? = YES<br>  ____ show all tracts that include this town.<hr>With Town shares? = NO<br>   ____ show only tracts where this is the only town.'
                                               )),
                                               checkboxInput("townSharedToggleId",
                                                    "Town shares?",value = TRUE)
                                      )
                                      ))
                         ),
                         leafletOutput("map", height = 450),
                         br(),
                         fluidRow(#style='background:green',  #  final rhs
                           column(width=4,
                                  #div(
                                    actionButton('IdAck', label='Acknowledgments',
                                                 style='background-color:green; color:yellow')
                           ),
                           column(width=4,
                                  actionButton(inputId='IdMapAdvice',
                                               style='background-color:green; color:yellow',
                                               label = 'Navigating the map')
                           ),
                           column(width = 2, offset = 0.5,
                                  downloadButton("downloadData", "Export Data",
                                                 style='background-color:green; color:yellow')
                           )
                         ) #fluidRow
                  ), #  final rhs
                  column(5,
                         div(style='color:yellow; background-color:green',
                             strong("Select a feature to show:")),
                       fluidRow(
                         column(12, radioButtons(inputId='idFeature',
                                                   label=' ',
                                                   choices=featureList,
                                                 selected=featureList[1],
                                                 inline=TRUE)
                         )),
                       uiOutput('histTitle'),
                       fluidRow(
                         column(12, plotOutput(outputId="featurePlot",
                                               height=300)
                        #                  p("*All estimates are based on number of cases per 1,000 population annually"),
                        # p("**Performance IQ is a measure of intelligence related to problem solving skills."),
                        )
                )))
            # ,
            #     fluidRow(
            #       #dataTableOutput("tabledemog"),
            #       dataTableOutput("tableest"), br(),
            #       textOutput("hotext"), br(),
            #       p("**Performance IQ is a measure of intelligence related to problem solving skills."))
            )

})


