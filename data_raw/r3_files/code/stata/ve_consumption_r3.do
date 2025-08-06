******************************** CONSUMPTION AGGREGATE - VIETNAM R3 YC AND OC **************************

clear
set mem 50m
set more off
capture log close


global r3		  N:\Quantitative research\Data\r3\vietnam\

* YOUNGER COHORT

global r3yc		  N:\Quantitative research\Data\r3\vietnam\yc\
global r2yc		  N:\Quantitative research\Data\r2\vietnam\yc\
global r1yc		  N:\Quantitative research\Data\r1\vietnam\yc\

* OLDER COHORT

global r3oc		  N:\Quantitative research\Data\r3\vietnam\oc\
global r2oc		  N:\Quantitative research\Data\r2\vietnam\oc\
global r1oc		  N:\Quantitative research\Data\r1\vietnam\oc\

*global cons_prob    S:\country_reports\Vietnam\consump_probs
*global data_sk      N:\Quantitative research\Data\r3\vietnam\constructed\
*global output_sk    N:\Quantitative research\Data\r3\vietnam\constructed\



***extract child interview date (to fill in missing hh interview date)
use "$r3yc/raw/vn_yc_childlevel.dta", clear
keep childid cdint
qui append using "$r3oc/raw/vn_oc_childlevel.dta"
keep childid cdint
sort childid 
tempfile cdint
save `cdint'

***CPI
use "$r3/constructed/povlines&deflators.dta", clear
keep if year>=2009 & year!=.
label define typesite 1 "urban" 2 "rural"
label values typesite_region typesite
gen povlinenom2006_reg = .
replace povlinenom2006_reg = povline_jan2006*cpireg_jan2006*cpi_urban if typesite_region==1 
replace povlinenom2006_reg = povline_jan2006*cpireg_jan2006*cpi_rural if typesite_region==2 
gen povlinenom2008_reg = .
replace povlinenom2008_reg = povline_jan2008*cpireg_jan2008*cpi08_urban if typesite_region==1
replace povlinenom2008_reg = povline_jan2008*cpireg_jan2008*cpi08_rural if typesite_region==2
ren region_id region_2
sort region_2 year month
tempfile CPI
save `CPI'


***typesite round 3
use childid typesite clustid region using "$r3yc/raw/tblYoungerTrackingInformation.dta", clear
sort childid
tempfile temp
save `temp'
use childid typesite clustid region using "$r3oc/raw/tblOlderTrackingInformation.dta"
append using `temp'
replace typesite=1 if childid=="VN170012" | childid=="VN180066" | childid=="VN180072" | childid=="VN180087" | childid=="VN180092" | childid=="VN180094" | childid=="VN180109" | childid=="VN200078"
replace typesite=2 if childid=="VN030007" | childid=="VN050015" | childid=="VN050032" | childid=="VN070002"
replace typesite=2 if childid=="VN121052"
gen region_2 =.
replace region_2 = 51 if region==41
replace region_2 = 52 if region==42
replace region_2 = 53 if region==44 & (clustid<=4 | (clustid>=90 & typesite==2))
replace region_2 = 54 if region==44 & ((clustid>=17 & clustid<=20) | (clustid>=90 & typesite==1))   
replace region_2 = 55 if region==45  
replace region_2 = 56 if region==46  
replace region_2 = 57 if region==47  
replace region_2 = 58 if region==43 | region==99  
label define region_2 51 "Northern Uplands" 52 "Red River Delta" 53 "Phu Yen" 54 "Da Nang" 55 "Highlands" 56 "South Eastern" 57 "Mekong River Delta"  58 "Other"  
label values region_2 region_2
replace region_2=58 if region_2==.

sort childid
tempfile typesite_r3
save  `typesite_r3'


***merge cpi in with main data
use "$r3yc/raw/vn_yc_householdlevel.dta",clear
drop typesite region clustid
drop if childid=="vn170052"
gen cohort = 1 
qui append using "$r3oc/raw/vn_oc_householdlevel.dta"
replace cohort = 2 if cohort==.
sort childid 
merge childid using `cdint'
drop if _m==2
drop _m
replace dint = cdint if dint==.
***TEMP: for now replace missing dates to "mean date"
bys cohort: egen temp = mean(dint)
bys cohort: gen dint_mean = round(temp) 
replace dint = dint_mean if dint==. 


***MERGE IN RUR_URB DATA
replace childid = "VN090082" if childid=="vn090082"
sort childid
merge childid using `typesite_r3'
assert _m==3
drop _m


***MERGE IN CPI DATA
gen month = month(dint)
gen year  = year(dint)

*some cleaning (TEMP)
replace year = 2009 if year==2010 & month>1
replace month = 9 if year==2009 & month<9 
replace year = 2009 if year==2010 & (month==10 | month==11)
sort region_2 year month 
merge region_2 year month using `CPI'

