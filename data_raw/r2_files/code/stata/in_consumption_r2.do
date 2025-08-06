***** CONSUMPTION AGGREGATES R2 - BASED ON ANDREAS' COUNTRY REPORT DO FILE ********************
clear
set mem 700m
set more off 

global r1yc			N:\Quantitative research\Data\r1\india\yc
global r1oc			N:\Quantitative research\Data\r1\india\oc
global r2yc			N:\Quantitative research\Data\r2\india\yc
global r2oc			N:\Quantitative research\Data\r2\india\oc
global r3yc			N:\Quantitative research\Data\r3\india\yc
global r3oc			N:\Quantitative research\Data\r3\india\oc
global constructed 	N:\Quantitative research\Round 3 country reports\snapshots\india\constructed_data\andreas



****************************************** YOUNGER COHORT **********************************************

use "$r2yc\raw\inchildlevel5yrold.dta", clear
sort commid

merge commid using "$constructed\community_local_prices_india_merge_r2.dta" 

/* see "\\qeh1\staff$\qehs0759\Do files\India\R2_country_report\india_r1_r2_aggregates_indexes.do" to see how community_local_prices_india_merge_r2 was
constructed. */

tab _merge

// not perfect merging because community price data include info for 98 communities whereas child obs are from 101 communities

su price*

/*missing price info for two reasons: incomplete merging and lack of price info for some communities in the community price data.Some of the missing
values are replaced using the cluster average price for the good as executed in the rest of the generating community prices do file.*/

// where no price data is available we will use the average for the rest of the cluster

sort clustid
by clustid: egen xprice01= mean(price01)
by clustid: egen xprice02= mean(price02)
by clustid: egen xprice07= mean(price07)
by clustid: egen xprice11= mean(price11)
by clustid: egen xprice13= mean(price13)
by clustid: egen xprice14= mean(price14)
by clustid: egen xprice15= mean(price15)
by clustid: egen xprice18= mean(price18)
by clustid: egen xpricecig= mean(pricecig)
by clustid: egen xpricekero= mean(pricekero)

replace price01=xprice01 if price01==.
replace price02=xprice02 if price02==.
replace price07=xprice07 if price07==.
replace price11=xprice11 if price11==.
replace price13=xprice13 if price13==.
replace price14=xprice14 if price14==.
replace price15=xprice15 if price15==.
replace price18=xprice18 if price18==.
replace pricecig=xpricecig if pricecig==.
replace pricekero=xpricekero if pricekero==. 

// Missing Values

recode eatv* ownv* giftv* spyr* spndyr* spend* (-88 -77 -99 .=0)

forvalues i=1/20 {

if `i'>=1 & `i'<=9 {
replace eatv0`i'=0 if eatv0`i'<0
replace ownv0`i'=0 if ownv0`i'<0
replace giftv0`i'=0 if giftv0`i'<0

}

if `i'>=10 {
replace eatv`i'=0 if eatv`i'<0
replace ownv`i'=0 if ownv`i'<0
replace giftv`i'=0 if giftv`i'<0

}
}

// generating the total monthly expenditure on food items 

gen food1= 2*(eatv01 + ownv01+giftv01)
gen food2= 2*(eatv02 +ownv02+giftv01)
gen food7= 2*(eatv07 +ownv07+giftv07)
gen food11= 2*(eatv11 +ownv11+giftv11)
gen food13= 2*(eatv13 +ownv13+giftv13)
gen food14= 2*(eatv14 +ownv14+giftv14)
gen food15= 2*(eatv15 +ownv15+giftv15)
gen food18= 2*(eatv18 +ownv18+giftv18)

// generating total community-wide expenditure on each of the covered food and non-food items

sort commid
by commid: egen foodsum1= total(food1)
by commid: egen foodsum2= total(food2)
by commid: egen foodsum7= total(food7)
by commid: egen foodsum11= total(food11)
by commid: egen foodsum13= total(food13)
by commid: egen foodsum14= total(food14)
by commid: egen foodsum15= total(food15)
by commid: egen foodsum18= total(food18)
by commid: egen cigarettessum1= total(spend01)
by commid: egen kerosenesum1= total(spend03)

