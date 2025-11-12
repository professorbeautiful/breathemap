function(input, output, session) {
  
 # clicking updates selectInput
  observe({
    click <- input$map_shape_click
    if(is.null(click))
      return()
    else
      updateSelectInput(session, "town", selected = click$id)
  })

  # to speed app up and lower RAM
  townreac <- reactive(PAtowndata[PAtowndata$Town==input$town,])

  # leaflet map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.PositronNoLabels", options = tileOptions(minZoom = 5, maxZoom = 11)) %>%
      setView(lng = -71.7989, lat = 41.9410, zoom = 7)  %>%
      addPolygons(data = PAtown,
                  weight = 1,
                  color = "Black",
                  fillColor = "blue",
                  fillOpacity = 0.3,
                  label = ~TOWN,
                  layerId = ~TOWN,
                  highlight = highlightOptions(
                    fillColor = "Yellow",
                    color = "red",
                    weight = 2,
                    fillOpacity = 1,
                    bringToFront = T))
  })
  
  # Map animations and reactive selectors
  observeEvent(input$town, {
    leafletProxy("map", session) %>%
      flyTo(lng = townreac()$lon, lat = townreac()$lat, zoom=10) %>%
      clearGroup("selectedTownShp") %>%
      addPolygons(data=PAtown[PAtown$TOWN==townreac()$Town,], weight = 1, color="Red", fillColor="Yellow",fillOpacity = 1, group="selectedTownShp")

    # A few things from the map tool tab: datatables and text
    # if statement is used to give automatic value tables/no error when input is empty
    if (input$town == " "){
      output$tabledemog <- DT::renderDataTable(t(PAtowndata[PAtowndata$Town=="Boston",c(1,5,4)]),
                                               caption = demogcaption,
                                               options = list(
                                                 dom="t",
                                                 columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                 headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
      output$tableest <- DT::renderDataTable(t(PAtowndata[PAtowndata$Town=="Boston",c(9:12,8,15,16)]),
                                             caption = estcaption,
                                             options = list(dom="t",
                                                            columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                            headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
      output$hotext <- renderText(paste("*All statistics are based on annual air pollution estimates. For example, in", "Boston", "approximately",
                                        "176", "people die due to cancers caused by air pollution every year."))
    }
    else {
      output$tabledemog <- DT::renderDataTable(t(PAtowndata[PAtowndata$Town==townreac()$Town,c(1,5,4)]),
                                               caption = demogcaption,
                                               options = list(dom="t",
                                                              columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                              headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
      output$tableest <- DT::renderDataTable(t(PAtowndata[PAtowndata$Town==townreac()$Town,c(9:12,8,15,16)]),
                                             caption = estcaption,
                                             options = list(dom="t",
                                                            columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                            headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
      output$hotext <- renderText(paste("*All estimates are based on annual air pollution predictions. For example, in", townreac()$Town, "approximately",
                                        townreac()$`Cancer Deaths`, "people die due to cancers caused by air pollution every year."))
    }
  })

  # export button
  output$downloadData <- downloadHandler(
    filename = "Air-Pollution-PA.csv",
    content = function(file) {
      write.csv(PAtowndata, file)
    }
  )
  
  # Reactive storage of comparative tool inputs. Speeds up app
  secondpageinput <- reactive(c(input$townleft, input$townright))
  
  # datatables for comparison tool
  output$tabledemogleft <- DT::renderDataTable(t(PAtowndata[PAtowndata$Town==secondpageinput()[1],c(1,4,5)]),
                                               caption = demogcaption,
                                               options = list(dom="t",
                                                              columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                              headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  
  output$tablepoprateleft <- DT::renderDataTable(t(PAtowndata[PAtowndata$Town==secondpageinput()[1],c(19:20,17:18)]),
                                             caption = popratecaption,
                                             options = list(dom="t",
                                                            columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                            headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
 
  output$tableIQleft <- DT::renderDataTable(t(PAtowndata[PAtowndata$Town==secondpageinput()[1],c(15:16)]),
                                            caption = IQcaption,
                                            options = list(dom="t",
                                                           columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                           headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  
  output$tabledemogright <- DT::renderDataTable(t(PAtowndata[PAtowndata$Town==secondpageinput()[2],c(1,4,5)]),
                                                caption = demogcaption,
                                                options = list(dom="t",
                                                               columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                               headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  
  output$tablepoprateright <- DT::renderDataTable(t(PAtowndata[PAtowndata$Town==secondpageinput()[2],c(19:20,17:18)]),
                                              caption = popratecaption,
                                              options = list(dom="t",
                                                             columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                             headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))

  output$tableIQright <- DT::renderDataTable(t(PAtowndata[PAtowndata$Town==secondpageinput()[2],c(15:16)]),
                                                caption = IQcaption,
                                                options = list(dom="t",
                                                               columnDefs = list(list(className = 'dt-right', targets = 1)),
                                                               headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  
  # column plot for comparison tool (hidden for small devices)
  reactivedata <- reactive(columnchartdata[columnchartdata$Town == secondpageinput()[1] | columnchartdata$Town ==secondpageinput()[2],])
  
  output$comptable <- renderPlot(ggplot(data=melt(data.table(reactivedata()), id=1), aes(x=variable, y=value, fill=Town)) +
                                  geom_bar(stat="identity", position=position_dodge(), colour="black") +
                                  theme_classic() + xlab("Incidence Rates") + ylab("") +
                                  scale_fill_manual(values = c("#8a100b", "#b29d6c")) +
                                  scale_x_discrete(labels= c("CancerDeaths_IR"="Cancer Deaths per 10,000 Population", "IHDDeaths_IR"="Heart Disease Deaths per 10,000 Population",
                                                              "**PIQ points lost per child"="PIQ Points Lost per child")))
  

  
}


