library(shiny)
State = 'PA'
wd = getwd()
appname = paste0('app', State)
if( ! (basename(wd) == appname) ){
  if(file.exists(appname))
    setwd(appname)
  else if(file.exists(paste0('../', appname)))
    setwd(paste0('../', appname))

}
# setwd("C:\\Users\\lukem\\Desktop\\BC_developer\\0224\\0308\\0625_FINAL\\app")
runApp()

setwd('..')
# sometimes setwd() is funky when running R locally. and setwd(".") won't work
# if this is the case, use set awd("~localpath") for development, but comment it
# out when uploading to actual server

# required packages:  sf  leaflet DT data.table ggplot2
