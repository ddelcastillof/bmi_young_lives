********************************* PERU: CONSUMPTION AGGREGATES (round 2)*****************************************
************************************** YOUNGER COHORT ***************************************************************

clear
set mem 50m
set more off


global data 	N:\Quantitative research\Data\r2\peru\
use 			"$data\yc\raw\pechildlevel5yrold.dta", clear


***** I. FOOD CONSUMPTION
recode fdsp* valfrm* valprs* valown* valpay* valb4* valov* (-77 -88 -99=0)

* FOOD BOUGHT
egen gastom_food_r2=rsum(fdsp* )

* FOOD FROM OWN SOURCES AND OWN SUPPLIES 
egen autoconsm_food_r2=rsum(valfrm* valprs* valown* valpay* valb4*)

* FOOD LEFT OVER
egen nocons_food_r2=rsum(valov*)

*Food consumption per month.
gen totg_food_r2=(gastom_food_r2+ autoconsm_food_r2 - nocons_food_r2)*2
sum gastom_food_r2 autoconsm_food_r2 nocons_food_r2 totg_food_r2

label variable gastom_food_r2 	"Total food bought in two weeks R2"
label variable autoconsm_food_r2 	"Total food from own sources in two weeks R2"
label variable nocons_food_r2 	"Total food left over in two weeks R2"
label var totg_food_r2 			"Total Food Consumption per month R2"

keep childid gastom*_food_r2 autoconsm*_food_r2 nocons*_food_r2 totg*_food_r2 spyr* spend* spndyr*  hhsize

*******II. NON-FOOD CONSUMPTION

recode spyr* spend* spndyr* (-77 -88 -99 -88.8=0)

sum spend*
sum spndyr*
sum spyr*

egen gcloth_r2=rsum(spyr01 spyr02 spyr02a spyr03 spyr04 spyr04a spyr05 spyr06 spyr07 spyr08)
replace gcloth_r2=gcloth_r2/12
sum gcloth_r2

egen geduc_r2=rsum(spyr09 spyr10 spyr11a spyr12a spyr13a spyr15 spyr16)
replace geduc_r2=geduc_r2/12
sum geduc_r2

egen gmed_r2=rsum(spyr17 spyr18)
replace gmed_r2=gmed_r2/12
sum gmed_r2

egen gocio_r2=rsum(spyr19)
replace gocio_r2=gocio_r2/12
sum gocio_r2

egen gother_r2=rsum(spyr20 spyr22 spyr23 spyr24)
replace gother_r2=gother_r2/12
sum gother_r2
*we exclude jewelry in "other" nonfood expenditure.

egen gu30d_r2=rsum(spend*)
sum gu30d_r2

egen gu12m_r2=rsum(spndyr*)
replace gu12m_r2=gu12m_r2/12
sum gu12m_r2

egen totg_nfood_r2=rsum(gcloth_r2 geduc_r2 gmed_r2 gocio_r2 gother_r2 gu30d_r2 gu12m_r2)
sum totg_nfood_r2

label variable gcloth_r2 	"Clothes and footwear consumption per month R2"
label variable geduc_r2 	"Education consumption per month R2"
label variable gmed_r2 		"Doctors and medicine consumption per month R2"
label variable gocio_r2 	"Entertainment consumption per month R2"
label variable gother_r2 	"Other consumption per month R2"
label variable gu30d_r2 	"Last 30 days consumption per month R2"
label variable gu12m_r2 	"Last 12 months consumption per month R2"
label variable totg_nfood_r2 	"Total nonfood consumption per month R2"

******* SUMMARY: CONSUMPTION AND INCOME - SECOND ROUND

sum gastom_food_r2 autoconsm_food_r2 nocons_food_r2 totg_food_r2

*without expenditure on transfers for comparability with round 3.
egen totg_r2=rsum(totg_food_r2 totg_nfood_r2)
label variable totg_r2 "Total consumption per month R2 (comparable)"

gen totg_pc_r2=totg_r2/hhsize
label variable totg_pc_r2 "Total per capita consumption per month R2"

sort childid
merge childid using "$data\yc\constructed\deflactores_yls_yc.dta", keep(def_full_r2)
tab _merge
drop if _merge==2
drop _merge

gen totg_real_r2=totg_r2/def_full_r2
label variable totg_real_r2 "Total real consumption per month R2"

gen totg_real_pc_r2=totg_real_r2/hhsize
label variable totg_real_pc_r2 "Total real per capita consumption per month R2"

sum totg_r2 totg_real_r2

sort childid
keep childid totg_food_r2 totg_nfood_r2 totg_r2 totg_pc_r2 totg_real_r2 totg_real_pc_r2

rename totg_food_r2     totg_food	
rename totg_nfood_r2    totg_nfood 
rename totg_r2 		totg
rename totg_pc_r2 	totg_pc 
rename totg_real_r2     totg_real 
rename totg_real_pc_r2  totg_real_pc

