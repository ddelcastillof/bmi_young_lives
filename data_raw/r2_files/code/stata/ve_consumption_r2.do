*******************************************************************************************************
/*THIS DO-FILE CREATES ALTERNATIVE CONSUMPTION AGGREGATES USING MORE APPROPRIATE DEFLATORS ETC*/

clear
set mem 50m
set more off
capture log close


********************** YOUNGER COHORT *****************************************

global r3		N:\Quantitative research\Data\r3\vietnam\
global r3yc		N:\Quantitative research\Data\r3\vietnam\yc\
global r2yc		N:\Quantitative research\Data\r2\vietnam\yc\

********************** OLDER COHORT *******************************************
global r3oc		N:\Quantitative research\Data\r3\vietnam\oc\
global r2oc		N:\Quantitative research\Data\r2\vietnam\oc\

*global data_sk    N:\Quantitative research\Data\r2\vietnam\constructed\
*global output_sk  N:\Quantitative research\Data\r2\vietnam\constructed\

***ROUND 3 PANEL VARIABLE

use 			"$r3yc/raw/vn_yc_householdlevel.dta", clear
keep childid
qui append using	"$r3oc/raw/vn_oc_householdlevel.dta"
keep childid 
sort childid
tempfile   r3
save 	    `r3'

***PREPARE CPI DATA

use 			"$r3/constructed/povlines&deflators.dta", clear
keep if year<2009
label define typesite 1 "urban" 2 "rural"
label values typesite_region typesite
gen povlinenom2006_reg = .
replace povlinenom2006_reg = povline_jan2006*cpireg_jan2006*cpi_urban if typesite_region==1 
replace povlinenom2006_reg = povline_jan2006*cpireg_jan2006*cpi_rural if typesite_region==2 
ren region_id region_2
sort region_2 year month 
tempfile    CPI
save       `CPI'

***MERGE PRICE INDICES INTO MAIN DATA

use 			"$r2yc/raw/vnchildlevel5yrold.dta",clear
keep childid dint typesite region
qui append using 	"$r2oc/raw/vnchildlevel12yrold.dta"

replace typesite = 2 if clustid==1 | clustid==2 |clustid==3 |clustid==4 |clustid==5 |clustid==6 |clustid==7 |clustid==8 |clustid==9 |clustid==10 | clustid==11 |clustid==12 |clustid==13 |clustid==14 |clustid==15 |clustid==16 
replace typesite = 1 if clustid==17 |clustid==18 | clustid==19 |clustid==20		
replace typesite = 2 if childid=="VN060026" /* a case in Ben Tre */	
replace typesite = 2 if childid=="VN110007" /* a case in Lai Chau */	
replace typesite = 2 if childid=="VN121052" /* a case in Long Thanh, Dong Nai */	

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

drop region
replace region_2=58 if region_2==.
keep childid dint typesite region_2
gen year = year(dint)
gen month = month(dint)
sort region_2 year month
merge region_2 year month using `CPI'
keep if _m==3
drop _m

*** rural_urban specific cpi
gen cpi = .
replace cpi=cpi_urb if typesite==1
replace cpi=cpi_rur if typesite==2
label var cpi 	"Consumer price index (typesite specific)"
keep childid povlinenom2006_reg cpi cpireg_jan2006 typesite region_2
sort childid 
tempfile cpi 
save `cpi'

use 			"$r2yc/raw/vnchildlevel5yrold.dta",clear
drop region typesite
gen cohort = 1 
qui append using 	"$r2oc/raw/vnchildlevel12yrold.dta"
drop region typesite
replace cohort = 2 if cohort==.
label define cohort 1 "YC" 2 "OC"
label values cohort cohort
sort childid 
merge childid using `cpi'
assert _m==3
drop _m


**********************************************************************************************************
******************************FOOD EXPENDITURE************************************************************
**********************************************************************************************************

foreach i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 {
replace eatv`i'=0 if eatv`i'<0
replace giftv`i'=0 if giftv`i'<0
gen eatv`i'_pc = eatv`i'/hhsize
gen giftv`i'_pc = giftv`i'/hhsize
}

