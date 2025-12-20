function(input, output, session) {
  includeScript('www/KeyHandler.js')
  observeEvent(input$ctrlDpressed, {}) # just to flush the ctrl-D press.
  shinyDebuggingPanel::makeDebuggingPanelOutput(
       session, toolsInitialState = FALSE,
       condition='ctrlDpressed === true'
      )


    # to speed app up and lower RAM
  #townreac <- reactive(PAtowndata[PAtowndata$NAME==input$townSelectorId,])
  townreac <- reactive({
    result = PAtowndata[which(PAtowndata$NAME==input$townSelectorId),]
    if(nrow(result) > 1) {
      print(result)
      result = result[result$COUNTYFP == '003', ]  ### select Allegheny
      print(result)
    }
    result
    })
  #needs Town, lat, lon

  medianLON= median(as.numeric(pa_tracts$INTPTLON[pa_tracts$tracts %in% PAtowndata$NAMELSAD]))
  medianLAT= median(as.numeric(pa_tracts$INTPTLAT[pa_tracts$tracts %in% PAtowndata$NAMELSAD]))


 # clicking updates selectInput
  observe({
    click <- input$map_shape_click
    if(is.null(click))
      updateSelectInput(session, "townSelectorId", selected = PAtowndata$NAME[1])
    else
      updateSelectInput(session, "townSelectorId", selected = click$id)
  })

  areaField = reactive({
    try({
      if(input$townToggleId == 'towns'){
      areaField = 'townName'
    }
    else if(input$townToggleId == 'towns with tracts'){
      areaField = 'towntractName'
    }
    print(paste('areaField=', areaField))
    })
    # print(head(PAtown[[areaField]]))
    return(areaField)
    # currentSelection = input$townSelectorId
    # print(paste('currentSelection', currentSelection))
    # updateSelectInput(session, "townSelectorId", choices = PAtown)
  })
 # leaflet map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.PositronNoLabels", options = tileOptions(minZoom = 5, maxZoom = 11)) %>%
      setView(lng = medianLON, lat = medianLAT, zoom = 7)  %>%
      addPolygons(data = PAtown,
                  weight = 1,
                  color = "Black",
                  fillColor = "blue",
                  fillOpacity = 0.3,
                  label = ~TOWN,
                  layerId = ~TOWN,
                  highlight = highlightOptions(
                    fillColor = "green",
                    color = "red",
                    weight = 2,
                    fillOpacity = 1,
                    bringToFront = T))
  })

  # Map animations and reactive selectors
  observeEvent(input$townSelectorId, {
    print(townreac())
    townRowNumber = which(PAtown$NAME==townreac()$NAME)
    leafletProxy("map", session) %>%
      flyTo(lng = townreac()$lon, lat = townreac()$lat, zoom=10) %>%
      clearGroup("selectedTownShp") %>%
      addPolygons(data=PAtown[townRowNumber,], weight = 1,
                  color="Red", fillColor="yellow",
                  fillOpacity = 1, group="selectedTownShp") #%>%
      # addLabelOnlyMarkers(    ## not working, not important
      #   lng = townreac()$lon, lat = townreac()$lat,
      #   layerId = NULL,
      #   group = 'selectedTownShp',
      #   icon = NULL,
      #   label = 'hello', #townreac()$NAME,
      #   labelOptions = labelOptions(noHide = T, direction = 'top', textOnly = T),
      #   #options = markerOptions(),
      #   clusterOptions = NULL,
      #   clusterId = NULL,
      #   data = getMapData(map)
      # )
    # A few things from the map tool tab: datatables and text
    # if statement is used to give automatic value tables/no error when input is empty
    default_town = 'Adamsburg, Census Tract'
    if (input$townSelectorId == " ")
      updateSelectInput(inputId='townSelectorId', selected = default_town)
    #   townChosen = default_town
    # else     townChosen = townreac()$NAME
    columns.tabledemog = c("NAME", "Total Population (2019)", "PM_avg")
        # columns for tabledemog  are: c("NAME", "Total Population (2019)", "PM_avg")  (was 1,5,4)
    # columns for tableest  were c(9:12,8,15,16)
    columns.tableest = c("Myocardial Infarctions", "COPD Deaths", "Ischemic Heart Disease Deaths",
                         "All Cause Deaths, Laden Estimate"  ,
                         "All Cause Deaths, Krewski Estimate", "All Cause Deaths, Lepeule Estimate",
                         "All Cause Deaths, Di Estimate",
                         "Low Birth Weight Babies", "Preterm Births", "Stillbirths" )
    output$tabledemog <- DT::renderDataTable(
      t(PAtowndata[PAtowndata$NAME==townreac()$NAME,
                   columns.tabledemog]),
      caption = demogcaption,
      options = list(
        dom="t",
        columnDefs = list(list(className = 'dt-right', targets = 1)),
        headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
      output$tableest <- DT::renderDataTable(t(PAtowndata[PAtowndata$NAME==townreac()$NAME,
                                                          columns.tableest]),
                                             caption = estcaption,
                                             options = list(dom="t",
                                                            columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                            headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
      output$hotext <- renderText(paste("*All estimates are based on annual air pollution predictions. For example, in", townreac()$NAME, "approximately",
                                        "was townreac()$`Cancer Deaths`", "people die due to cancers caused by air pollution every year."))
    }
  )

  # export button
  output$downloadData <- downloadHandler(
    filename = "Air-Pollution-PA.csv",
    content = function(file) {
      write.csv(PAtowndata, file)
    }
  )

  # Reactive storage of comparative tool inputs. Speeds up app
  # secondpageinput <- reactive(c(input$townSelectorIdleft, input$townSelectorIdright))

  # datatables for comparison tool
  # output$tabledemogleft <- DT::renderDataTable(t(PAtowndata[PAtowndata$NAME==secondpageinput()[1],c(1,4,5)]),
  #                                              caption = demogcaption,
  #                                              options = list(dom="t",
  #                                                             columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                             headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tablepoprateleft <- DT::renderDataTable(t(PAtowndata[PAtowndata$NAME==secondpageinput()[1],c(19:20,17:18)]),
  #                                            caption = popratecaption,
  #                                            options = list(dom="t",
  #                                                           columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                           headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tableIQleft <- DT::renderDataTable(t(PAtowndata[PAtowndata$NAME==secondpageinput()[1],c(15:16)]),
  #                                           caption = IQcaption,
  #                                           options = list(dom="t",
  #                                                          columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                          headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tabledemogright <- DT::renderDataTable(t(PAtowndata[PAtowndata$NAME==secondpageinput()[2],c(1,4,5)]),
  #                                               caption = demogcaption,
  #                                               options = list(dom="t",
  #                                                              columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                              headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tablepoprateright <- DT::renderDataTable(t(PAtowndata[PAtowndata$NAME==secondpageinput()[2],c(19:20,17:18)]),
  #                                             caption = popratecaption,
  #                                             options = list(dom="t",
  #                                                            columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                            headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tableIQright <- DT::renderDataTable(t(PAtowndata[PAtowndata$NAME==secondpageinput()[2],c(15:16)]),
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

  output$histTitle = renderUI( {
    thisFeature = as.numeric(PAtowndata[  , input$idFeature])
    thisTownFeature = thisFeature[which(PAtowndata$NAME==input$townSelectorId)]
    div(hr(),
        span(strong("Selected town:"), span(
          style='color:green',
          paste(input$townSelectorId))),
        br(),
        span(strong("Selected feature: "),
             span(
               style='color:green', input$idFeature, ' = ',
             signif(digits=3,
                    as.numeric(thisTownFeature) ))
             ### population is char for some reason.
        ),
        br(),
        span(strong("Compared with entire region: "),
          span(style='color:green', 'proportion smaller = ',
          signif(digits=2, mean(na.rm = TRUE,
               PAtowndata[  , input$idFeature]
               < PAtowndata[PAtowndata$NAME==input$townSelectorId, input$idFeature]
          )))))
      })

  output$featurePlot <- renderPlot({
    thisFeature = as.numeric(PAtowndata[  , input$idFeature])
    thisTownFeature = thisFeature[which(PAtowndata$NAME==input$townSelectorId)]
    xlab = gsub('All-cause deaths', 'All-cause deaths: avg Krewski & Laden',
                input$idFeature)
    hist(thisFeature,
         xlab=xlab, ylab = 'count',
         main = '')
    abline(v=PAtowndata[PAtowndata$NAME==input$townSelectorId, input$idFeature],
                        lwd=3, col='green')
    arrows(x0 = thisTownFeature, y0 = 0,
           x1 = thisTownFeature, y1= par('usr')[4]*1.2, xpd=NA,
           col='green', lwd=3)

  })
}


