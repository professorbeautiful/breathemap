# source('www/indentMe.R')
content_FeaturePlot_Information =
  div( style= 'width: 120% !important;',
h5('This graph:'),
       "The histogram values plotted are for all ", strong("TRACTS"), "not communities.",
       br(),
       "(Type capital ", strong('H'), " to toggle between ",
       "histogram and density plot.)",
       br(),
       "A vertical arrow shows the value of the feature for the selected tract or community.",

       br(),
       br(),
       h5('Multiple tracts:'),
      "When 'communities' is selected, there may be multiple tracts for the community.",
      br(),
      "If so, the  value for each tract is shown as a half-height green line.",
      br(),
      br(),
      "If '...total' is selected, then the tract results are combined by adding.
      <br>
In that case, the total is written along the top of the graph,
<br>
with the number of tracts contributing.
<br>
The total might be larger than the right hand side of the feature axis.
<br>
This is indicated by a horizontal green arrow reaching to the right hand side.
",
      br(),      br(),

       h5("Outlier handling:"),
       # indentMe(

         "When '...total' is selected and 'communities' is selected,",
         br(),
         "Outliers not on the graph ",
         br(),
         "are listed on the right side of the graph,",
         br(),
         " and in a quantile popover",
         br(),
         "To remove outlier handling, ",
         br(),
         "click in 'outlier quantile' box and delete."
       # )
,
       h5("Special KEYS for the outlier handling:"),
       # indentMe(
         "Type  ", strong('9'), " for a popover to open the outlier quantile dialog",
         br(),  ' while setting the outlier quantile to 0.999. ',
         br(),
         "Type capital ", strong('O'), " for a popover to open the outlier quantile dialog",
         br(),  ' while setting the outlier quantile (no  outlier handling). ',
         br()

       #)
       #  ,      HTML(paste(rep('-', 50)) )  NEEDED only if popover on the left.
  )