// generating total community-wide expenditure on all the covered items together

by commid: gen total = (foodsum1 +foodsum2 +foodsum7 +foodsum11 +foodsum13 +foodsum14 +foodsum15 +foodsum18 +cigarettes + kerosene)

// generating weights for each commodity equivalent to share in total expenditure at community-level

gen share1 = foodsum1/total  
gen share2 = foodsum2/total
gen share7 = foodsum7/total
gen share11 = foodsum11/total
gen share13 = foodsum13/total
gen share14 = foodsum14/total
gen share15 = foodsum15/total
gen share18 = foodsum18/total
gen sharecig = cigarettes/total
gen sharekerosene = kerosene/total

/*
foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
replace price`i'=. if price`i'<2
}

*/

egen mprice01=mean(price01)
egen mprice02=mean(price02)
egen mprice07=mean(price07)
egen mprice11=mean(price11)
egen mprice13=mean(price13)
egen mprice14=mean(price14)
egen mprice15=mean(price15)
egen mprice18=mean(price18)
egen mpricecig=mean(pricecig)
egen mpricekerosene=mean(pricekerosene)

/* A separate note is produced to explain how the CPIs where consutructed. In a nutshell we use community prices for spatial adjustments in the cost of 
living and Andhra Pradesh specific CPIs for rural and urban areas in the interview months from the Indian Labour Bureau for temporal adjustments using 2006
, e.g. R2 survey as base year.*/

gen index1= share1*(price01/mprice01)
gen index2= share2*(price02/mprice02)
gen index7= share7*(price07/mprice07)
gen index11= share11*(price11/mprice11)
gen index13= share13*(price13/mprice13)
gen index14= share14*(price14/mprice14)
gen index15= share15*(price15/mprice15)
gen index18= share18*(price18/mprice18)
gen indexcig= sharecig*(pricecig/mpricecig)
gen indexkerosene_c2 = sharekerosene*(pricekerosene/mpricekerosene)

g cpi1=index1

foreach i in 2 7 11 13 14 15 18 cig kerosene {
replace cpi1=cpi1+index`i'
}

g share01=share1
g share02=share2
g share07=share7

g wprsum=0

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
replace wprsum=wprsum+share`i'*price`i'
}

egen mwprsum=mean(wprsum)

g cpi2=wprsum/mwprsum

/* use Indian Labour bureau CPI for Industrial workers and urban labourers in Andhra Pradesh-see "\\qeh1\staff$\qehs0759\Data\India\R3\AP_CPI_IW_RL_06_09_10.xls"
for all data extracted from the Indian Labour Bureau-see folder "\\qeh1\staff$\qehs0759\Country reports for all relevant CPI tables. This CPI varies by whether 
urban/rural and by interview month.*/

su cpi1, detail
su cpi2,detail

su price* if cpi1<0.1
su price* if cpi2<0.1

/*the very small cpi is going to lead to an exploding real expenditure which doesn't make sense especially when the very small cpi results from implausibly
small prices. Thus trim cpi1, cpi2*/

replace cpi1=. if cpi1<0.5
replace cpi2=. if cpi2<0.5

// we use 2006, R2 as a base so no need for temporal adjustment 

egen seatv=rowtotal(eatv01-eatv20)
egen sownv=rowtotal(ownv01-ownv20)
egen sgiftv=rowtotal(giftv01-giftv20)

gen foodexp= 2*(seatv+sownv+sgiftv)

egen sspyr=rowtotal(spyr01-spyr23)
egen sspndyr=rowtotal(spndyr07-spndyr11)
egen sspend=rowtotal(spend01-spend06)

g nfexp=(0.083333333*(sspyr+sspndyr))+sspend

gen texp= foodexp + nfexp
gen percapexp = texp/hhsize

su percap,detail

// trim very small and very large values

replace percapexp=. if percapexp<197 | percapexp>3100

gen realpce1=percap/cpi1
gen realpce2=percap/cpi2

// will use realpce2 as explained above. Check consistency

su realpce2
tab typesite,su(realpce2)
tab chldeth,su(realpce2)

