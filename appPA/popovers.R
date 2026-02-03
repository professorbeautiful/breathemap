#### popovers using shinyBS

### doesn't work as popify, or with id=IdfeaturePlotforpopover on the div().
addPopover(session = session,
           placement = 'left',
           id='featurePlot',
           title = 'About this histogram:',
           content=div(
             "Histogram of values",
             "If these toggles are chosen: 'communities','...rate per 1000', ",
             "each tract in the community cluster is shown.",
             "Type capital O for a popup to adjust the outlier quantile.",
             p("*All estimates are based on number of cases per 1,000 population annually"),
             p("**Performance IQ is a measure of intelligence related to problem solving skills.")

           ), trigger='hover')