foreach i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 20 {
replace ownv`i'=0 if ownv`i'<0
gen ownv`i'_pc = ownv`i'/hhsize
}

egen fdeat=rsum 		( eatv01- eatv20) 	/*value of food bought and consumed in the last 2 weeks*/ 
egen fdown=rsum 		( ownv01- ownv20) 	/*value of food consumed from own harvest/stock in the last 2 weeks*/
egen fdgift=rsum  	( giftv01- giftv20)	/*value of food consumed from gifts in the last 2 weeks*/
egen foodexp_nom2w=rsum (fdeat fdown fdgift)
gen foodexp_real2w=foodexp_nom2w/cpi
gen foodexp_pcnom2w= foodexp_nom2w/hhsize
gen foodexp_pcreal2w= foodexp_real2w/hhsize
gen foodexp_nompm 	=foodexp_nom2w*2					/*value of food consumed (bought, own stocks, gifts) in the last 4 weeks*/
gen foodexp_realpm	=foodexp_real2w*2
gen foodexp_pcnompm 	=foodexp_nompm/hhsize				/*value of food consumed (bought, own stocks, gifts) in the last 4 weeks*/
gen foodexp_pcrealpm	=foodexp_realpm/hhsize


label var foodexp_nompm "Nominal value of consumed food per month: bought, own stock, gifts"
label var foodexp_realpm "Real value of consumed food per month: bought, own stock, gifts (2006 prices)"


foreach i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15  20  {
egen foodexp_nom2w_`i' = rsum(eatv`i' ownv`i' giftv`i')
gen foodexp_real2w_`i' = foodexp_nom2w_`i'/cpi
gen foodexp_pcreal2w_`i' = foodexp_real2w_`i'/hhsize
}

foreach i in 16 17 18 19  {
egen foodexp_nom2w_`i' = rsum(eatv`i' giftv`i')
gen foodexp_real2w_`i' = foodexp_nom2w_`i'/cpi
gen foodexp_pcreal2w_`i' = foodexp_real2w_`i'/hhsize
}
***tabulate for comparison with R3 (Younger cohort)
tabstat foodexp_pcreal2w_* if cohort==1, stats(mean sd) save
tabstatmat a
mat food=a'

xml_tab food, save ($output_sk\foodexpr2.xml) replace /*
*/   format(SCLR3 NCLR2) sheet(FOOD_YC)

***tabulate for comparison with R3 (Older cohort)
tabstat foodexp_pcreal2w_* if cohort==2, stats(mean sd) save
tabstatmat a
mat food=a'

xml_tab food, save ($output_sk\foodexpr2.xml) append /*
*/   format(SCLR3 NCLR2) sheet(FOOD_OC)

preserve
keep childid foodexp_nompm foodexp_realpm foodexp_pcnompm foodexp_pcrealpm
sort childid
tempfile foodexp_pm
save `foodexp_pm'
restore

**********************************************************************************************************
************************SCHOOL EXPENDITURE****************************************************************
**********************************************************************************************************

***Changing all negative values to 0
foreach i in 09 10 11 12 13 14 15 16 {
replace spyr`i'=0 if spyr`i'<0
gen spyr`i'_real=spyr`i'/cpi
gen spyr`i'_pcreal=spyr`i'_real/hhsize
}

egen 	educexp_nompyr=   	rsum(spyr09-spyr16) 	      /*school related expenditure in the last 12 months (incl uniforms, schooling fees, tuition payment, school books) */
gen  	educexp_realpyr=  	educexp_nompyr/cpi
gen 	educexp_pcnompyr=  	educexp_nompyr/hhsize
gen 	educexp_pcrealpyr=  educexp_realpyr/hhsize
gen  	educexp_nompm=   	educexp_nompyr/12 		/*school expenditure per month*/
gen  	educexp_realpm=  	educexp_realpyr/12 
gen  	educexp_pcnompm= 	educexp_nompm/hhsize
gen  	educexp_pcrealpm= 	educexp_realpm/hhsize


