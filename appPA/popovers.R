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
           content=div(
             "The toggle '...total'/'...rate per 1000'  ",
             br(),
             "is in effect for the nine ", strong("'harm'"),
             "features at the top.",
             br(),
             "but irrelevant for the three ", strong("'information'"),
             "features along the bottom.)",
             h5("If '...total' is selected:"),
             indentMe(
               "Yearly EXCESS harm estimates are totalled ",
               br(),
               "for the selected tract or community."
             ),
             h5("If '...rate per 1000' is selected:"),
             indentMe(
               "Yearly estimates are rescaled to per 1000 people."
             ),
             h6("Special KEYS:"),
             indentMe(
               "Type capital ", strong('H'), " to toggle between histogram and density plot.",
               br(),
               "Type capital ", strong('O'), " for a popup to adjust the outlier quantile:",
               br(),
               indentMe(
                 "Outliers not on the graph are listed on the right side.",
                 br(),
                 "To remove outlier handling, ",
                 br(),
                 "click in 'outlier quantile' box and delete."
               )
             )

           ), trigger='hover'
)


