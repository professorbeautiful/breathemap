library(shiny)
if( ! (basename(getwd()) == 'app') )
    setwd('app')
# setwd("C:\\Users\\lukem\\Desktop\\BC_developer\\0224\\0308\\0625_FINAL\\app")
runApp()

# sometimes setwd() is funky when running R locally. and setwd(".") won't work
# if this is the case, use setwd("~localpath") for development, but comment it
# out when uploading to actual server

# required packages:  sf  leaflet DT data.table ggplot2
