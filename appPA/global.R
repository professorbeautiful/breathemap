# loads packages required to run the app
library(sf)
library(leaflet)
library(DT)
library(ggplot2)
library(data.table)
library(shinyDebuggingPanel)

# loads data required for app
source('geodataPA.R', local=TRUE)
load('PAtown.Rd')
load('PAtowndata.Rd')
load('tracts_with_towns.Rd')  ### shoudl be in the folder appPA
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
