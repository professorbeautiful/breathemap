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
names(get('PAtowndata', env=lukedata))
setdiff(names(PAtowndata),
names(get('PAtowndata', env=lukedata)))
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
###
# head(PAtownnames)  # just census tracts.

# saved previous appPA/PAtowndata.Rd  as PAtowndata.earlyNov.Rd
## REMEMBER to save PAtowndata.Rd in appPA.

