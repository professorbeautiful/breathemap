# loads packages required to run the app
library(sf)
library(leaflet)
library(DT)
library(ggplot2)
library(data.table)
library(tigris)
library(sf)
library(dplyr)

if(!require(shinyDebuggingPanel))
  devtools::install_github('professorbeautiful/shinyDebuggingPanel')
library(shinyDebuggingPanel)

# loads data required for app


load('tracts_with_towns.Rd')
load('patown1.Rd')   ## 26 fields only
PAtown = patown1
load('patowndata2.Rd' )   # same as
load('PAtowndata.lukedata.Rd')
PAtowndata = PAtowndata.lukedata
PAtowndata$`All-cause deaths` = rowMeans(PAtowndata[c(
  'All Cause Deaths, Laden Estimate',
  'All Cause Deaths, Krewski Estimate') ])

st_crs(PAtown) <- "WGS84"   ### no effect on the app apparently.
### removes the error msg,
# Warning: sf layer has inconsistent datum (+proj=longlat +datum=NAD83 +no_defs).
# Need '+proj=longlat +datum=WGS84'
### But gives us a new  error msg,
###Warning: st_crs<- : replacing crs does not reproject data; use st_transform for that


#  tracts_with_towns = tt1.sw # from geodataPA

# tracts = PAtowndata$NAMELSAD
# towns = tracts_with_towns$towns[match(tracts, tracts_with_towns$tracts)]
towns = tracts_with_towns$towns
townOrder = order(towns, na.last=TRUE)

####   15 are missing still.
towns [ is.na(towns )] = '___'
tracts_with_towns$towns [ is.na(tracts_with_towns$towns )] = '___'
townIs___ =  (towns == '___')
tracts_with_towns$lat.places[townIs___ ] =  tracts_with_towns$lat.tracts[townIs___ ]
tracts_with_towns$lon.places[townIs___ ] =  tracts_with_towns$lon.tracts[townIs___ ]
# PAtownnames = paste(towns, tracts, sep= ', ')
# PAtown$TOWN = PAtown$NAME = PAtownnames[match(tracts, PAtown$NAMELSAD)]
# PAtowndata$TOWN =PAtowndata$NAME = PAtownnames[match(tracts, PAtowndata$NAMELSAD)]
# PAtowndata$lat = lats[match(tracts, PAtowndata$NAMELSAD)]
# PAtowndata$lon = lons[match(tracts, PAtowndata$NAMELSAD)]
#
# PAtown$lat = lats[match(tracts, PAtown$NAMELSAD)]
# PAtown$lon = lons[match(tracts, PAtown$NAMELSAD)]
#  these lat and lon do seem to locate correctly.  checking against https://data.jsonline.com/census/total-population/ and US census.
# But needs more checking.


# sort everything by
tracts_with_towns = tracts_with_towns[townOrder, ]
towns = towns[townOrder]
names(PAtowndata)
featureList= c("Myocardial Infarctions", "COPD Deaths", "Ischemic Heart Disease Deaths",
               # "All Cause Deaths, Laden Estimate"  ,
               # "All Cause Deaths, Krewski Estimate", "All Cause Deaths, Lepeule Estimate",
               # "All Cause Deaths, Di Estimate",
               "All-cause deaths", # (avg Krewski, Laden)
               "Low Birth Weight Babies", "Preterm Births", "Stillbirths",
               "Total Population (2019)", "PM2.5 average")

#### Bring in featureList.  Careful PM_avg
PAtowndata$tracts = PAtowndata$GEOID
PAtowndata$`PM2.5 average` = PAtowndata$PM_avg
tracts_with_towns.wide = merge(tracts_with_towns, PAtowndata[c('tracts', 'Tract Name', featureList)])
names(tracts_with_towns.wide) = gsub(' ', '__', names(tracts_with_towns.wide))
tracts_with_towns.wide = (tracts_with_towns.wide %>%
                            select(c(tracts:towns.tt1, Tract__Name:geometry)))
names(tracts_with_towns.wide)
names(tracts_with_towns.wide) = gsub('__', ' ', names(tracts_with_towns.wide))
names(tracts_with_towns.wide)

tracts_with_towns.wide$areaField = tracts_with_towns.wide$towns
### for other fields to use for label, we will copy onto areaField.


# PAtown$townName = gsub(', .*Census Tract.*', '', PAtowndata$TOWN )
# PAtown$towntractName = PAtowndata$TOWN
# PAtown$noTown = PAtown$townName == '___'
# table (PAtown$noTown)

# PAtown$townName = gsub(', .*Census Tract.*', '', PAtowndata$TOWN )
# PAtown$towntractName = PAtowndata$TOWN
# PAtown$noTown = PAtown$townName == '___'
# table (PAtown$noTown)
# PAtown$areaField = PAtown$towntractName  ### until toggled
# PAtownExtra = setdiff(y=names(PAtown), names(PAtowndata))
# PAtown[PAtownExtra] = PAtowndata[PAtownExtra]
# class(PAtown)
# names(PAtown)
##  OK, from here on, no more PAtowndata
# PAtown$`Total Population (2019)` = as.numeric(PAtown$`Total Population (2019)`)

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

