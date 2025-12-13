# loads packages required to run the app
library(sf)
library(leaflet)
library(DT)
library(ggplot2)
library(data.table)
if(!require(shinyDebuggingPanel))
  devtools::install_github('professorbeautiful/shinyDebuggingPanel')
library(shinyDebuggingPanel)

# loads data required for app

source('geodataPA.R', local=TRUE)
load('PAtown.Rd')
st_crs(PAtown) <- "WGS84"   ### no effect on the app apparently.
### removes the error msg,
# Warning: sf layer has inconsistent datum (+proj=longlat +datum=NAD83 +no_defs).
# Need '+proj=longlat +datum=WGS84'
### But gives us a new  error msg,
###Warning: st_crs<- : replacing crs does not reproject data; use st_transform for that

load('PAtowndata.lukedata.Rd')
PAtowndata = PAtowndata.lukedata
PAtowndata$`All-cause deaths` = rowMeans(PAtowndata[c(
  'All Cause Deaths, Laden Estimate',
  'All Cause Deaths, Krewski Estimate') ])
load('tracts_with_towns.Rd')  ### should be in the folder appPA
tracts = PAtowndata$NAMELSAD
towns = tracts_with_towns$towns[match(tracts, tracts_with_towns$tracts)]
townOrder = order(towns, na.last=TRUE)

towns [ is.na(towns )] = '___'
tracts_with_towns$towns [ is.na(tracts_with_towns$towns )] = '___'

lats.x = as.numeric(tracts_with_towns$lat.x[match(tracts, tracts_with_towns$tracts)])
lons.x = as.numeric(tracts_with_towns$lon.x[match(tracts, tracts_with_towns$tracts)])
lats.y = as.numeric(tracts_with_towns$lat.y[match(tracts, tracts_with_towns$tracts)])
lons.y = as.numeric(tracts_with_towns$lon.y[match(tracts, tracts_with_towns$tracts)])
#plot(lats.x, lats.y); plot(lons.x, lons.y);
lats = (lats.x+lats.y)/2    ### slightly more accurate, probably
lons = (lons.x+lons.y)/2
PAtownnames = paste(towns, tracts, sep= ', ')
PAtown$TOWN = PAtown$NAME = PAtownnames[match(tracts, PAtown$NAMELSAD)]
PAtowndata$TOWN =PAtowndata$NAME = PAtownnames[match(tracts, PAtowndata$NAMELSAD)]
PAtowndata$lat = lats[match(tracts, PAtowndata$NAMELSAD)]
PAtowndata$lon = lons[match(tracts, PAtowndata$NAMELSAD)]

PAtown$lat = lats[match(tracts, PAtown$NAMELSAD)]
PAtown$lon = lons[match(tracts, PAtown$NAMELSAD)]
#  these lat and lon do seem to locate correctly.  checking against https://data.jsonline.com/census/total-population/ and US census.
# But needs more checking.


# sort everything by
tracts_with_towns = tracts_with_towns[townOrder, ]
towns = towns[townOrder]
PAtown = PAtown[townOrder, ]
PAtowndata = PAtowndata[townOrder, ]
PAtownnames = PAtownnames[townOrder]


# creates headers for the datatables. Referenced in server.R
demogcaption <- htmltools::tags$caption(
  style = 'font-weight: bold; text-align: center; color:#FFFFFF; background-color:#8a100b; padding:0.5em;',
  'Town Demographics')

estcaption <- htmltools::tags$caption(
  style = 'font-weight: bold; text-align: center; color:#FFFFFF; background-color:#8a100b; padding:0.5em;',
  'Annual Pollution-Related Health Outcomes*')

popratecaption <- htmltools::tags$caption(
  style = 'font-weight: bold; text-align: center; color:#FFFFFF; background-color:#8a100b; padding:0.5em;',
  'Estimated Health Outcome Rates*')

IQcaption <- htmltools::tags$caption(
  style = 'font-weight: bold; text-align: center; color:#FFFFFF; background-color:#8a100b; padding:0.5em;',
  'Estimated IQ Loss')

featureList= c("Myocardial Infarctions", "COPD Deaths", "Ischemic Heart Disease Deaths",
               # "All Cause Deaths, Laden Estimate"  ,
               # "All Cause Deaths, Krewski Estimate", "All Cause Deaths, Lepeule Estimate",
               # "All Cause Deaths, Di Estimate",
               "All-cause deaths", # (avg Krewski, Laden)
               "Low Birth Weight Babies", "Preterm Births", "Stillbirths",
               "Total Population (2019)", "PM_avg")
