#### note 2 places:  Millvale and Pittsburgh. ####
#### How many "Pittsburgh" places also have a neighborhood name?
####  But Millvale is NOT part of Pittsburgh.
tt1.sw %>% filter(tracts=='42003090100')   # Pittsburgh.  Millvale is 42003427000
tt1.sw %>% filter(tracts=='42003427000')  # also Millvale and Pittsburgh.


'Etna'
tt1.sw %>% filter(tracts=='42003425000')  # also Etna Sharpsburg and Pittsburgh.
tt1.sw %>% filter(tracts=='42003101100')  # also Etna Sharpsburg and Pittsburgh.

toStudy = cq('42003101100 42003090100 42003425000 42003427000')
st_join(pa_tracts[pa_tracts$tracts %in%
                    toStudy[4]  , ],
        join=st_covered_by,
        left=F,
        pa_places) $places
# NO DIFFERENCE  largest=F(default)    join='left'
# FAILS     join=st_contains_properly
# WARN largest=T   & takes a long time.
#  st_contains gives only Millvale and Etna , not Pittsburgh
intersect(PAtown$GEOID, toStudy)   ### they are all there.
#  st_covered_by does fine with 1 2 3 not 4-- gives Pittsburgh instead of Etna.
tractsLemery[tractsLemery$tracts %in% toStudy, ]   #perfect.
# towns      tracts
# 71                                 Etna 42003425000
# 130                            Millvale 42003427000
# 291  Central Lawrenceville (Pittsburgh) 42003090100
# 1421   Upper Lawrenceville (Pittsburgh) 42003101100

### Conclusion:  use st_covered_by, and if tractsLemery differs, use that instead.
 ###new improved  tt1.sw is 808, not 1937
table(tt1.sw$tracts %in% PAtown$GEOID)   ### 739
tt1.sw[tt1.sw$tracts %in% toStudy, cq('towns tracts')]
#'          towns      tracts
#'70   Pittsburgh 42003090100
#'7041 Pittsburgh 42003101100
#'3290   Millvale 42003427000
#'3373       Etna 42003425000
#'
#