assert _m==3 if dint!=.
drop if _m==2 /*round 2 CPI or dint==.*/
drop _m
gen cpi = .
replace cpi=cpi_urb if typesite==1
replace cpi=cpi_rur if typesite==2
drop cpi_rur cpi_urb 

keep childid cpi typesite cpireg_jan2008 region_2 povlinenom2006_reg povlinenom2008_reg
sort childid
tempfile cpi
save `cpi'

use "$r3yc/raw/pda/pda_yc.dta", clear
ren pda_num pda
append using "$r3oc/raw/pda/pda_oc.dta"
sort childid
tempfile pda
save `pda'

use "$r3yc/constructed/hhsize_yc_adeqhhsize.dta", clear
append using "$r3oc/constructed/hhsize_oc_adeqhhsize.dta"
sort childid 
tempfile adeq
save `adeq'

***MERGE ALL THE BITS TOGETHER
use 				"$r3yc/raw/vn_yc_householdlevel.dta", clear
drop typesite region clustid
gen cohort = 1 
qui append using 		"$r3oc/raw/vn_oc_householdlevel.dta"
replace cohort = 2 if cohort==.
label define cohort 1 "YC" 2 "OC"
label values cohort cohort
sort childid
merge childid using `cpi'
drop _m
sort childid 
duplicates drop

merge childid using `pda'
keep if _m==3
drop _m

sort childid
merge childid using `adeq'
assert _m==3
drop _m

sort childid
merge childid using `typesite_r3', unique
assert _m==3
drop _m

***merge in a dataset of proposed "wrong entries"

**********************************************************************************************************
******************************FOOD EXPENDITURE****************************************************************************
**********************************************************************************************************
***big outliers
*replace eatvr300=. if eatvr300>250 & cohort==2
foreach i in 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 /*
*/ 319 320 321 324 { 
gen eatvr`i'_pc  = eatvr`i'/hhsize
gen gftvr`i'_pc = gftvr`i'/hhsize
gen ownvr`i'_pc  = ownvr`i'/hhsize
}

/*IGNORE
***Checking data issues
*preserve
keep if cohort==2
keep childid region_2 eatvr* gftvr* ownvr*
sort childid 
merge childid using "$cons_prob/consumpflag_oc.dta"
assert _m!=2
gen flag = _m==3
drop _m

*/


***temporary code until data is fixed
ren eatvr320 eatvr320_old
ren eatvr319 eatvr320
ren eatvr318 eatvr319
ren eatvr317 eatvr318
ren eatvr316 eatvr317
ren eatvr315 eatvr316
ren eatvr314 eatvr315
ren eatvr313 eatvr314
ren eatvr312 eatvr313
ren eatvr311 eatvr312
ren eatvr310 eatvr311
ren eatvr309 eatvr310
ren eatvr308 eatvr309
ren eatvr307 eatvr308
ren eatvr306 eatvr307
ren eatvr305 eatvr306
ren eatvr304 eatvr305
ren eatvr303 eatvr304
ren eatvr320_old eatvr303

foreach i in 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 /*
*/ 319 320 321 324 { 
qui replace eatvr`i'=0 	if eatvr`i'==. | eatvr`i'<0 
qui replace gftvr`i'=0 	if gftvr`i'==. | gftvr`i'<0
qui replace ownvr`i'=0 	if ownvr`i'==. | ownvr`i'<0
}

***rename items omitted from aggs for comparability
foreach i in eat gft own {
ren `i'vr300 `i'_00
}
foreach i in 17 18 19 20 21{
ren ownvr3`i' own_`i'
} 

egen fdeat=rsum 		(eatvr*) 			/*value of food bought and consumed in the last 2 weeks (excluding oil seeds)*/ 
egen fdown=rsum 	  	(ownvr*) 			/*value of food consumed from own harvest/stock in the last 2 weeks (exclusing prepared food, packaged sweets, coffee/tea, soft drinks, alcohol as not asked for stocks in R2*/
egen fdgift=rsum 	  	(gftvr*)			/*value of food consumed from gifts in the last 2 weeks*/


