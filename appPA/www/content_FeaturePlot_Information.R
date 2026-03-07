source('indentMe.R')
content_FeaturePlot_Information =
  div( style= 'width: 120% !important;',
       "NOTE: ",
       br(),
       "The values plotted are for all ", strong("TRACTS"), "not communities.",
       br(),
       br(),

       h6("Outlier handling:"),
       indentMe(

         "When '...total' is selected and 'communities' is selected,
         Outliers not on the graph ",
         br(),
         "are listed on the right side of the graph,",
         br(),
         " and in a quantile popover",
         br(),
         "To remove outlier handling, ",
         br(),
         "click in 'outlier quantile' box and delete."
       ),
       h6("Special KEYS for the outlier handling:"),
       indentMe(
         "Type  ", strong('9'), " for a popover to open the outlier quantile dialog",
         br(),  ' while setting the outlier quantile to 0.999. ',
         br(),
         "Type capital ", strong('O'), " for a popover to open the outlier quantile dialog",
         br(),  ' while setting the outlier quantile (no  outlier handling). ',
         br()

         ,
         "Type capital ", strong('H'), " to toggle between ",
         "histogram and density plot.",
       )
       #  ,      HTML(paste(rep('-', 50)) )  NEEDED only if popover on the left.
  )
