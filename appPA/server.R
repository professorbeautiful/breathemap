function(input, output, session) {
  includeScript('www/KeyHandler.js')
  observeEvent(input$ctrlDpressed, {}) # just to flush the ctrl-D press.
  shinyDebuggingPanel::makeDebuggingPanelOutput(
       session, toolsInitialState = FALSE,
       condition='ctrlDpressed === true'
      )


    # to speed app up and lower RAM
  #townreac <- reactive(PAtown[PAtown$NAME==input$areaSelectorId,])
  # townreac <- reactive({
  #   areaFieldName = get_areaFieldName()
  #   print(paste('townreac: get_areaFieldName = ', areaFieldName))
  #   result = PAtown[which(PAtown[[areaFieldName]]==TARGETstring()),]
  #   if(nrow(result) > 1) {
  #     cat('==== townreac   --  duplicates ===== \n')
  #     print(result)
  #     result = result[result$COUNTYFP == '003', ]  ### select Allegheny
  #     print(result)
  #   }
  #   result   ###  it should return one row of PAtown.
  #   })
  #needs Town, lat, lon

  # This is ok, because only used for centering map at the start.
  medianLON= median(as.numeric(twt$lon.tracts), na.rm=T)
  medianLAT= median(as.numeric(twt$lat.tracts), na.rm=T)


 # clicking updates selectInput
  observe({
    click <- input$map_shape_click
    ### TODO  Seems ok but keep an eye on this.
    if(is.null(click))
      #updateSelectInput(session, "areaSelectorId", selected = PAtown[['areaField']] [1])
      updateSelectInput(session, "areaSelectorId", selected = twt[['areaField']] [1])
    else
      updateSelectInput(session, "areaSelectorId", selected = click$id)
  })

  areaFieldName = 'twt'  ## towns with tracts

  get_areaFieldName = reactive({
    if(length(input$townToggleId) == 1)
      areaFieldName = input$townToggleId
    else
      areaFieldName = 'twt'
    print(paste('get_areaFieldName: areaFieldName=', (areaFieldName)))
    twt[['areaField']] <<-twt[[areaFieldName]]
    return(areaFieldName)   ## get_areaFieldName
    # updateSelectInput(session, "areaSelectorId", choices = PAtown)
  })
 # leaflet map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.PositronNoLabels", options = tileOptions(minZoom = 5, maxZoom = 13)) %>%
      setView(lng = medianLON, lat = medianLAT, zoom = 7)  %>%
      addPolygons(data = twt,
                  weight = 1,
                  color = "Black",
                  fillColor = "blue",
                  fillOpacity = 0.3,
                  # label is the label shown
                  #label = ~areaField, #works ok. PAtown[['NAME']] = PAtown[['areaField']]
                  label = ~twt,
                  layerId = ~twt, ## initially.
                  highlight = highlightOptions(
                    fillColor = "green",
                    color = "red",
                    weight = 2,
                    fillOpacity = 1,
                    bringToFront = T))
  })
  TARGETstring = reactive({
    TARGETstring = (input$areaSelectorId)
    areaFieldName = get_areaFieldName()
    if(areaFieldName == 'towns')
      TARGETstring = twt$towns[match(TARGETstring, twt$twt)]
      # print(paste('TARGETstring (in):', TARGETstring))
    print(paste('TARGET (out):', TARGETstring))
    TARGETstring
  })
  TARGETrownumbers = reactive({
    print(paste('TARGETrownumbers:',
                TARGETstring() , ' in areaField ', get_areaFieldName()
                ))
    #which(PAtown[['areaField']] == TARGETstring())
    rownumbers = which(twt[['areaField']] == TARGETstring())
    print(paste('TARGETrownumbers: ', paste(collapse=' ', rownumbers)))
    return(rownumbers)
  })
  TARGETdatarows = reactive({
    twt[TARGETrownumbers(), ]
  })

  ##### mapObserver:  leafletProxy: Map animation  ####
  mapObserver = observeEvent(c(input$townToggleId, input$areaSelectorId), {

    print(paste('mapObserver: input$areaSelectorId', input$areaSelectorId) )
    print(paste('mapObserver: input$townToggleId', input$townToggleId) )
    print(paste('mapObserver: TARGETstring', TARGETstring() ) )

    areaRowNumbers = TARGETrownumbers()

    print(paste('mapObserver: areaRowNumbers', paste(collapse=',', areaRowNumbers)))
    #townRowNumber = which(PAtown$NAME==TARGETdatarows()$NAME) [1]  # [1] for now.
  #### leafletProxy ####
    leafletProxy("map", session) %>%
      flyTo(lng = TARGETdatarows()$lon.places[1],
            lat = TARGETdatarows()$lat.places[1], zoom=10) %>%
      clearGroup("selectedTownShp") %>%
      addPolygons(data=twt[areaRowNumbers,], weight = 1,
                  color="Red", fillColor="yellow",
                  label= ~areaField, layerId = ~areaField,
                  fillOpacity = 1, group="selectedTownShp") #%>%

    #### default before area is selected ####
    if (input$areaSelectorId == " ")
      updateSelectInput(inputId='areaSelectorId', selected = 1)

#
#     columns.tabledemog = c("Total Population (2019)", "PM_avg")
#         # columns for tabledemog  are: c("NAME", "Total Population (2019)", "PM_avg")  (was 1,5,4)
#         # columns for tableest  were c(9:12,8,15,16)
#     columns.tableest = featureList
#       # c("Myocardial Infarctions", "COPD Deaths", "Ischemic Heart Disease Deaths",
#       #                    "All Cause Deaths, Laden Estimate"  ,
#       #                    "All Cause Deaths, Krewski Estimate", "All Cause Deaths, Lepeule Estimate",
#       #                    "All Cause Deaths, Di Estimate",
#       #                    "Low Birth Weight Babies", "Preterm Births", "Stillbirths" )
#     output$tabledemog <- DT::renderDataTable(
#       t(TARGETdatarows() [featureList]),
#       caption = demogcaption,
#       options = list(
#         dom="t",
#         columnDefs = list(list(className = 'dt-right', targets = 1)),
#         headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
#       output$tableest <- DT::renderDataTable(t(TARGETdatarows()[
#                                                           columns.tableest]),
#                                              caption = estcaption,
#                                              options = list(dom="t",
#                                                             columnDefs = list(list(className = 'dt-right', targets = 1)),
#                                                             headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
#       output$hotext <- renderText(paste(
#         "*All estimates are based on annual air pollution predictions. "))
#       # For example, in", TARGETstring(), "approximately",
#       #                                   "was ",
#       #                                   signif(digits=3, sum(TARGETdatarows()$`Cancer Deaths`)),
#       #                                    " people die due to cancers caused by air pollution every year."))
    }
  )

  # export button
  output$downloadData <- downloadHandler(
    filename = "Air-Pollution-PA.csv",
    content = function(file) {
      write.csv(PAtown, file)
    }
  )

  # Reactive storage of comparative tool inputs. Speeds up app
  # secondpageinput <- reactive(c(input$areaSelectorIdleft, input$areaSelectorIdright))

  # datatables for comparison tool
  # output$tabledemogleft <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[1],c(1,4,5)]),
  #                                              caption = demogcaption,
  #                                              options = list(dom="t",
  #                                                             columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                             headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tablepoprateleft <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[1],c(19:20,17:18)]),
  #                                            caption = popratecaption,
  #                                            options = list(dom="t",
  #                                                           columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                           headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tableIQleft <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[1],c(15:16)]),
  #                                           caption = IQcaption,
  #                                           options = list(dom="t",
  #                                                          columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                          headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tabledemogright <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[2],c(1,4,5)]),
  #                                               caption = demogcaption,
  #                                               options = list(dom="t",
  #                                                              columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                              headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tablepoprateright <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[2],c(19:20,17:18)]),
  #                                             caption = popratecaption,
  #                                             options = list(dom="t",
  #                                                            columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                            headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tableIQright <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[2],c(15:16)]),
  #                                               caption = IQcaption,
  #                                               options = list(dom="t",
  #                                                              columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                              headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))

  # column plot for comparison tool (hidden for small devices)
  reactivedata <- reactive({
    if(exists(x = 'columnchartdata'))
      columnchartdata[columnchartdata$Town == secondpageinput()[1] | columnchartdata$Town ==secondpageinput()[2],]
  })
  # output$comptable <- renderPlot({
  #   if(exists(x = 'columnchartdata'))
  #     ggplot(data=melt(data.table(reactivedata()), id=1), aes(x=variable, y=value, fill=Town)) +
  #                                 geom_bar(stat="identity", position=position_dodge(), colour="black") +
  #                                 theme_classic() + xlab("Incidence Rates") + ylab("") +
  #                                 scale_fill_manual(values = c("#8a100b", "#b29d6c")) +
  #                                 scale_x_discrete(labels= c("CancerDeaths_IR"="Cancer Deaths per 10,000 Population", "IHDDeaths_IR"="Heart Disease Deaths per 10,000 Population",
  #                                                             "**PIQ points lost per child"="PIQ Points Lost per child"))
  # else
  #   "WARNING: columnchartdata is not available"
  # })

  thisAreaFeature = reactive({
    thisFeature = as.numeric(twt[[input$idFeature]])
    return(thisFeature[TARGETrownumbers()])
  })
  thisAreaFeatureSummary = reactive({
    featureSummaryFunction = mean
    ### for now.  May also be popWeightedMean or sum
    return(featureSummaryFunction(thisAreaFeature(), na.rm=TRUE))
  })

  output$histTitle = renderUI( {
    print(paste('histTitle:', 'get_areaFieldName()=', get_areaFieldName()))
    print(paste('histTitle:', 'input$idFeature=', input$idFeature))

    thisFeature = as.numeric(twt[[input$idFeature]])

    print(paste('histTitle:', 'feature values',
                paste(collapse=',', thisAreaFeature())))
    print(paste('histTitle:', 'feature summary',
                paste(collapse=',', thisAreaFeatureSummary())))

    div(hr(),
        span(strong(switch(get_areaFieldName()=='towns',
                           "Selected town:", "Selected town/tract:")),
             span(
          style='color:green',
          paste(TARGETstring()))),
        br(),
        span(strong("Selected feature: "),
             span(
               style='color:green', input$idFeature, ' = ',
             signif(digits=3,
                    thisAreaFeatureSummary() ) )
             #### TODO: which features do we sum, which do we mean?
             ### population is char for some reason.
        ),
        br(),
        span(strong("Compared with entire region: "),
          span(style='color:green', 'proportion smaller = ',
          textOutput('proportion_smaller')
          )))
  })
  output$proportion_smaller <- renderText({
    print(paste('proportion_smaller:', 'distribution of idFeature'))
    print(capture.output(summary(twt[[input$idFeature]])))
    howManyLess = try({
      twt[[input$idFeature]] < thisAreaFeatureSummary()
#        PAtown[[input$idFeature]] [PAtown$areaField==input$areaSelectorId]
    })
    if (class(howManyLess) == 'try-error')
      howManyLess = 0
    signif(digits=2, mean(na.rm = TRUE, howManyLess ) )
  })

  output$featurePlot <- renderPlot({
    thisFeature = as.numeric(twt[[input$idFeature]])
    thisAreaFeature = thisAreaFeatureSummary()
    xlab = gsub('All-cause deaths', 'All-cause deaths: avg Krewski & Laden',
                input$idFeature)
    hist(thisFeature,
         xlab=xlab, ylab = 'count',
         main = '')
    abline(v=thisAreaFeatureSummary(),
                        lwd=3, col='green')
    arrows(x0 = thisAreaFeatureSummary(), y0 = 0,
           x1 = thisAreaFeatureSummary(), y1= par('usr')[4]*1.2, xpd=NA,
           col='green', lwd=3)

  })
}