egen foodexp_nom2w   	=rsum (fdeat fdown fdgift)
gen  foodexp_real2w   	=foodexp_nom2w/cpi
gen  foodexp_pcnom2w	=foodexp_nom2w/hhsize
gen  foodexp_pcreal2w   =foodexp_real2w/hhsize
gen  foodexp_nompm 	=foodexp_nom2w*2				/*value of food consumed (bought, own stocks, gifts) in the last 4 weeks*/
gen  foodexp_realpm 	=foodexp_real2w*2
gen  foodexp_pcnompm 	=foodexp_nompm/hhsize				/*value of food consumed (bought, own stocks, gifts) in the last 4 weeks*/
gen  foodexp_pcrealpm 	=foodexp_realpm/hhsize

label var foodexp_nompm    "Nominal value of consumed food per month: bought, own stock, gifts"
label var foodexp_realpm   "Real value of consumed food per month: bought, own stock, gifts (2006 prices)"
label var foodexp_pcnompm  "Nominal value of consumed food per month per capita: bought, own stock, gifts"
label var foodexp_pcrealpm "Real val of monthly consumed food per capita: bought own stock gifts 2006 prices"


*******************************************

foreach i in 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 324 { 
egen foodexp_nom2w`i'=rsum(eatvr`i' ownvr`i' gftvr`i')
gen foodexp_real2w`i'=foodexp_nom2w`i'/cpi
gen foodexp_pcreal2w`i'=foodexp_real2w`i'/hhsize
} 

***items not included in stock questions in r2 (so excluded in r3)
foreach i in 317 318 319 320 321 {
egen foodexp_nom2w`i'=rsum(eatvr`i' gftvr`i')
gen  foodexp_real2w`i'=foodexp_nom2w`i'/cpi
gen  foodexp_pcreal2w`i'=foodexp_real2w`i'/hhsize
}

***item not in r2 so not in r3 aggregate
egen foodexp_nom2w300=rsum(eat_00 gft_00 own_00)
gen foodexp_real2w300=foodexp_nom2w300/cpi
gen foodexp_pcreal2w300=foodexp_real2w300/hhsize


***tabulate for comparison with R2 (Younger Cohort)
tabstat foodexp_pcreal2w* if cohort==1, stats(mean sd) save
tabstatmat a
mat food=a'

tabstat foodexp_pcreal2w* if pda==0 & cohort==1, stats(mean sd) save
tabstatmat a
mat food_paper=a'

tabstat foodexp_pcreal2w* if pda==1 & cohort==1, stats(mean sd) save
tabstatmat a
mat food_pda=a'

xml_tab food food_paper food_pda, save ($output_sk\foodexpr3.xml) replace /*
*/   format(SCLR3 NCLR2) sheet(FOOD_YC)


***tabulate for comparison with R2 (Older Cohort)
tabstat foodexp_pcreal2w* if cohort==2, stats(mean sd) save
tabstatmat a
mat food=a'

tabstat foodexp_pcreal2w* if pda==0 & cohort==2, stats(mean sd) save
tabstatmat a
mat food_paper=a'

tabstat foodexp_pcreal2w* if pda==1 & cohort==2, stats(mean sd) save
tabstatmat a
mat food_pda=a'

xml_tab food food_paper food_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(FOOD_OC)

********************************************
preserve
keep childid foodexp_nompm foodexp_realpm foodexp_pcnompm foodexp_pcrealpm
sort childid
tempfile foodexp_pm
save `foodexp_pm'
restore

**********************************************************************************************************
************************SCHOOL EXPENDITURE**********************************************************************************
**********************************************************************************************************

***big outlier
replace spyrr311=. if spyrr311>10000

foreach i in 309 310 311 312 313 314 315 316 324 325 {
qui replace spyrr`i'=0 if spyrr`i'==. | spyrr`i'<0 
}

gen educexp_nompyr= (spyrr309+spyrr310+spyrr311+spyrr312+spyrr313+spyrr314+spyrr315+spyrr316) /*school related expenditure in the last 12 months (incl uniforms, schooling fees, tuition payment, school books) */
gen educexp_realpyr= educexp_nompyr/cpi  /*school related expenditure in the last 12 months (incl uniforms, schooling fees, tuition payment, school books) */
gen educexp_pcnompyr= educexp_nompyr/hhsize
gen educexp_pcrealpyr= educexp_realpyr/hhsize

/******NB: Because expenditure on school fees/donation for adult men and women was not asked in Round 2 it is excluded from Round 3 aggregates in order to ensure comparability accross rounds ****/   
gen educexp_nompm=educexp_nompyr/12 		 /*school expenditure per month*/
gen educexp_realpm=educexp_realpyr/12 
gen educexp_pcnompm = educexp_nompm/hhsize
gen educexp_pcrealpm = educexp_realpm/hhsize

label var educexp_nompm "Nominal value of school expenditure per month"
label var educexp_realpm "Real value of school expenditure per month (in 2006 prices)"
label var educexp_pcnompm "Nominal value of per capita school expenditure per month"
label var educexp_pcrealpm "Real value of per capita school expenditure per month (in 2006 prices)"


*******************************************
foreach i in spyrr309 spyrr310 spyrr311 spyrr312 spyrr324 spyrr325 spyrr313 spyrr314 spyrr315 spyrr316 {
gen `i'_real = `i'/cpi
gen `i'_pcreal = `i'_real/hhsize
} 

