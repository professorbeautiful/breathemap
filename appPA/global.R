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
library(shinyjs)
library(shinyWidgets)
library(keys)
library(markdown)
library(rmarkdown)
library(standby)
library(waiter)


shinyjs::useShinyjs()

verbose = 0

defaultAppName =   #### used only when run locally.
  'BreatheMap-test-with-IQ-no-popify'

# if( ! (basename(getwd()) == 'appPA') )
#      setwd('appPA')  ### NOT NEEDED IF FILES ARE LINKED IN THE 2 FOLDERS.
if(exists('appName'))
  rm(appName) ### running from RStudio; removing previous run.
appName = gsub('deploying','',
               grep('deploying', dir() , v=T) )
if(length(appName) > 1)  ### running from RStudio, not a deployed one.
  appName = defaultAppName
print(paste('appName: ', appName))

### use this to mask elements.

hideIfDesired <<- function(style = ';',
                           hideMe =
                             appName %in% c('BreatheMap-test',
                                            'BreatheMap', ### Added for web page.
                                            'BreatheMap-noIQ'))
  paste(style,
        ifelse(hideMe,
               "; visibility: hidden;",
               ''))


# if(basename(getwd()) != 'appPA')
#   setwd('appPA')
source('moveColumns.R')
source('cq.R')
source('inclRmd.R')
# source('www/content_TotalOrRates_Information.R')
# source('www/content_FeaturePlot_Information.R')
# source('www/content_LifetimeHarm_Information.R')
print(dir())
# source('indentMe.R')

if(!require(shinyDebuggingPanel))
  devtools::install_github('professorbeautiful/shinyDebuggingPanel')
library(shinyDebuggingPanel)

print(paste('interactive()', interactive()))
if(exists('ourModalDialog')) rm(ourModalDialog)
ourModalDialog = function(...) {
  modalDialog(footer=NULL,
              fluidRow(
                column(style='color:blue' , offset=11, 12,
                       style='text-align:left; color:blue',
                        span(#em("To close this popup:"),
                       modalButton('X'))
                )),
              hr(),
      div(...)
  )
}


#### infoList, for the bottom 3 buttons, handled differently in plot ####
infoList = c(
  "Population in 2019",
  "PM2.5 average",
  "Births in 2019"
)
#### infoListIds ####
infoListIds = data.frame(var = infoList,
                         id = c("IdShowPop",
                                "IdShowPM2.5",
                                "IdShowCohort")
)

#### featureList  or harmList ####

featureList= c(
  "IQ points lost",
  "Lifetime earnings lost",
  "All-cause deaths", # (avg Lepeule, Laden)
  "Ischemic Heart Disease Deaths",
  "Lung Cancer Deaths",
  "Myocardial Infarctions", #   "COPD Deaths", dropped.
  "Low Birth Weight Babies",
  "Preterm Births",
  "Stillbirths"
)

load('tracts_with_towns.Rd')   ## of type sf
# tracts_with_towns = tracts_with_towns[- (which(names(tracts_with_towns) %in% infoList))]
# tracts_with_towns = tracts_with_towns[- (which(names(tracts_with_towns) %in% featureList))]

load('patown2.Rd')   ##   # 2026-01-24   geometry.
patown2 = st_transform(patown2, 'WGS84')
PAtown = patown2

load('patowndata3.Rd' )   # 2026-01-24
#load('PAtowndata.lukedata.Rd')  # same as patowndata2.Rd, previous data
patowndata3$`Population in 2019` =
  as.numeric(patowndata3$`Total Population (2019)`)
print(paste('is.numeric(patowndata3$`Population in 2019` )',
      is.numeric(patowndata3$`Population in 2019` )))
PAtowndata = patowndata3    ### as of Jan 25.

PAtowndata$`All-cause deaths` = rowMeans(PAtowndata[c(
  'All Cause Deaths, Laden Estimate',
  'All Cause Deaths, Lepeule Estimate') ])  ### Krewski is out.

#### cohort.births.plus ####
load('cohort.births.plus.Rd')
print(head(cohort.births.plus))
#### merging in cohort.births.plus ####
PAtowndata$tract = as.numeric(PAtowndata$tract)
PAtowndata = merge(PAtowndata, cohort.births.plus)
print('merge is finished')
PAtowndata$`Births in 2019` = PAtowndata$births
  print(paste('identical(PAtowndata$`Births in 2019` ,  PAtowndata$births)
  ?',   identical(PAtowndata$`Births in 2019` ,  PAtowndata$births)
  ))