/*use real poverty line from Indian Planning commission Nov 2009 updated methodology to construct poverty lines. See my documents/country reports etc. for
 a pdf file. This is constructed using 2004/05 prices and allows only for regional disparities. Thus will use the 2004-05/2006 price ratio for urban/rural
 from Indian Labour bureau CPI for Andhra Prdesh to allow for temporal adjustments in the poverty line. The poverty line uses average prices over 2004/05 
and thus the index used to do the temporal adjustment will be the ratio of 2004/05 average prices divided by 2006 average prices (both price averages are 
using 2001 as base). Thus the base will be 2006 and the poverty line will be different for urban and for rural. See AP_CPI Indian LAbour bureau excell file
in my documents for details.*/

g povline=433.43/0.93 if typesite==2
replace povline=563.16/0.98 if typesite==1

g abspov=realpce2<povline if realpce2<. & povline<.

tab typesite,su(abspov)

keep childid foodexp nfexp texp percapexp realpce2

label var foodexp    "Expenditure in food items"
label var nfexp      "Expenditure in non-food items"
label var texp       "Total Expenditure"
label var percapexp  "Total expenditure per capita"
label var realpce2   "Real per capita expenditure"

sort childid
save "$r2yc/constructed/consumption_2yc.dta", replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep childid realpce2   
rename  realpce2       tconsrpc
label var tconsrpc     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\india\consumption_2yc.dta", replace



************************************** OLDER COHORT **************************************
use "$r2oc\raw\inchildlevel12yrold.dta", clear
sort commid
merge commid using "$constructed\community_local_prices_india_merge_r2.dta"
tab _merge

// not perfect merging because community price data include info for 98 communities whereas child obs are from 101 communities

su price*

/* missing price info for two reasons: incomplete merging and lack of price info for some communities in the community price data.Some of the missing
values are replaced using the cluster average price for the good as executed in the rest of the generating community prices do file.*/

// below it is executed the command from the rest of the community prices do file

// where no price data is available we will use the average for the rest of the cluster

sort clustid
by clustid: egen xprice01= mean(price01)
by clustid: egen xprice02= mean(price02)
by clustid: egen xprice07= mean(price07)
by clustid: egen xprice11= mean(price11)
by clustid: egen xprice13= mean(price13)
by clustid: egen xprice14= mean(price14)
by clustid: egen xprice15= mean(price15)
by clustid: egen xprice18= mean(price18)
by clustid: egen xpricecig= mean(pricecig)
by clustid: egen xpricekero= mean(pricekero)

replace price01=xprice01 if price01==.
replace price02=xprice02 if price02==.
replace price07=xprice07 if price07==.
replace price11=xprice11 if price11==.
replace price13=xprice13 if price13==.
replace price14=xprice14 if price14==.
replace price15=xprice15 if price15==.
replace price18=xprice18 if price18==.
replace pricecig=xpricecig if pricecig==.
replace pricekero=xpricekero if pricekero==. 

// Missing Values

recode eatv* ownv* giftv* spyr* spndyr* spend* (-88 -77 -99 .=0)

forvalues i=1/20 {

if `i'>=1 & `i'<=9 {
replace eatv0`i'=0 if eatv0`i'<0
replace ownv0`i'=0 if ownv0`i'<0
replace giftv0`i'=0 if giftv0`i'<0
}

if `i'>=10 {
replace eatv`i'=0 if eatv`i'<0
replace ownv`i'=0 if ownv`i'<0
replace giftv`i'=0 if giftv`i'<0
}
}

// generating the total monthly expenditure on food items 

gen food1= 2*(eatv01 + ownv01+giftv01)
gen food2= 2*(eatv02 +ownv02+giftv01)
gen food7= 2*(eatv07 +ownv07+giftv07)
gen food11= 2*(eatv11 +ownv11+giftv11)
gen food13= 2*(eatv13 +ownv13+giftv13)
gen food14= 2*(eatv14 +ownv14+giftv14)
gen food15= 2*(eatv15 +ownv15+giftv15)
gen food18= 2*(eatv18 +ownv18+giftv18)

// generating total community-wide expenditure on each of the covered food and non-food items 

