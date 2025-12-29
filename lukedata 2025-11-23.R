## 2025-11-25   data from Luke
lukedata =new.env()
load('refindingtheaccuratedatatopopulatepaannualhealtho/appData.Rdata',
     envir=lukedata, verbose = TRUE)
View(get('MAtown', envir=lukedata))
#' I moved previous PA data into PAenv
#' The previous MA data were in fact the PA data;  removed.
#' Placed new data from luke 2025-11-23 into lukedata.
#' Now renaming MA to PA
#
# saved previous appPA/PAtowndata.Rd  as PAtowndata.earlyNov.Rd

sapply(ls(env=lukedata), function(o)
  assign(gsub('MA', 'PA', o), get(o, envir = lukedata), envir = lukedata) )
ls(env=lukedata)
rm(list=
     ls(pattern = 'MA', envir=lukedata),
   envir=lukedata
   )
ls(env=lukedata)
###DONE

#' copy lukedata PA objects to .GlobalEnv and reprocess.
#
sapply(ls(env=lukedata), function(o)
  assign(o, get(o, envir = lukedata), envir = .GlobalEnv) )
ls(patt='^PA*')
names(PAtown)
names(PAtowndata)
PAtowndata.lukedata = get('PAtowndata', env=lukedata)
identical(PAtowndata.lukedata, PAtowndata)

# these setdiff are from earlier era!
# setdiff(names(PAtowndata),
#         names(PAtowndata.lukedata))
# # [1] "Lung Cancer Deaths, Ghardibvand Estimate"
# # [2] "Lung Cancer Deaths, Laden Estimate"
# # [3] "TOWN"
# # [4] "lat"
# # [5] "lon"
# setdiff(y=names(PAtowndata),
#         names(get('PAtowndata', env=lukedata)))
# # [1] "PM_avg"                  "Tract Name"
# # [3] "Low Birth Weight Babies" "Preterm Births"
# # [5] "Stillbirths"
# intersect(names(PAtowndata),
#         names(get('PAtowndata', env=lukedata)))###
#'  Merging new fields ...
length(get('PAtowndata')$NAMELSAD)   #739
length(get('PAtowndata', env=lukedata)$NAMELSAD)   #739
setcompare(y=get('PAtowndata')$GEOID,
        get('PAtowndata', env=lukedata)$GEOID)
### identical. so we can just merge.
#######NOOOOOOO!!!

PAtowndata[grep (' 103', PAtowndata$NAMELSAD), ] #### GEOID is what we want.
PAtown[grep (' 103', PAtowndata$NAMELSAD), ] #### GEOID is what we want.

PAtowndata.joined =   ### no can do
  st_join(PAtown, PAtown, by='GEOID')


PAtowndata.merged = merge(PAtowndata, PAtowndata.lukedata, #get('PAtowndata', env=lukedata),
                           by='GEOID')
dim(PAtowndata.merged)
names(PAtowndata.merged)
dotxNames = grep('.x$', names(PAtowndata.merged), v=T)
dotxNums = grep('.x$', names(PAtowndata.merged))
for(dotx in grep('.x$', names(PAtowndata.merged), v=T)) {
  dot = gsub('.x$', '', dotx)
  doty = paste0(dot, '.y')
  print(paste(dot, identical(PAtowndata.merged$dotx, PAtowndata.merged$doty)))
  ### all identical, so drop dup columns.
}
PAtowndata.merged = PAtowndata.merged[,
  -grep('.y$', names(PAtowndata.merged))]
names(PAtowndata.merged)[dotxNums] =
  gsub('.x', '', dotxNames)
names(PAtowndata.merged)
## OK, done.
dim(PAtowndata.merged)   ## 739  21

which(duplicated(PAtowndata$GEOID))
### none. !!!!!  finally rid of the tract mess!
# which(duplicated(PAtowndata$NAMELSAD))
# [1] 128 130 175 549 550 565 610

# duplicatedNAMELSAD = PAtowndata.lukedata$NAMELSAD [
#   which(duplicated(PAtowndata.lukedata$NAMELSAD))]
#     306 580 724 725 726 728 730

## the geom data is in PAtown, not PAtowndata or PAtowndata.merged!!
save(PAtowndata.merged, file = 'appPA/PAtowndata.merged.Rd')