***tabulate for comparison with R2
tabstat spyrr309_p* spyrr310_p* spyrr311_p* spyrr312_p* spyrr324_p* spyrr325_p* spyrr313_p* spyrr314_p* spyrr315_p* spyrr316_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat educ=a'

tabstat spyrr309_p* spyrr310_p* spyrr311_p* spyrr312_p* spyrr324_p* spyrr325_p* spyrr313_p* spyrr314_p* spyrr315_p* spyrr316_p* if pda==0 & cohort==1, stats(mean sd) save
tabstatmat a
mat educ_paper=a'

tabstat spyrr309_p* spyrr310_p* spyrr311_p* spyrr312_p* spyrr324_p* spyrr325_p* spyrr313_p* spyrr314_p* spyrr315_p* spyrr316_p* if pda==1 & cohort==1, stats(mean sd) save
tabstatmat a
mat educ_pda=a'


xml_tab educ educ_paper educ_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(EDUC_YC)
*******************************************
***tabulate for comparison with R2 (OLDER COHORT)
tabstat spyrr309_p* spyrr310_p* spyrr311_p* spyrr312_p* spyrr324_p* spyrr325_p* spyrr313_p* spyrr314_p* spyrr315_p* spyrr316_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat educ=a'

tabstat spyrr309_p* spyrr310_p* spyrr311_p* spyrr312_p* spyrr324_p* spyrr325_p* spyrr313_p* spyrr314_p* spyrr315_p* spyrr316_p* if pda==0 & cohort==2, stats(mean sd) save
tabstatmat a
mat educ_paper=a'

tabstat spyrr309_p* spyrr310_p* spyrr311_p* spyrr312_p* spyrr324_p* spyrr325_p* spyrr313_p* spyrr314_p* spyrr315_p* spyrr316_p* if pda==1 & cohort==2, stats(mean sd) save
tabstatmat a
mat educ_pda=a'


xml_tab educ educ_paper educ_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(EDUC_OC)
*******************************************

preserve
keep childid educexp_nompm educexp_realpm educexp_pcnompm educexp_pcrealpm 
sort childid
tempfile educexp_pm
save `educexp_pm'
restore

**********************************************************************************************************
***************************MEDICAL EXPENDITURE*******************************************************************************
**********************************************************************************************************

foreach i in r317 r318 319a 319b r320 {
replace spyr`i'=0 if spyr`i'<0 | spyr`i'==.
gen spyr`i'_real = spyr`i'/cpi
gen spyr`i'_pcreal = spyr`i'_real/hhsize
}

*omitting expenditure on prescriptions
gen 	medexp_nompyr    = spyrr317+spyrr320 		/*medical expenditure in the last 12 months*/
gen 	medexp_realpyr   = medexp_nompyr/cpi	
gen 	medexp_pcnompyr  = medexp_nompyr/hhsize
gen 	medexp_pcrealpyr = medexp_realpyr/hhsize
gen  	medexp_nompm     = medexp_nompyr/12   		/*medical expenditure in the last month*/ 
gen  	medexp_realpm    = medexp_nompm/cpi
gen   medexp_pcnompm   = medexp_nompm/hhsize
gen   medexp_pcrealpm  = medexp_realpm/hhsize

label var medexp_nompm    "Nominal value of medical expenditure per month"
label var medexp_realpm   "Real value of medical expenditure per month (in 2006 prices)"
label var medexp_pcnompm  "Nominal value of per capita medical expenditure per month"
label var medexp_pcrealpm "Real value of per capita medical expenditure per month (in 2006 prices)"

*******************************************
***tabulate for comparison with R2 (YC)
tabstat spyrr317_p* spyrr318_p* spyr319a_p* spyr319b_p*  spyrr320_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat med=a'

tabstat spyrr317_p* spyrr318_p* spyr319a_p* spyr319b_p*  spyrr320_p* if pda==0 & cohort==1, stats(mean sd) save
tabstatmat a
mat med_paper=a'

tabstat spyrr317_p* spyrr318_p* spyr319a_p* spyr319b_p*  spyrr320_p* if pda==1 & cohort==1, stats(mean sd) save
tabstatmat a
mat med_pda=a'

