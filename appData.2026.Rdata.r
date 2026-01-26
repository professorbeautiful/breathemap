load('appData.2026.Rdata')
appData.2026.Rdata = new.env()

assign('PAtowndata', MAtowndata, env=appData.2026.Rdata)
assign('PAtown', MAtown, env=appData.2026.Rdata)
assign('PAtownnames', MAtownnames, env=appData.2026.Rdata)

# PM_avg  is there.
dim(MAtowndata)  # still 739.

patowndata3 = get('PAtowndata', env=appData.2026.Rdata)
# where there was patowndata2, replace with patowndata3

setcompare(names(get('PAtowndata', env=appData.2026.Rdata)),
           names(get('PAtowndata', env=PAenv)), countsonly = F)
setcompare(names(patowndata2), names(patowndata3), countsonly = F)

#  18 the same names.
#         "Lung Cancer Deaths"  is new
# gone: [1] "COPD Deaths"                        "All Cause Deaths, Krewski Estimate"
# [3] "All Cause Deaths, Di Estimate"      "All-cause deaths"
# [5] "tracts"                             "PM2.5 average"

# tracts field
patowndata3$tracts = patowndata3$GEOID
## identical in patowndata2, so in patowndata3 copy GEOID to tracts

patowndata3$`PM2.5 average` = patowndata3$`PM_avg`

#  compare new fields with old
samenames = setcompare(names(get('PAtowndata', env=appData.2026.Rdata)),
                       names(get('PAtowndata', env=PAenv)), countsonly = F)[[1]]
sapply(samenames, function(n)
                      table(patowndata2[[n]] == patowndata3[[n]], exclude=NULL))

View(cbind(patowndata2$`Myocardial Infarctions` , patowndata3$`Myocardial Infarctions`))
### some are mostly changed. Anyway, use patowndata3.

####
patown2 = get('PAtown', env=appData.2026.Rdata)
setcompare(names(patown1), names(patown2), countsonly = F)
### ah, patown2 now has PM_avg and "Tract Name".
samenames = setcompare(names(patown1),
                       names(patown2), countsonly = F)[[1]]
sapply(samenames, function(n)
  table(patown1[[n]] == patown2[[n]], exclude=NULL))   #### identical.

#####
appPA='/Users/rogerday/Google Drive/Documents/Fireman Breathe Project/appPA'
save('patowndata3', file=paste0(appPA,'/patowndata3.Rd'))
save('patown2', file=paste0(appPA,'/patown2.Rd'))















