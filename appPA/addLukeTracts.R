## requires pa_tracts, patown1 (PAtown;  has the geometry),
#                   patowndata2 (PAtowndata; has the data to display)

PAtown = patown1    #  badly named.  Luke tract geometry.
PAtowndata = patowndata2  #  badly named.  Luke tract data fields.
# There's nothing "town" about them. But we will keep these names to avoid more confusion.
save(PAtown, file='appPA/PAtown.Rd')
save(PAtowndata, file='appPA/PAtowndata.Rd')


luke.pa.geom.pop = patown1
luke.pa.geom.pop$tracts = luke.pa.geom.pop$GEOID   ### rename

#### replace missing geometry with luke.pa.geom.pop (from PAtown originally)

setcompare(luke.pa.geom.pop$tracts, patowndata2$GEOID)   # identical.
# setcompare(luke.pa.geom.pop$tracts, tt1.sw.l$tracts)
# # both x_not_y y_not_x
# #  739       0      69
setcompare(luke.pa.geom.pop$tracts, pa_tracts_sw$tracts)
#### 69 tracts for which we have no luke data.  nothing to be done with that.
#### Add the 56 tracts missing from pa_tracts, and start again, may pick up names.
missingTracts = setcompare(luke.pa.geom.pop$tracts, pa_tracts_sw$tracts, countsonly = F)  [[2]]
pa_tracts_sw_missing = luke.pa.geom.pop[luke.pa.geom.pop$GEOID %in% missingTracts,]

names(pa_tracts_sw)
names(pa_tracts_sw_missing)
pa_tracts_sw_missing = pa_tracts_sw_missing %>% dplyr::mutate(tracts=GEOID) %>% dplyr::mutate(tracts.short=NAME) %>%
  dplyr::mutate(lat.tracts=NA) %>% dplyr::mutate(lon.tracts=NA) %>%
  dplyr::mutate(county.tracts=COUNTYFP)
pa_tracts_sw_missing =  moveColumns(pa_tracts_sw_missing,
                                    cq('tracts tracts.short lat.tracts lon.tracts county.tracts geometry' ) )
pa_tracts_sw_missing = pa_tracts_sw_missing  %>% dplyr::select(
  cq('tracts tracts.short lat.tracts lon.tracts county.tracts geometry') )
print(paste('dim (pa_tracts_sw_missing) = ', paste(collapse=' ', dim(pa_tracts_sw_missing))))
pa_tracts_sw.luke_extended <<- rbind(pa_tracts_sw_missing, pa_tracts_sw)

