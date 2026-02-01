#### IQ , birth cohort

#' from ella: 2019 PA birth cohort_censustracts_county .xlsx'
#' All births in PA in 2019
#'
#'

install.packages("googlesheets4")
library("googlesheets4")

# reading the sheet data
sheet_data <-read_sheet(    ##### doesn't work... Client error: (400) FAILED_PRECONDITION?
  'https://docs.google.com/spreadsheets/d/1NGwXkJ2TH_sP_O1dwT2Hx1jrawxGWhL0/edit?gid=1240450136#gid=1240450136'
)


ellaAllBirths.xl = readxl::read_excel(
  '2019 PA birth cohort_censustracts_county .xlsx')
###  identical read either way
ellaAllBirths = read.csv(
  '2019 PA birth cohort_censustracts_county .xlsx - Pennsylvania_Birth_2019.csv.csv', )
#' Tract needs to  be padded.
#'
ellaAllBirths$tract = 1e10 + ellaAllBirths$Tract

head(ellaAllBirths)
ellaAllBirths$tract = as.character(ellaAllBirths$tract)
head(ellaAllBirths)
ellaAllBirths$tract = substr(ellaAllBirths$tract, 6,13)
source('appPA/countymap.R')
ellaBirths.SW = ellaAllBirths[ellaAllBirths$County %in% countymap$county, ]  ##ok.
ellaBirths.SW$countynum = countymap$COUNTYFP[match(ellaBirths.SW$County,countymap$county)]
head(ellaBirths.SW)
table(ellaBirths.SW$County, ellaBirths.SW$countynum)
table(ellaBirths.SW$County)

which(ellaBirths.SW$Tract=='')  #none!

install.packages('xlsx')  #This package depends on Java and the rJava package
ellaIQ = readxl::read_excel(path = 'IQ Loss in the 2019 Pittsburgh MSA Birth Cohort.xlsx', sheet=1, skip =2, col_names = T)

countyBirthComparison = cbind(table(ellaBirths.SW$County), ellaIQ$`Live Births`[1:8])
names(countyBirthComparison) =
  c('ellaBirths.SW','ellaIQ')
#' Armstrong and Fayette and Westmoreland are way off???


### compare ellaBirths.SW with census?
census.allegheny = read.csv('Census Data ACSST5Y2020.S0101_2026-01-24T130140/ACSST5Y2020.S0101-Data.csv', header=T, skip = 1)
census.allegheny = data.frame(
  pop = census.allegheny$Estimate..Total..Total.population,
  tract = census.allegheny$Geography,
  lt5 = census.allegheny$Estimate..Total..Total.population..AGE..Under.5.years)
head(census.allegheny) [1:3] #ok
census.allegheny$tract = substr(start = 10, stop = 100, census.allegheny$tract)
head(census.allegheny) [1:3] #ok

census.allegheny$birth = census.allegheny$lt5/5
dim(census.allegheny)   # only 394 tracts.  that's just allegheny.  so ok.
head(census.allegheny)  # tract has '42'

source('appPA/setcompare.R')
head(ellaBirths.SW)
ellaBirths.SW$tract = paste0('42', ellaBirths.SW$countynum, ellaBirths.SW$tract)
head(ellaBirths.SW)


setcompare(ellaBirths.SW$tract, census.allegheny$tract)
# 351 tracts overlap
# both x_not_y y_not_x
# 351     492      43
table(ellaBirths.SW$tract)
ellaBirths.SW.counts = data.frame(ellaCounts = table(ellaBirths.SW$tract),
                                  tract = names(table(ellaBirths.SW$tract)))
head(ellaBirths.SW.counts)
sum(ellaBirths.SW$tract == '42003030500') ### checks out.
census.counts = data.frame(tract=census.allegheny$tract, oneFifth = census.allegheny$lt5/5)
head(census.counts)
birthsComparison = merge(ellaBirths.SW.counts, census.counts)
dim(birthsComparison)   ### 351
birthsComparison$county = substr(birthsComparison$tract, 3,5)
head(birthsComparison)

cor(birthsComparison$ellaCounts.Freq, birthsComparison$oneFifth, use = 'pair')  # 0.67
plot(birthsComparison$oneFifth, birthsComparison$ellaCounts.Freq,
     xlab='census <5 divided by 5',
     ylab='Ella birth cohort')
title("Allegheny County")
mtext('correlation = 0.67', side=3)
abline(0,1)

# For all 8 counties:
# https://data.census.gov/table?g=050XX00US42003,42005,42005$1400000,42007,42019,42051,42073,42125,42129


###   We will use
twt$births = ellaBirths.SW.counts$ellaCounts.Freq[
  match(twt$tracts, ellaBirths.SW.counts$tract)]
sum(is.na(twt$births)) #   16 are missingm we presume no births.
twt$births [is.na(twt$births)]  = 0

cohort.births.previous  = twt$births
cohort.iq.lost = twt$`PM2.5 average` * twt$births * 0.27  ## sum
cohort.earnings.lost = twt$`PM2.5 average` * twt$births * mean(10.6,13.1)

save(cohort.births, file = 'cohort.births.Rd')
save(cohort.iq.lost, file = 'cohort.iq.lost.Rd')
save(cohort.earnings.lost, file = 'cohort.earnings.lost.Rd')

#######  new census file for 8 counties











#### where did cohort.births come from?.  yet another table?
plot(cohort.births, twt$births)
births.by.county = sapply(split(cohort.births, twt$county.tracts), sum)
names(births.by.county) = countymap$county[ match(names(births.by.county), countymap$COUNTYFP)]
as.data.frame(births.by.county)
# tabulated from cohort.by.tract$births[match(twt$tracts, cohort.by.tract$tract)]
# See also 2019-counties-tracts - Pennsylvania_Birth_2019.csv.csv,
# Allegheny               12718
# Armstrong                 569
# Beaver                   1503
# Butler                   1582
# Fayette                   960
# Lawrence                  760
# Washington               1890
# Westmoreland             2879
## births.ella.by.county, pasted from Ella's table, using read.delim(file=pipe('pbpaste'))
# Allegheny	12834
# Armstrong	2092
# Beaver	1906
# Butler	1683
# Fayette	3202
# Lawrence	903
# Washington	1339
# Westmoreland	645
# Pittsburgh MSA	24604
read.table(file=pipe('pbpaste'), header = F)

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



