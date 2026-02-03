#### popovers using shinyBS
# [1] "areaSelectorId" "townToggleId" "idFeature"
# [4] "IdNbhds" "townSharedToggleId" "map_bounds"
# [7] "map_center" "map_zoom" "evalButtonR"
# [10] "evalButtonJS" "id_languageChoice" "traceCheckbox"
# [13] "prependOutputPreambleToggle" "prependInputPreambleToggle" "idRlineNum"
# [16] "idJSlineNum" "evalStringR" "evalStringJS"
# [19] "map_groups" "map_shape_mouseover" "map_shape_mouseout"
# [22] "ctrlDpressed" "savedYposition" "Latestkeypressedx"
# [25] "Latestkeypressede"
addPopover(session = session,
           placement = 'left',
           id='IdfeaturePlotforpopover',

           title = 'About this histogram:',
           content=div(
             "Histogram of values",
             "If these toggles are chosen: 'communities','...rate per 1000', ",
             "each tract in the community cluster is shown.",
             "Type capital O for a popup to adjust the outlier quantile.",
             p("*All estimates are based on number of cases per 1,000 population annually"),
             p("**Performance IQ is a measure of intelligence related to problem solving skills.")

           ), trigger='hover')