save "$data\yc\constructed\consumption_2yc.dta",replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep childid totg_real_pc
rename  totg_real_pc    tconsrpa
label var tconsrpa     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\peru\consumption_2yc.dta", replace

*************************************** OLDER COHORT ***************************************

use "$data\oc\raw\pechildlevel12yrold.dta", clear

****** I. FOOD CONSUMPTION


recode fdsp* valfrm* valprs* valown* valpay* valb4* valov*(-77 -88 -99=0)

*Food bought.
egen gastom_food_r2=rsum(fdsp* )

*Foods supplied from own sources and own supplies.
egen autoconsm_food_r2=rsum(valfrm* valprs* valown* valpay* valb4*)

*Food left over.
egen nocons_food_r2=rsum(valov*)

*Food consumption per month.
gen totg_food_r2=(gastom_food_r2+ autoconsm_food_r2 - nocons_food_r2)*2

sum gastom_food_r2 autoconsm_food_r2 nocons_food_r2 totg_food_r2

sort childid

label variable gastom_food_r2 "Total food bought in two weeks R2"

label variable autoconsm_food_r2 "Total food from own sources in two weeks R2"

label variable nocons_food_r2 "Total food left over in two weeks R2"

label var totg_food_r2 "Total Food Consumption per month R2"

keep childid gastom*_food_r2 autoconsm*_food_r2 nocons*_food_r2 totg*_food_r2 spyr* spend* spndyr*  hhsize

******II. NON-FOOD CONSUMPTION
recode spyr* spend* spndyr* (-77 -88 -99 -88.8=0)

sum spend*
sum spndyr*
sum spyr*

egen gcloth_r2=rsum(spyr01 spyr02 spyr02a spyr03 spyr04 spyr04a spyr05 spyr06 spyr07 spyr08)
replace gcloth_r2=gcloth_r2/12
sum gcloth_r2

egen geduc_r2=rsum(spyr09 spyr10 spyr11a spyr12a spyr13a spyr15 spyr16)
replace geduc_r2=geduc_r2/12
sum geduc_r2

egen gmed_r2=rsum(spyr17 spyr18)
replace gmed_r2=gmed_r2/12
sum gmed_r2

egen gocio_r2=rsum(spyr19)
replace gocio_r2=gocio_r2/12
sum gocio_r2

egen gother_r2=rsum(spyr20 spyr22 spyr23 spyr24)
replace gother_r2=gother_r2/12
sum gother_r2
*we exclude jewelry in "other" nonfood expenditure.

egen gu30d_r2=rsum(spend*)
sum gu30d_r2

egen gu12m_r2=rsum(spndyr*)
replace gu12m_r2=gu12m_r2/12
sum gu12m_r2

egen totg_nfood_r2=rsum(gcloth_r2 geduc_r2 gmed_r2 gocio_r2 gother_r2 gu30d_r2 gu12m_r2)
sum totg_nfood_r2

label variable gcloth_r2 "Clothes and footwear consumption per month R2"
label variable geduc_r2 "Education consumption per month R2"
label variable gmed_r2 "Doctors and medicine consumption per month R2"
label variable gocio_r2 "Entertainment consumption per month R2"
label variable gother_r2 "Other consumption per month R2"
label variable gu30d_r2 "Last 30 days consumption per month R2"
label variable gu12m_r2 "Last 12 months consumption per month R2"
label variable totg_nfood_r2 "Total nonfood consumption per month R2"

******* SUMMARY: CONSUMPTION AND INCOME - SECOND ROUND
sum gastom_food_r2 autoconsm_food_r2 nocons_food_r2 totg_food_r2

*without expenditure on transfers for comparability with round 3.
egen totg_r2=rsum(totg_food_r2 totg_nfood_r2)
label variable totg_r2 "Total consumption per month R2 (comparable)"

gen totg_pc_r2=totg_r2/hhsize
label variable totg_pc_r2 "Total per capita consumption per month R2"

sort childid
merge childid using "$data\oc\constructed\deflactores_yls_oc.dta", keep(def_full_r2)
tab _merge
drop if _merge==2
drop _merge

gen totg_real_r2=totg_r2/def_full_r2
label variable totg_real_r2 "Total real consumption per month R2"

gen totg_real_pc_r2=totg_real_r2/hhsize
label variable totg_real_pc_r2 "Total real per capita consumption per month R2"

sum totg_r2 totg_real_r2

sort childid
keep childid totg_food_r2 totg_nfood_r2 totg_r2 totg_pc_r2 totg_real_r2 totg_real_pc_r2

rename totg_food_r2 	totg_food
rename totg_nfood_r2    totg_nfood 
rename totg_r2		totg 
rename totg_pc_r2		totg_pc 
rename totg_real_r2 	totg_real 
rename totg_real_pc_r2	totg_real_pc

save "$data\oc\constructed\consumptionr_2oc.dta",replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep childid totg_real_pc
rename  totg_real_pc    tconsrpa
label var tconsrpa     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\peru\consumption_2oc.dta", replace