***tabulate for comparison with R3 (YC)

tabstat spyr09_p* spyr10_p* spyr11_p* spyr12_p* spyr13_p* spyr14_p* spyr15_p* spyr16_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat educ=a'

xml_tab educ, save ($output_sk\foodexpr2.xml) append /*
*/   format(SCLR3 NCLR2) sheet(SCHOOL_YC)

***tabulate for comparison with R3 (OC)

tabstat spyr09_p* spyr10_p* spyr11_p* spyr12_p* spyr13_p* spyr14_p* spyr15_p* spyr16_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat educ=a'

xml_tab educ, save ($output_sk\foodexpr2.xml) append /*
*/   format(SCLR3 NCLR2) sheet(SCHOOL_OC)

preserve
keep childid educexp_nompm educexp_realpm educexp_pcnompm educexp_pcrealpm  
sort childid
tempfile educexp_pm
save `educexp_pm'
restore

**********************************************************************************************************
***************************MEDICAL EXPENDITURE************************************************************
**********************************************************************************************************

foreach i in 17 18 {
replace spyr`i'=0 if spyr`i'<0
gen spyr`i'_real = spyr`i'/cpi
gen spyr`i'_pcreal = spyr`i'_real/hhsize
}

*medical expenditure excluding "other" for comparability with round 3
egen medexp_nompyr	=rsum( spyr17) 

gen 	medexp_realpyr   = medexp_nompyr/cpi	
gen 	medexp_pcnompyr  = medexp_nompyr/hhsize
gen 	medexp_pcrealpyr = medexp_realpyr/hhsize
gen  	medexp_nompm     = medexp_nompyr/12   		
gen  	medexp_realpm    = medexp_nompm/cpi
gen   medexp_pcnompm   = medexp_nompm/hhsize
gen   medexp_pcrealpm  = medexp_realpm/hhsize

label var medexp_nompm "Nominal value of medical expenditure per month"
label var medexp_realpm "Real value of medical expenditure per month (in 2006 prices)"
label var medexp_pcnompm "Nominal value of per capita medical expenditure per month"
label var medexp_pcrealpm "Real value of per capita medical expenditure per month (in 2006 prices)"


***tabulate for comparison with R3 (YC)
tabstat spyr17_p* spyr18_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat med=a'

xml_tab med, save ($output_sk\foodexpr2.xml) append /*
*/   format(SCLR3 NCLR2) sheet(MED_YC)

***tabulate for comparison with R3 (OC)
tabstat spyr17_p* spyr18_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat med=a'

xml_tab med, save ($output_sk\foodexpr2.xml) append /*
*/   format(SCLR3 NCLR2) sheet(MED_OC)

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
foreach i in 01 02 03 04 05 06 {
replace spend`i'=0 if spend`i'<0
gen spend`i'_real = spend`i'/cpi
gen spend`i'_pcreal = spend`i'_real/hhsize
}

egen nfoodexp1_nompm	=rsum(spend01 spend02 spend03 spend04 spend05) 			/*expenditure on cigs, perasonal care, firewood, kero etc, internet, public transport, security in the last month*/
gen  nfoodexp1_pcnompm	=nfoodexp1_nompm/hhsize
gen  nfoodexp1_realpm	=nfoodexp1_nompm/cpi
gen  nfoodexp1_pcrealpm	=nfoodexp1_realpm/hhsize

***tabulate for comparison with R3 (YC)
tabstat spend01_p* spend02_p* spend03_p* spend04_p* spend05_p* spend06_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat nfood1=a'

xml_tab nfood1 , save ($output_sk\foodexpr2.xml) append format(SCLR3 NCLR2) sheet(NFOOD1_YC)

***tabulate for comparison with R3 (OC)
tabstat spend01_p* spend02_p* spend03_p* spend04_p* spend05_p* spend06_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat nfood1=a'

xml_tab nfood1 , save ($output_sk\foodexpr2.xml) append format(SCLR3 NCLR2) sheet(NFOOD1_OC)


