## 2025-11-23   data from Luke
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
s
#' copy lukedata PA objects to .GlobalEnv and reprocess.
#
sapply(ls(env=lukedata), function(o)
  assign(o, get(o, envir = lukedata), envir = .GlobalEnv) )
ls(patt='^PA*')
names(PAtown)
names(PAtowndata)
PAtowndata.lukedata = get('PAtowndata', env=lukedata)
setdiff(names(PAtowndata),
        names(PAtowndata.lukedata))
# [1] "Lung Cancer Deaths, Ghardibvand Estimate"
# [2] "Lung Cancer Deaths, Laden Estimate"
# [3] "TOWN"
# [4] "lat"
# [5] "lon"
setdiff(y=names(PAtowndata),
        names(get('PAtowndata', env=lukedata)))
# [1] "PM_avg"                  "Tract Name"
# [3] "Low Birth Weight Babies" "Preterm Births"
# [5] "Stillbirths"
intersect(names(PAtowndata),
        names(get('PAtowndata', env=lukedata)))###
#'  Merging new fields ...
length(get('PAtowndata')$NAMELSAD)   #739
length(get('PAtowndata', env=lukedata)$NAMELSAD)   #739
setdiff(y=get('PAtowndata')$NAMELSAD,
        get('PAtowndata', env=lukedata)$NAMELSAD)
### identical. so we can just merge.
PAtowndata.merged = merge(PAtowndata, get('PAtowndata', env=lukedata),
                           by='NAMELSAD')
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
dim(PAtowndata.merged)   ## 753  26    #Why not 739?

setdiff(x=PAtowndata$NAMELSAD,
        PAtowndata.merged$NAMELSAD)  ### no difference.  Duplicates?
which(duplicated(PAtowndata$NAMELSAD))
# [1] 128 130 175 549 550 565 610
PAtowndata[which(PAtowndata$NAMELSAD == PAtowndata$NAMELSAD[128] ) , ]

duplicatedNAMELSAD = PAtowndata.lukedata$NAMELSAD [
  which(duplicated(PAtowndata.lukedata$NAMELSAD))]
#     306 580 724 725 726 728 730


duplicatedNAMELSAD.rows = PAtowndata.lukedata[ PAtowndata.lukedata$NAMELSAD %in% duplicatedNAMELSAD, ]
duplicatedNAMELSAD.rows [order(duplicatedNAMELSAD.rows$NAMELSAD), ]

## REMEMBER to save PAtowndata.Rd in appPA.

save(PAtowndata.lukedata, file = 'appPA/PAtowndata.lukedata.Rd')