xml_tab med med_paper med_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(MED_YC)
*******************************************
***tabulate for comparison with R2 (OC)
tabstat spyrr317_p* spyrr318_p* spyr319a_p* spyr319b_p*  spyrr320_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat med=a'

tabstat spyrr317_p* spyrr318_p* spyr319a_p* spyr319b_p*  spyrr320_p* if pda==0 & cohort==2, stats(mean sd) save
tabstatmat a
mat med_paper=a'

tabstat spyrr317_p* spyrr318_p* spyr319a_p* spyr319b_p*  spyrr320_p* if pda==1 & cohort==2, stats(mean sd) save
tabstatmat a
mat med_pda=a'

xml_tab med med_paper med_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(MED_OC)
*******************************************

preserve
keep childid medexp_nompm medexp_realpm medexp_pcnompm  medexp_pcrealpm
sort childid
tempfile medexp_pm
save `medexp_pm'
restore

**********************************************************************************************************
*************************OTHER NON-FOOD EXPENDITURE*******************************************************
**********************************************************************************************************

****NON-FOOD EXPENDITURE 1

replace spndr305=. if spndr305==37000
replace spndr306=. if spndr306==30000

foreach i in 301 302 303 304 305 306 307{
qui replace spndr`i'=0 if spndr`i'<0 | spndr`i'==. 
gen spndr`i'_real = spndr`i'/cpi
gen spndr`i'_pcreal = spndr`i'_real/hhsize
}

egen nfoodexp1_nompm	=rsum(spndr301 spndr302 spndr303 spndr304 spndr305) 			/*expenditure on cigs, perasonal care, firewood, kero etc, internet, public transport in the last month*/
gen  nfoodexp1_pcnompm	=nfoodexp1_nompm/hhsize
gen  nfoodexp1_realpm	=nfoodexp1_nompm/cpi
gen  nfoodexp1_pcrealpm	=nfoodexp1_realpm/hhsize

***tabulate for comparison with R2 (YC)
tabstat spndr301_p* spndr302_p* spndr303_p* spndr304_p* spndr305_p* spndr306_p* spndr307_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat nfood1=a'

tabstat spndr301_p* spndr302_p* spndr303_p* spndr304_p* spndr305_p* spndr306_p* spndr307_p* if pda==0 & cohort==1, stats(mean sd) save
tabstatmat a
mat nfood1_paper=a'

tabstat spndr301_p* spndr302_p* spndr303_p* spndr304_p* spndr305_p* spndr306_p* spndr307_p* if pda==1 &  cohort==1, stats(mean sd) save
tabstatmat a
mat nfood1_pda=a'

xml_tab nfood1 nfood1_paper nfood1_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(NFOOD1_YC)


***tabulate for comparison with R2 (OC)
tabstat spndr301_p* spndr302_p* spndr303_p* spndr304_p* spndr305_p* spndr306_p* spndr307_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat nfood1=a'

tabstat spndr301_p* spndr302_p* spndr303_p* spndr304_p* spndr305_p* spndr306_p* spndr307_p* if pda==0 & cohort==2, stats(mean sd) save
tabstatmat a
mat nfood1_paper=a'

tabstat spndr301_p* spndr302_p* spndr303_p* spndr304_p* spndr305_p* spndr306_p* spndr307_p* if pda==1 & cohort==2, stats(mean sd) save
tabstatmat a
mat nfood1_pda=a'

xml_tab nfood1 nfood1_paper nfood1_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(NFOOD1_OC)


****NON-FOOD EXPENDITURE 2
***big outlier
replace bgyrr314=0 if bgyrr314==1000000
replace bgyrr322=0 if bgyrr322==1500000 | bgyrr322==2000500


foreach i in 307 312 322 320 313 314 315 316 317 319 321 304 305 306 311  {
replace bgyrr`i'=0 if bgyrr`i'<0 | bgyrr`i'==. 
gen bgyrr`i'_real = bgyrr`i'/cpi
gen bgyrr`i'_pcreal = bgyrr`i'_real/hhsize
}

/*
egen nfoodexp2_nompyr=rsum(bgyrr307 bgyrr312 bgyrr322 bgyrr320 bgyrr313 bgyrr314 /*
*/ bgyrr315 bgyrr316 bgyrr317 bgyrr319 bgyrr321 bgyrr304 bgyrr305 bgyrr306 bgyrr311)
*/

