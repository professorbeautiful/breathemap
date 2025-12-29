addLukeTracts = function(pa_tracts) addLukeTracts()
{
  luke.pa.geom.pop = patown1
  luke.pa.geom.pop$tracts = luke.pa.geom.pop$GEOID

  #### replace missingPlaces with Lemery where possible.
  missingPlaces = which(is.na(tt1.sw.l$places))
  sum(is.na(tt1.sw.l$places))
  tt1.sw.l$towns[missingPlaces] = tt1.sw.l$lem.towns[missingPlaces]
  sum(is.na(tt1.sw.l$places))
  sum(is.na(tt1.sw.l$towns))  #15

  #### replace missing geometry with luke.pa.geom.pop (from PAtown originally)

  setcompare(luke.pa.geom.pop$tracts, patowndata2$GEOID)   # identical.
  setcompare(luke.pa.geom.pop$tracts, tt1.sw.l$tracts)
  # both x_not_y y_not_x
  #  683      56       0
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
}