****NON-FOOD EXPENDITURE 2
foreach i in 04 05 06 07 20 11 12 13 14 15 16 17 19 21{
replace spndyr`i'    = 0 if spndyr`i'<0
gen spndyr`i'_real   = spndyr`i'/cpi
gen spndyr`i'_pcreal = spndyr`i'_real/hhsize
}

****without dwelling maintenance & one-off family events
egen nfoodexp2_nompyr=rsum(spndyr07 spndyr20 spndyr13 spndyr14 spndyr15 spndyr16 spndyr17 spndyr19 spndyr21 spndyr04 spndyr05 spndyr06)

gen nfoodexp2_pcnompyr	=nfoodexp2_nompyr/hhsize
gen nfoodexp2_realpyr 	=nfoodexp2_nompyr/cpi
gen nfoodexp2_pcrealpyr	=nfoodexp2_realpyr/hhsize
gen nfoodexp2_nompm     =nfoodexp2_nompyr/12
gen nfoodexp2_pcnompm	=nfoodexp2_nompm/hhsize
gen nfoodexp2_realpm    =nfoodexp2_realpyr/12
gen nfoodexp2_pcrealpm	=nfoodexp2_realpm/hhsize

*** tabulate for comparison with R3 (YC)
tabstat spndyr07_p* spndyr12_p* spndyr20_p* spndyr13_p* spndyr14_p* spndyr15_p* spndyr16_p* spndyr17_p* spndyr19_p* spndyr21_p* spndyr04_p* spndyr05_p* spndyr06_p* spndyr11_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat nfood2=a'

xml_tab nfood2, save ($output_sk\foodexpr2.xml) append format(SCLR3 NCLR2) sheet(NFOOD2_YC)

*** tabulate for comparison with R3 (OC)
tabstat spndyr07_p* spndyr12_p* spndyr20_p* spndyr13_p* spndyr14_p* spndyr15_p* spndyr16_p* spndyr17_p* spndyr19_p* spndyr21_p* spndyr04_p* spndyr05_p* spndyr06_p* spndyr11_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat nfood2=a'

xml_tab nfood2, save ($output_sk\foodexpr2.xml) append format(SCLR3 NCLR2) sheet(NFOOD2_OC)


****NON-FOOD EXPENDITURE 3
foreach i in 01 02 03 04 05 06 07 08 {
replace spyr`i'=0 if spyr`i'<0  
gen spyr`i'_real   = spyr`i'/cpi
gen spyr`i'_pcreal = spyr`i'_real/hhsize
}

egen nfoodexp3_nompyr=rsum( spyr01-spyr08)			/*expenditure on adult & children's clothing and footware in the last year*/
gen nfoodexp3_pcnompyr	=nfoodexp3_nompyr/hhsize
gen nfoodexp3_realpyr 	=nfoodexp3_nompyr/cpi
gen nfoodexp3_pcrealpyr	=nfoodexp3_realpyr/hhsize
gen nfoodexp3_nompm     =nfoodexp3_nompyr/12
gen nfoodexp3_pcnompm	=nfoodexp3_nompm/hhsize
gen nfoodexp3_realpm    =nfoodexp3_realpyr/12
gen nfoodexp3_pcrealpm	=nfoodexp3_realpm/hhsize


***tabulate for comparison with R3 (YC)
tabstat spyr01_p*  spyr02_p* spyr03_p* spyr04_p* spyr05_p* spyr06_p* spyr07_p* spyr08_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat nfood3=a'

xml_tab nfood3, save ($output_sk\foodexpr2.xml) append format(SCLR3 NCLR2) sheet(NFOOD3_YC)

***tabulate for comparison with R3 (OC)
tabstat spyr01_p*  spyr02_p* spyr03_p* spyr04_p* spyr05_p* spyr06_p* spyr07_p* spyr08_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat nfood3=a'

xml_tab nfood3, save ($output_sk\foodexpr2.xml) append format(SCLR3 NCLR2) sheet(NFOOD3_OC)


