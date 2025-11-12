for (ob in ls())  {
  cat('===', ob, '\n')
  print(str(get(ob)))
}


#envMA = new.env()

# objects except envMA
library(dplyr)

#notMA = unlist(filter(data.frame(obs=ls()), obs!=  'envMA'))

#sapply(notMA, function(ob) assign(ob, get(ob), envir = envMA) )

#rm(list = ls(envMA))
#load(file = 'app/appdatafilesforbreathemap/appData.Rdata')
load(file = '../app/appdatafilesforbreathemap/massachusetts_columnchartdata.Rdata')
setdiff(names(MAtown), y=names(envMA$MAtown))
setdiff(names(MAtown), x=names(envMA$MAtown))
intersect(names(MAtown), x=names(envMA$MAtown))

#newdata
dim(MAtown) #739  26
newFields = setdiff(names(MAtown), y=names(envMA$MAtown))   # 10
newFields

#previous
dim(envMA$MAtown) #351  19
extraFieldsPrevious = setdiff(names(MAtown), x=names(envMA$MAtown))
#"POPCH80_90" "lon"        "lat"

#fields in common
intersect(names(MAtown), x=names(envMA$MAtown))     #16


