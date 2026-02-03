#### popovers using shinyBS

### doesn't work as popify, or with id=IdfeaturePlotforpopover on the div().
indentMe = function(...)
  fluidRow(column(12, offset=1,
                  ...)
  )
addPopover(session = session,
           placement = 'left',
           id='featurePlot',
           title = 'About this graph:',
           content=div( style= 'width: 120% !important;',
             "NOTE: ",
             br(),
             "The values plotted are for all ", strong("TRACTS"), "not communities.",
             br(),
             br(),
             indentMe(
             "The toggle '...total'/'...rate per 1000'  ",
             br(),
             "is in effect for the nine ", strong("'harm'"),
             "features at the top.",
             br(),
             "but irrelevant for the three ",
             br(),
             strong("'information'"),
             "features along the bottom.)"
             ),
             h5("If '...total' is selected:"),
             indentMe(
               "Yearly EXCESS harm estimates are totalled ",
               br(),
               "for the selected tract or community.",
               br(),
               "If 'communities/tracts' is set to 'communities',",
               br(),
               "this total is the sum",
               br(),
               "across the communities currently selected."
             ),
             h5("If '...rate per 1000' is selected:"),
             indentMe(
               "Yearly estimates are rescaled to per 1000 people.",
               br(),
               "If 'communities/tracts' is set to 'communities',",
               br(),
               "this is the rate combined ",
               br(),
               "across the communities currently selected."

             ),
             h6("Special KEYS:"),
             indentMe(
               "Type capital ", strong('H'), " to toggle between ",
               br(), "histogram and density plot.",
               br(),
               "Type capital ", strong('O'), " for a popover to adjust the outlier quantile:",
               br(),
               indentMe(
                 "Outliers not on the graph ",
                 br(),
                 "are listed on the right side of the graph,",
                 br(),
                 " and in this  ", strong('O'), " quantile popover",
                 br(),
                 "To remove outlier handling, ",
                 br(),
                 "click in 'outlier quantile' box and delete."

               )
             ),
             HTML(paste(rep('-', 50)) )
           ), trigger='hover'
)


