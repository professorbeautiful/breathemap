#### IQ , birth cohort

cohort.pa = readr::read_csv('2019-counties-tracts - Pennsylvania_Birth_2019.csv.csv', col_types = 'cccc')
#ok, noread.csv()#ok, now character.
#### for searching, gsheet is better.
dim(cohort.pa)
head(cohort.pa)
## argh, dropping leading zeros despite "c'.
names(cohort.pa)
#shd be 130532
source('appPA/countymap.R')
cohort.pa[3089,] #  030500  next one empty
cohort.pa[3090,] #    this one empty
cohort.pa.sw = cohort.pa[cohort.pa$County %in% countymap$county, ]  ##ok.
cohort.pa.sw$countynum = countymap$COUNTYFP[match(cohort.pa.sw$County,countymap$county)]
table(cohort.pa.sw$County, cohort.pa.sw$countynum)
cohort.by.tract = paste0(cohort.pa.sw$countynum, cohort.pa.sw$Tract)
cohort.by.tract = table(cohort.by.tract)
cohort.by.tract = data.frame(tract = names(cohort.by.tract), births = as.vector(cohort.by.tract))
head(cohort.by.tract)
cohort.by.tract$tract = paste0('42', cohort.by.tract$tract)

### compare with census?
census.allegheny = read.csv('ACSST5Y2020.S0101_2026-01-24T130140/ACSST5Y2020.S0101-Data.csv', header=T, skip = 1)
head(census.allegheny) [1:6] #ok
census.allegheny = data.frame(
  pop = census.allegheny$Estimate..Total..Total.population,
  tract = census.allegheny$Geography,
  lt5 = census.allegheny$Estimate..Total..Total.population..AGE..Under.5.years)
census.allegheny$tract = substr(start = 10, stop = 100, census.allegheny$tract)

census.allegheny$birth = census.allegheny$lt5/5
dim(census.allegheny)   # only 394 tracts.  that's just allegheny.  so ok.
head(census.allegheny)  # tract has '42'

source('appPA/setcompare.R')
setcompare(cohort.by.tract$tract, twt$tracts)
# missing in 16.  Zeros?   723 overlapping tracts
birthmatch = census.allegheny
birthmatch$cohort = cohort.by.tract$births[
  match(birthmatch$tract,  cohort.by.tract$tract)]
sum(is.na(birthmatch$cohort))  #43.


cor(birthmatch$lt5, birthmatch$cohort, use = 'pair')  # 0.67
plot(birthmatch$lt5/5, birthmatch$cohort, xlab='census <5 divided by 5',
     ylab='birth cohort')
title("Allegheny County")
mtext('correlation = 0.67', side=3)
abline(0,1)

twt$births = cohort.by.tract$births[match(twt$tracts, cohort.by.tract$tract)]
sum(is.na(twt$births))  #16    We will assume they are zeros.
twt$births [is.na(twt$births)]  = 0

cohort.births  = twt$births
cohort.iq.lost = twt$`PM2.5 average` * twt$births * 0.27  ## sum
cohort.earnings.lost = twt$`PM2.5 average` * twt$births * mean(10.6,13.1)


save(cohort.births, file = 'cohort.births.Rd')
save(cohort.iq.lost, file = 'cohort.iq.lost.Rd')
save(cohort.earnings.lost, file = 'cohort.earnings.lost.Rd')

#'A 0.27-point loss in full-scale IQ (FSIQ) per 1 µg/m³ increase in PM₂.₅ (Alter et al.)
#'The monetary valuation of an IQ point, estimated at USD 10,600–13,100 per point in the United States (Grosse et al.).
#'Estimates of IQ points lost per 1 µg/m³ increase in PM₂.₅
#' were derived from Alter et al. (2024),
#' with a counterfactual concentration set to 0µg/m³.
#' The monetary valuation of one IQ point was taken from
#' Grosse and Zhou (2021), who estimated the present value
#' of lifetime earnings in the United States at USD 10,600–13,100
#' per IQ point.
#' In our analysis, USD 10,600 and USD 13,100 were used
#' to calculate the lower and upper limits, respectively,
#' and the Average Economic Loss was calculated as their mean.
#' All economic estimates are based on PM₂.₅-attributable FSIQ points lost,
#' therefore disregard the columns of performance IQ (PIQ) and verbal IQ (VIQ).
#'
#' asthma hospitalizations attributable to PM2.5:
#' 0.23% increase in asthma hospitalizations per 1 µg/m³,


################################################
### for old time's sake... last 6 digits are not unique.
counties = substr(twt$tracts, 3, 5)
table(counties)
table(table(substr(twt$tracts, 6, 100)))  ## remember the 7?



