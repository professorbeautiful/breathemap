#### proceeding as if the new data with "MA" in file names really are "PA".

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
setdiff(names(PAtown), y=names(envMA$MAtown))
setdiff(names(PAtown), x=names(envMA$MAtown))
intersect(names(PAtown), x=names(envMA$MAtown))

#newdata
dim(PAtown) #739  26
newFields = setdiff(names(PAtown), y=names(envMA$MAtown))   # 10
newFields

#previous
dim(envMA$MAtown) #351  19
extraFieldsPrevious = setdiff(names(PAtown), x=names(envMA$MAtown))
#"POPCH80_90" "lon"        "lat"

#fields in common
intersect(names(PAtown), x=names(envMA$MAtown))     #16


