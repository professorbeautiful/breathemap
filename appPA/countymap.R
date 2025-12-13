### county map
table(PAtown$COUNTYFP)

# 003 005 007 019 051 073 125 129
# 402  19  51  44  36  28  59 100
'Allegheny Armstrong Beaver Butler Fayette Lawrence Washington Westmoreland'
countymap = data.frame(COUNTYFP =
                         strsplit(split=' ', '003 005 007 019 051 073 125 129 ')[[1]],
                       county=
                         strsplit(split=' ', 'Allegheny Armstrong Beaver Butler Fayette Lawrence Washington Westmoreland')[[1]]
)
PAtowndata[ PAtowndata$NAMELSAD %in%  duplicatedNAMELSAD, c('COUNTYFP', 'NAME')]
twoCounties = PAtowndata$NAMELSAD %in%  duplicatedNAMELSAD &
             PAtowndata$COUNTYFP=='003'
PAtowndata[twoCounties, c('COUNTYFP', 'NAME')]
###  So one allegheny per pair.   We can remove the others.
PAtowndata.reduced = PAtowndata[  ! (PAtowndata$NAMELSAD %in%  duplicatedNAMELSAD)
                        | PAtowndata$COUNTYFP=='003', ]
##  "not duplicated or Allegheny".   dropped 7.
