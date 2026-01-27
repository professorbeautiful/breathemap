# loads packages required to run the app
library(sf)
library(leaflet)
library(DT)
library(ggplot2)
library(data.table)
library(tigris)
library(sf)
library(dplyr)
library(shinyBS)

# if(basename(getwd()) != 'appPA')
#   setwd('appPA')
source('moveColumns.R')
source('cq.R')

if(!require(shinyDebuggingPanel))
  devtools::install_github('professorbeautiful/shinyDebuggingPanel')
library(shinyDebuggingPanel)



load('tracts_with_towns.Rd')   ## of type sf
load('patown2.Rd')   ##   # 2026-01-24   geometry.
patown2 = st_transform(patown2, 'WGS84')
PAtown = patown2

load('patowndata3.Rd' )   # 2026-01-24
#load('PAtowndata.lukedata.Rd')  # same as patowndata2.Rd, previous data
PAtowndata = patowndata3    ### as of Jan 25.
PAtowndata$`All-cause deaths` = rowMeans(PAtowndata[c(
  'All Cause Deaths, Laden Estimate',
  'All Cause Deaths, Lepeule Estimate') ])  ### Krewski is out.

load('cohort.iq.lost.Rd')
load('cohort.earnings.lost.Rd')

PAtown = st_transform(PAtown, "WGS84")
#st_crs(PAtown) <- "WGS84"   ### no effect on the app apparently.
### removes the error msg,
# Warning: sf layer has inconsistent datum (+proj=longlat +datum=NAD83 +no_defs).
# Need '+proj=longlat +datum=WGS84'
### But gives us a new  error msg,
###Warning: st_crs<- : replacing crs does not reproject data; use st_transform for that


#  tracts_with_towns = tt1.sw # from geodataPA

# tracts = PAtowndata$NAMELSAD
# towns = tracts_with_towns$towns[match(tracts, tracts_with_towns$tracts)]
# towns = tracts_with_towns$towns
# townOrder = order(towns, na.last=TRUE)  ###
# # sort everything by towns
# tracts_with_towns = tracts_with_towns[townOrder, ]
# towns = towns[townOrder]
# PAtown = PAtown[townOrder, ]
# PAtowndata = PAtowndata[townOrder, ]

####   15 are missing still. ####
towns = tracts_with_towns$towns

table(is.na(towns ))
towns [ which(is.na(towns )) ] = '___'
tracts_with_towns$towns [ which(is.na(tracts_with_towns$towns) )] = '___'
townIs___ =  (towns == '___')
### if '___' copy lat and lon from tracts to places
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
##
PAtowndata$tracts = PAtowndata$GEOID

#### featureList ####

featureList= c(
  "PM2.5 average",
  "All-cause deaths", # (avg Lepeule, Laden)
  "Ischemic Heart Disease Deaths",
  "Lung Cancer Deaths",
  "Myocardial Infarctions", #   "COPD Deaths", dropped.
  "Low Birth Weight Babies",
  "Preterm Births",
  "Stillbirths",
  "Total Population (2019)"
  )
PAtowndata$`PM2.5 average` = PAtowndata$PM_avg

tracts_with_towns.wide = merge(
  PAtowndata[c('tracts', 'Tract Name', featureList)],
  tracts_with_towns, by='tracts' )

names(tracts_with_towns.wide) = gsub(' ', '__', names(tracts_with_towns.wide))
tracts_with_towns.wide = (tracts_with_towns.wide %>%
                            select(c(tracts:towns.tt1, Tract__Name:geometry)))
names(tracts_with_towns.wide)
names(tracts_with_towns.wide) = gsub('__', ' ', names(tracts_with_towns.wide))
names(tracts_with_towns.wide)
#### Must be a "sf" object. ####
tracts_with_towns.wide = st_as_sf(tracts_with_towns.wide)
class(tracts_with_towns.wide)

### for other fields to use for label, we will copy onto areaField.
#### finally, copy back to tracts_with_fields ####
tracts_with_towns = tracts_with_towns.wide
tracts_with_towns$twt =  paste(tracts_with_towns$towns, tracts_with_towns$tracts)
tracts_with_towns$areaField = tracts_with_towns$twt
tracts_with_towns = moveColumns(tracts_with_towns, 'areaField')
tracts_with_towns = tracts_with_towns[ order(tracts_with_towns$twt) ,  ]
twt = tracts_with_towns   ##### So twt$twt
class(twt)  #sf
names(twt)
head(twt$areaField)

twt$twtSaved = twt$twt
# twt$twt = twt$twt.for.tracts = twt$twt.for.towns =
#   gsub( '^Pittsburgh 42', 'Pittsburgh (unspecified) 42',
#         twt$twtSaved )


#### move '___' to the end, ####
which___ = (grep('___', twt$areaField))   ### 1 to 15
twt = twt[ c(setdiff(1:nrow(twt), which___),  which___), ]

####and create twtFirst ?   no, rely on towns field ####
# twt$twtFirst = paste(twt$towns.intersects.first, twt$tracts)
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

#st_crs(twt) <- "WGS84"
twt = st_transform(twt, "WGS84")
#st_crs(twt) <- 4326

eachTown = sort(unique(unlist(strsplit(twt$towns, split=', *'))))
#eachTown.isNbhd = match(eachTown, twt$towns)
#twt$lem.tracts