sort commid
by commid: egen foodsum1= total(food1)
by commid: egen foodsum2= total(food2)
by commid: egen foodsum7= total(food7)
by commid: egen foodsum11= total(food11)
by commid: egen foodsum13= total(food13)
by commid: egen foodsum14= total(food14)
by commid: egen foodsum15= total(food15)
by commid: egen foodsum18= total(food18)
by commid: egen cigarettessum1= total(spend01)
by commid: egen kerosenesum1= total(spend03)

// generating total community-wide expenditure on all the covered items together 

by commid: gen total = (foodsum1 +foodsum2 +foodsum7 +foodsum11 +foodsum13 +foodsum14 +foodsum15 +foodsum18 +cigarettes + kerosene)

// generating weights for each commodity equivalent to share in total expenditure at community-level 

gen share1 = foodsum1/total  
gen share2 = foodsum2/total
gen share7 = foodsum7/total
gen share11 = foodsum11/total
gen share13 = foodsum13/total
gen share14 = foodsum14/total
gen share15 = foodsum15/total
gen share18 = foodsum18/total
gen sharecig = cigarettes/total
gen sharekerosene = kerosene/total

egen mprice01=mean(price01)
egen mprice02=mean(price02)
egen mprice07=mean(price07)
egen mprice11=mean(price11)
egen mprice13=mean(price13)
egen mprice14=mean(price14)
egen mprice15=mean(price15)
egen mprice18=mean(price18)
egen mpricecig=mean(pricecig)
egen mpricekerosene=mean(pricekerosene)

gen index1= share1*(price01/mprice01)
gen index2= share2*(price02/mprice02)
gen index7= share7*(price07/mprice07)
gen index11= share11*(price11/mprice11)
gen index13= share13*(price13/mprice13)
gen index14= share14*(price14/mprice14)
gen index15= share15*(price15/mprice15)
gen index18= share18*(price18/mprice18)
gen indexcig= sharecig*(pricecig/mpricecig)
gen indexkerosene_c2 = sharekerosene*(pricekerosene/mpricekerosene)

g cpi1=index1

foreach i in 2 7 11 13 14 15 18 cig kerosene {
replace cpi1=cpi1+index`i'
}

g share01=share1
g share02=share2
g share07=share7

g wprsum=0

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
replace wprsum=wprsum+share`i'*price`i'
}

egen mwprsum=mean(wprsum)

g cpi2=wprsum/mwprsum

su cpi1, detail
su cpi2,detail

// trim very low values (outliers)

replace cpi1=. if cpi1<0.5
replace cpi2=. if cpi2<0.5

// aggregate expenditure 

egen seatv=rowtotal(eatv01-eatv20)
egen sownv=rowtotal(ownv01-ownv20)
egen sgiftv=rowtotal(giftv01-giftv20)

gen foodexp= 2*(seatv+sownv+sgiftv)

egen sspyr=rowtotal(spyr01-spyr23)
egen sspndyr=rowtotal(spndyr07-spndyr11)
egen sspend=rowtotal(spend01-spend06)

g nfexp=(0.083333333*(sspyr+sspndyr))+sspend

gen texp= foodexp + nfexp
gen percapexp = texp/hhsize

su percapexp,detail

// trim extreme values

replace percapexp=. if percapexp<170 & percapexp>3644

gen realpce1 =percap/cpi1
gen realpce2=percap/cpi2

su realpce2
tab typesite,su(realpce2)
tab chldeth,su(realpce2)

g povline=433.43/0.93 if typesite==2
replace povline=563.16/0.98 if typesite==1

g abspov=realpce2<povline if realpce2<. & povline<.

tab typesite,su(abspov)

keep childid foodexp nfexp texp percapexp realpce2

label var foodexp    "Expenditure in food items"
label var nfexp      "Expenditure in non-food items"
label var texp       "Total Expenditure"
label var percapexp  "Total expenditure per capita"
label var realpce2   "Real per capita expenditure"

sort childid
save "$r2yc/constructed/consumption_2yc.dta", replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep childid realpce2   
rename  realpce2       tconsrpc
label var tconsrpc     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\india\consumption_2Oc.dta", replace


ppppppppppppppppppppppppppppppppppppppppp