PAtowndata$`IQ points lost` = PAtowndata$cohort.iq.lost
PAtowndata$`Lifetime earnings lost` = PAtowndata$cohort.earnings.lost
#  15 zeros, not 16?
head(PAtowndata)


PAtown = st_transform(PAtown, "WGS84")
PAtown$tract = as.numeric(PAtown$GEOID)
#st_crs(PAtown) <- "WGS84"   ### no effect on the app apparently.
### removes the error msg,
# Warning: sf layer has inconsistent datum (+proj=longlat +datum=NAD83 +no_defs).
# Need '+proj=longlat +datum=WGS84'
### But gives us a new  error msg,
###Warning: st_crs<- : replacing crs does not reproject data; use st_transform for that


#  tracts_with_towns = tt1.sw # from geodataPA

####   15 are missing still. ####
towns = tracts_with_towns$towns

table(is.na(towns ))
towns [ which(is.na(towns )) ] = '___'
tracts_with_towns$towns [ which(is.na(tracts_with_towns$towns) )] = '___'
townIs___ =  (towns == '___')
### if '___' copy lat and lon from tracts to places
tracts_with_towns$lat.places[townIs___ ] =  tracts_with_towns$lat.tracts[townIs___ ]
tracts_with_towns$lon.places[townIs___ ] =  tracts_with_towns$lon.tracts[townIs___ ]

PAtowndata$tracts = PAtowndata$GEOID


PAtowndata$`PM2.5 average` = PAtowndata$PM_avg
PAtowndata$`Population in 2019` =
  as.numeric(PAtowndata$`Population in 2019`
)

tracts_with_towns.wide = merge(
  PAtowndata[c('tracts', 'Tract Name', 'Population in 2019', 'Births in 2019',
               'PM2.5 average', featureList)],
  tracts_with_towns, by='tracts' )

# temporarily replace spaces with __
names(tracts_with_towns.wide) = gsub(' ', '__', names(tracts_with_towns.wide))
tracts_with_towns.wide = (tracts_with_towns.wide %>%
                            select(c(tracts:towns.tt1, Tract__Name:geometry)))
names(tracts_with_towns.wide)
names(tracts_with_towns.wide) = gsub('__', ' ', names(tracts_with_towns.wide))
# restore spaces
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

#### move '___' to the end, ####
which___ = (grep('___', twt$areaField))   ### 1 to 15
twt = twt[ c(setdiff(1:nrow(twt), which___),  which___), ]


fixOneTract = function(tract, value, newvalue){
  print(paste('Calling fixOneTract', tract, value, newvalue))
  if(is.numeric(tract)) tract = as.character(tract)
  rowToChange = which(twt$tracts==tract) #35
  print(paste('Calling fixOneTract', tract, value, newvalue, rowToChange))
  # if( ! identical(length(rowToChange), 1) )
  #   stop(paste('error fixOneTract', length(rowToChange), rowToChange))
  columnsToChange = names(grep(value, twt[rowToChange, ], v=T) )
  print(columnsToChange)
  for(v in columnsToChange) {
    fixedFeature =  gsub(value, newvalue,
                          data.frame(twt[rowToChange,v] ) ) [1]

    print(paste(names(fixedFeature), fixedFeature, length(fixedFeature)))
    twt[rowToChange,v] = fixedFeature

  }
  print(paste('Exiting fixOneTract', twt[rowToChange, columnsToChange]))
  twt <<- twt
}
fixOneTract(42003562900, 'Pittsburgh', 'Hazelwood')

twt.df = data.frame(twt)   ### remove the sf class.
twt.df <<- data.frame(twt)
twt.df <<- twt.df[ which(names(twt.df) != 'geometry')]

#st_crs(twt) <- "WGS84"
twt = st_transform(twt, "WGS84")
#st_crs(twt) <- 4326



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

css.radio <- "
 .radio-inline {
#   padding: 0 10px;
#   text-align: center;
#   margin-left: 0 !important;
}"
#
# .radio-inline input {
#   top: 20px;
#   left: 50%;
#   margin-left: -6px !important;
# }"