****without dwelling maintenance & business license tax
egen nfoodexp2_nompyr=rsum(bgyrr307 bgyrr320 bgyrr313 /*
*/ bgyrr315 bgyrr316 bgyrr317 bgyrr319 bgyrr321 bgyrr304 bgyrr305 bgyrr306 bgyrr311)

gen nfoodexp2_pcnompyr	=nfoodexp2_nompyr/hhsize
gen nfoodexp2_realpyr 	=nfoodexp2_nompyr/cpi
gen nfoodexp2_pcrealpyr	=nfoodexp2_realpyr/hhsize
gen nfoodexp2_nompm     =nfoodexp2_nompyr/12
gen nfoodexp2_pcnompm	=nfoodexp2_nompm/hhsize
gen nfoodexp2_realpm    =nfoodexp2_realpyr/12
gen nfoodexp2_pcrealpm	=nfoodexp2_realpm/hhsize

***tabulate for comparison with R2 (YC)
tabstat bgyrr307_p* bgyrr312_p* bgyrr322_p* bgyrr320_p* bgyrr313_p* bgyrr314_p* bgyrr315_p* bgyrr316_p* bgyrr317_p* bgyrr319_p* /*
*/ bgyrr321_p* bgyrr304_p* bgyrr305_p* bgyrr306_p* bgyrr311_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat nfood2=a'

tabstat bgyrr307_p* bgyrr312_p* bgyrr322_p* bgyrr320_p* bgyrr313_p* bgyrr314_p* bgyrr315_p* bgyrr316_p* bgyrr317_p* bgyrr319_p* /*
*/ bgyrr321_p* bgyrr304_p* bgyrr305_p* bgyrr306_p* bgyrr311_p* if pda==0 & cohort==1, stats(mean sd) save
tabstatmat a
mat nfood2_paper=a'

tabstat bgyrr307_p* bgyrr312_p* bgyrr322_p* bgyrr320_p* bgyrr313_p* bgyrr314_p* bgyrr315_p* bgyrr316_p* bgyrr317_p* bgyrr319_p* /*
*/ bgyrr321_p* bgyrr304_p* bgyrr305_p* bgyrr306_p* bgyrr311_p* if pda==1 & cohort==1, stats(mean sd) save
tabstatmat a
mat nfood2_pda=a'

xml_tab nfood2 nfood2_paper nfood2_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(NFOOD2_YC)


***tabulate for comparison with R2 (OC)
tabstat bgyrr307_p* bgyrr312_p* bgyrr322_p* bgyrr320_p* bgyrr313_p* bgyrr314_p* bgyrr315_p* bgyrr316_p* bgyrr317_p* bgyrr319_p* /*
*/ bgyrr321_p* bgyrr304_p* bgyrr305_p* bgyrr306_p* bgyrr311_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat nfood2=a'

tabstat bgyrr307_p* bgyrr312_p* bgyrr322_p* bgyrr320_p* bgyrr313_p* bgyrr314_p* bgyrr315_p* bgyrr316_p* bgyrr317_p* bgyrr319_p* /*
*/ bgyrr321_p* bgyrr304_p* bgyrr305_p* bgyrr306_p* bgyrr311_p* if pda==0 & cohort==2, stats(mean sd) save
tabstatmat a
mat nfood2_paper=a'

tabstat bgyrr307_p* bgyrr312_p* bgyrr322_p* bgyrr320_p* bgyrr313_p* bgyrr314_p* bgyrr315_p* bgyrr316_p* bgyrr317_p* bgyrr319_p* /*
*/ bgyrr321_p* bgyrr304_p* bgyrr305_p* bgyrr306_p* bgyrr311_p* if pda==1 & cohort==2, stats(mean sd) save
tabstatmat a
mat nfood2_pda=a'

xml_tab nfood2 nfood2_paper nfood2_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(NFOOD2_OC)


****NON-FOOD EXPENDITURE 3
foreach i in 301 302 303 304 305 306 307 308 {
replace spyrr`i'=0 if spyrr`i'<0 | spyrr`i'==.   
gen spyrr`i'_real = spyrr`i'/cpi
gen spyrr`i'_pcreal = spyrr`i'_real/hhsize
}

egen nfoodexp3_nompyr=rsum(spyrr301- spyrr308)			/*expenditure on adult & children's clothing and footware in the last year*/
gen nfoodexp3_pcnompyr	=nfoodexp3_nompyr/hhsize
gen nfoodexp3_realpyr 	=nfoodexp3_nompyr/cpi
gen nfoodexp3_pcrealpyr	=nfoodexp3_realpyr/hhsize
gen nfoodexp3_nompm     =nfoodexp3_nompyr/12
gen nfoodexp3_pcnompm	=nfoodexp3_nompm/hhsize
gen nfoodexp3_realpm    =nfoodexp3_realpyr/12
gen nfoodexp3_pcrealpm	=nfoodexp3_realpm/hhsize