****NON-FOOD EXPENDITURE 4
foreach i in 19 20 22 23 {
replace spyr`i'=0 if spyr`i'<0  
gen spyr`i'_real   = spyr`i'/cpi
gen spyr`i'_pcreal = spyr`i'_real/hhsize
}

*expenditure on entertainment and other excluding "other non-food" for comparability with round 3
egen nfoodexp4_nompyr=rsum(spyr19 spyr20 spyr22 )			
gen nfoodexp4_pcnompyr	=nfoodexp4_nompyr/hhsize
gen nfoodexp4_realpyr 	=nfoodexp4_nompyr/cpi
gen nfoodexp4_pcrealpyr	=nfoodexp4_realpyr/hhsize
gen nfoodexp4_nompm     =nfoodexp4_nompyr/12
gen nfoodexp4_pcnompm	=nfoodexp4_nompm/hhsize
gen nfoodexp4_realpm    =nfoodexp4_realpyr/12
gen nfoodexp4_pcrealpm	=nfoodexp4_realpm/hhsize

***tabulate for comparison with R3 (YC)
tabstat spyr19_p* spyr20_p* spyr22_p* spyr23_p* if cohort==1, stats(mean sd) save
tabstatmat a
mat nfood4=a'

xml_tab nfood4, save ($output_sk\foodexpr2.xml) append format(SCLR3 NCLR2) sheet(NFOOD4_YC)

***tabulate for comparison with R4 (OC)
tabstat spyr19_p* spyr20_p* spyr22_p* spyr23_p* if cohort==2, stats(mean sd) save
tabstatmat a
mat nfood4=a'

xml_tab nfood4, save ($output_sk\foodexpr2.xml) append format(SCLR3 NCLR2) sheet(NFOOD4_OC)


****TOTAL OTHER NON-FOOD EXPENDITURE (nfood1 nfood2 nfood3 nfood4)

gen nfoodexpoth_nompm	= nfoodexp1_nompm+nfoodexp2_nompm+nfoodexp3_nompm+nfoodexp4_nompm 
gen nfoodexpoth_pcnompm	= nfoodexp1_pcnompm+nfoodexp2_pcnompm+nfoodexp3_pcnompm+nfoodexp4_pcnompm
gen nfoodexpoth_realpm	= nfoodexp1_realpm+nfoodexp2_realpm+nfoodexp3_realpm+nfoodexp4_realpm
gen nfoodexpoth_pcrealpm	= nfoodexp1_pcrealpm+nfoodexp2_pcrealpm+nfoodexp3_pcrealpm+nfoodexp4_pcrealpm

label var nfoodexpoth_nompm 		"Nom value: non-food expend (excl med, educ, jewellery)per month"
label var nfoodexpoth_realpm 		"Real value: non-food expend (excl med, educ, jewellery)per month (2006 prices)"
label var nfoodexpoth_pcnompm 	"Nom value: non-food expend (excl med, educ, jewellery)per cap per month"
label var nfoodexpoth_pcrealpm 	"Real val: non-food expend (excl med educ jewellery)per cap per month 2006 prices"

preserve
keep childid typesite region_2 cohort cpi cpireg_jan2006 povlinenom2006_reg nfoodexpoth_nompm nfoodexpoth_pcnompm nfoodexpoth_realpm nfoodexpoth_pcrealpm 
sort childid
tempfile nfoodexpoth_pm
save `nfoodexpoth_pm'
restore

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

preserve
keep if cohort==1
drop cohort
sort childid 
save "$r2yc/constructed/consumption_2yc.dta", replace
* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY
keep childid totexp_pcrealpm 
rename  totexp_pcrealpm tconsrpc
label var tconsrpc     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\vietnam\consumption_2yc.dta", replace
restore

preserve
keep if cohort==2
drop cohort
sort childid 
save "$r2oc/constructed/consumption_2oc.dta", replace
* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY
keep childid totexp_pcrealpm 
rename  totexp_pcrealpm tconsrpc
label var tconsrpc     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\vietnam\consumption_2oc.dta", replace
restore

ppppppp