***tabulate for comparison with R2 (YC)
tabstat spyrr301_p* spyrr302_p* spyrr303_p* spyrr304_p* spyrr305_p* spyrr306_p* spyrr307_p* spyrr308_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat nfood3=a'

tabstat spyrr301_p* spyrr302_p* spyrr303_p* spyrr304_p* spyrr305_p* spyrr306_p* spyrr307_p* spyrr308_p* if pda==0 & cohort==1, stats(mean sd) save
tabstatmat a
mat nfood3_paper=a'

tabstat spyrr301_p* spyrr302_p* spyrr303_p* spyrr304_p* spyrr305_p* spyrr306_p* spyrr307_p* spyrr308_p* if pda==1 & cohort==1, stats(mean sd) save
tabstatmat a
mat nfood3_pda=a'

xml_tab nfood3 nfood3_paper nfood3_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(NFOOD3_YC)

***tabulate for comparison with R2 (OC)
tabstat spyrr301_p* spyrr302_p* spyrr303_p* spyrr304_p* spyrr305_p* spyrr306_p* spyrr307_p* spyrr308_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat nfood3=a'

tabstat spyrr301_p* spyrr302_p* spyrr303_p* spyrr304_p* spyrr305_p* spyrr306_p* spyrr307_p* spyrr308_p* if pda==0 & cohort==2, stats(mean sd) save
tabstatmat a
mat nfood3_paper=a'

tabstat spyrr301_p* spyrr302_p* spyrr303_p* spyrr304_p* spyrr305_p* spyrr306_p* spyrr307_p* spyrr308_p* if pda==1 & cohort==2, stats(mean sd) save
tabstatmat a
mat nfood3_pda=a'

xml_tab nfood3 nfood3_paper nfood3_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(NFOOD3_OC)

****NON-FOOD EXPENDITURE 4
***outliers
replace spyrr327=0 if spyrr327==191000 | spyrr327==200000 

foreach i in 321 322 326 327 {
replace spyrr`i'=0 if spyrr`i'<0 | spyrr`i'==.   
gen spyrr`i'_real = spyrr`i'/cpi
gen spyrr`i'_pcreal = spyrr`i'_real/hhsize
}

*leaving out "other non-food expenditure"
egen nfoodexp4_nompyr		=rsum (spyrr321 spyrr322 spyrr326)	/*expenditure on cinema/entertainment, child presents, other transport (non-public), other non-food in the last year*/ 
gen  nfoodexp4_pcnompyr		=nfoodexp4_nompyr/hhsize
gen  nfoodexp4_realpyr 		=nfoodexp4_nompyr/cpi
gen  nfoodexp4_pcrealpyr	=nfoodexp4_realpyr/hhsize
gen  nfoodexp4_nompm     	=nfoodexp4_nompyr/12
gen  nfoodexp4_pcnompm		=nfoodexp4_nompm/hhsize
gen  nfoodexp4_realpm    	=nfoodexp4_realpyr/12
gen  nfoodexp4_pcrealpm		=nfoodexp4_realpm/hhsize

*******************************************
***tabulate for comparison with R2 (YC)
tabstat spyrr321_p* spyrr322_p* spyrr326_p* spyrr327_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat nfood4=a'

tabstat spyrr321_p* spyrr322_p* spyrr326_p* spyrr327_p* if pda==0 & cohort==1, stats(mean sd) save
tabstatmat a
mat nfood4_paper=a'

tabstat spyrr321_p* spyrr322_p* spyrr326_p* spyrr327_p* if pda==1 & cohort==1, stats(mean sd) save
tabstatmat a
mat nfood4_pda=a'

xml_tab nfood4 nfood4_paper nfood4_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(NFOOD4_YC)

*******************************************
***tabulate for comparison with R2 (OC)
tabstat spyrr321_p* spyrr322_p* spyrr326_p* spyrr327_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat nfood4=a'

tabstat spyrr321_p* spyrr322_p* spyrr326_p* spyrr327_p* if pda==0 & cohort==2, stats(mean sd) save
tabstatmat a
mat nfood4_paper=a'

tabstat spyrr321_p* spyrr322_p* spyrr326_p* spyrr327_p* if pda==1 & cohort==2, stats(mean sd) save
tabstatmat a
mat nfood4_pda=a'

xml_tab nfood4 nfood4_paper nfood4_pda, save ($output_sk\foodexpr3.xml) append /*
*/   format(SCLR3 NCLR2) sheet(NFOOD4_OC)


****TOTAL OTHER NON-FOOD EXPENDITURE (nfood1 nfood2 nfood3 nfood4)
gen nfoodexpoth_nompm	= nfoodexp1_nompm+nfoodexp2_nompm+nfoodexp3_nompm+nfoodexp4_nompm 
gen nfoodexpoth_pcnompm	= nfoodexp1_pcnompm+nfoodexp2_pcnompm+nfoodexp3_pcnompm+nfoodexp4_pcnompm
gen nfoodexpoth_realpm	= nfoodexp1_realpm+nfoodexp2_realpm+nfoodexp3_realpm+nfoodexp4_realpm
gen nfoodexpoth_pcrealpm	= nfoodexp1_pcrealpm+nfoodexp2_pcrealpm+nfoodexp3_pcrealpm+nfoodexp4_pcrealpm

label var nfoodexpoth_nompm 	"Nom value: non-food expend (excl med, educ, jewellery)per month"
label var nfoodexpoth_realpm 	"Real value: non-food expend (excl med, educ, jewellery)per month (2006 prices)"
label var nfoodexpoth_pcnompm 	"Nom value: non-food expend (excl med, educ, jewellery)per cap per month"
label var nfoodexpoth_pcrealpm 	"Real val: non-food expend (excl med educ jewellery)per cap per month 2006 prices"

preserve
keep childid typesite region_2 cohort pda cpi cpireg_jan2008  povlinenom2006_reg povlinenom2008_reg nfoodexpoth_nompm nfoodexpoth_pcnompm nfoodexpoth_realpm nfoodexpoth_pcrealpm 
sort childid
tempfile nfoodexpoth_pm
save `nfoodexpoth_pm'
restore


**********************************************************************************************************
*************************TOTAL EXPENDITURE*********************************************************************************
**********************************************************************************************************

use `foodexp_pm', clear
sort childid
merge childid using `educexp_pm'
assert _m==3
drop _m
sort childid 
merge childid using `medexp_pm'
assert _m==3
drop _m
sort childid
merge childid using `nfoodexpoth_pm'
assert _m==3
drop _m

***total expenditure
gen totexp_nompm		=foodexp_nompm+medexp_nompm+educexp_nompm+nfoodexpoth_nompm
gen totexp_pcnompm	=foodexp_pcnompm+medexp_pcnompm+educexp_pcnompm+nfoodexpoth_pcnompm
gen totexp_realpm		=foodexp_realpm+medexp_realpm+educexp_realpm+nfoodexpoth_realpm
gen totexp_pcrealpm	=foodexp_pcrealpm+medexp_pcrealpm+educexp_pcrealpm+nfoodexpoth_pcrealpm

***total non-food expenditure
gen nfoodexp_nompm	=medexp_nompm+educexp_nompm+nfoodexpoth_nompm	
gen nfoodexp_pcnompm    =medexp_pcnompm+educexp_pcnompm+nfoodexpoth_pcnompm
gen nfoodexp_realpm	=medexp_realpm+educexp_realpm+nfoodexpoth_realpm
gen nfoodexp_pcrealpm   =medexp_pcrealpm+educexp_pcrealpm+nfoodexpoth_pcrealpm

label var nfoodexp_nompm 	"Nom value: non-food expend per month"
label var nfoodexp_realpm 	"Real value: non-food expend per month (2006 prices)"
label var nfoodexp_pcnompm 	"Nom value: non-food expend per cap per month"
label var nfoodexp_pcrealpm 	"Real val: non-food expend per cap per month 2006 prices"


***relative poverty 
poverty totexp_pcrealpm if cohort==1, line(-1) h gen(relpov_yc) 
poverty totexp_pcrealpm if cohort==2, line(-1) h gen(relpov_oc)



gen poor1 = (totexp_pcnompm *12)< povlinenom2006_reg
label var poor1 "poor using 2006 poverty line"
gen poor2 = (totexp_pcnompm *12)< povlinenom2008_reg
label var poor2 "poor using 2008 poverty line"


preserve 
keep if cohort==1
sort childid 
save "$r3yc/constructed/consumption_3yc.dta", replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY
keep childid totexp_pcrealpm
rename  totexp_pcrealpm tconsrpc
label var tconsrpc     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\vietnam\consumption_3yc.dta", replace
restore


preserve 
keep if cohort==2
sort childid 
save "$r3oc/constructed/consumption_3oc.dta", replace
* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY
keep childid totexp_pcrealpm
rename  totexp_pcrealpm tconsrpc
label var tconsrpc     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\vietnam\consumption_3oc.dta", replace
restore
