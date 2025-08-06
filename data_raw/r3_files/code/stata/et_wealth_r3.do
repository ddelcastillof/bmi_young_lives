**********************************
****  WEALTH INDEX - ETHIOPIA ****
**********************************

***********************************
*YOUNGER COHORT ROUND3: 8 YEAR OLD*
***********************************

clear
set mem 600m
use "N:\Quantitative research\Data\r3\ethiopia\yc\raw\et_yc_householdlevel.dta", clear

******************************** HOUSEHOLD QUALITY INDEX - HQ ********************************************************

* 1) 
gen hq1=(numrmr3/hhsize)/1.5
replace hq1=1 if hq1>1

* 2) if wall's material is brick/concrete
replace hq1=hq1+1 if (wallr3==3 | wall==8 |wall==9 | wall==14)

*3) if roof's material is concrete/ iron/ galvanised iron/ tiles & slates
replace hq1=hq1+1 if (roofr3==4 | roofr3==6 | roofr3==15)

*no information about tiles/ slate in R3

*4) if floor's material is cement/tiles; laminated material; concrete/cement; marble stone
replace hq1=hq1+1 if (floorr3==1 | floorr3==6 | floorr3==3 | floorr3==7)


gen hq=hq1/4
label var hq " Household quality index"     // consistent across rounds


* NB. NO MISSING VALUES IN R3 - ALL OTHER MISSING VALUES WILL BE RECODED TO 0

******************************** CONSUMER DURABLES - CD *************************************************************

gen cd=(tv7r3+radio7r3+car7r3+motor7r3+bike7r3+ phone7r3+ mbphn7r3+ tabch7r3+ sofa7r3+ bedst7r3)/10

label var cd "Consumer durables index"      // consistent across rounds - 10 items


********************************* SERVICES QUALITY INDEX - SV ********************************************************
gen sv1=0

*household has electricity
replace sv1=sv1+1 if elecr3==1
gen elec1=elecr3==1

*drinking water piped into dwelling or yard
replace sv1=sv1+1 if drwtrr3==3 | drwtrr3==8 | drwtrr3==10
gen drwater1=drwtrr3==3 | drwtrr3==8 | drwtrr3==10

*Household has own toilet facility
replace sv1=sv1+1 if toiletr3==1 | toiletr3==6
gen toilet1=toiletr3==1 | toiletr3==6

*main cooking fuel is paraffin, kerosene, gas or electricity, 
replace sv1=sv1+1 if cookr3==8 | cookr3==9

gen sv=sv1/4

label var sv "Services quality index"    // consistent across rounds

******************************************** WEALTH INDEX ***************************************************************

gen wi_3yc=(hq+cd+sv)/3

label var wi_3yc "Wealth Index - Round 3 YC"

keep childid wi_3yc hq cd sv 

rename wi_3yc wi

sort childid 

save "N:\Quantitative research\Data\r3\Ethiopia\yc\Constructed\wi_3yc", replace


************************************
*OLDER COHORT ROUND 3 - 15 YEAR OLD*
************************************

use "N:\Quantitative research\Data\r3\ethiopia\oc\raw\et_oc_householdlevel.dta", clear


******************************** HOUSEHOLD QUALITY INDEX - HQ ********************************************************

* 1) 
gen hq1=(numrmr3/hhsize)/1.5
replace hq1=1 if hq1>1

* 2) if wall's material is brick/concrete - added categories mud &  bricks, mud & stones, mud & wood
replace hq1=hq1+1 if (wallr3==3 | wall==8 | wall==9 | wall==14)

*3) if roof's material is concrete/ iron/ galvanised iron/ tiles & slates
replace hq1=hq1+1 if (roofr3==4 | roofr3==6 | roofr3==15)

*4) if floor's material is cement/ tiles; laminated material; concrete/cement; marble stone
replace hq1=hq1+1 if (floorr3==1 | floorr3==6 | floorr3==3 | floorr3==7)


gen hq=hq1/4
label var hq " Household quality index"   // consistent across rounds


* NB. NO MISSING VALUES IN R3 - ALL OTHER MISSING VALUES WILL BE RECODED TO 0

******************************** CONSUMER DURABLES - CD *************************************************************

gen cd=(tv7r3+radio7r3+car7r3+motor7r3+bike7r3+ phone7r3+ mbphn7r3+ tabch7r3+ sofa7r3+ bedst7r3)/10

label var cd "Consumer durables index"   // consistent across rounds


********************************* SERVICES QUALITY INDEX - SV ********************************************************
gen sv1=0

*household has electricity
replace sv1=sv1+1 if elecr3==1
gen elec1=elecr3==1

*drinking water piped into dwelling or yard
replace sv1=sv1+1 if (drwtrr3==3 | drwtrr3==8 | drwtrr3==10)
label l drwtrr3
gen drwater1=drwtrr3==3 | drwtrr3==8 | drwtrr3==10

*Household has own toilet facility
replace sv1=sv1+1 if toiletr3==1 | toiletr3==6
label l toiletr3
gen toilet1=toiletr3==1 | toiletr3==6

*main cooking fuel is paraffin, kerosene, gas or electricity, 
replace sv1=sv1+1 if (cookr3==8 | cookr3==9)
label l LABBH

gen sv=sv1/4

label var sv "Services quality index"   // consistent across rounds

******************************************** WEALTH INDEX ***************************************************************

gen wi_3oc=(hq+cd+sv)/3
lab var wi_3oc "Wealth Index - Round 3 OC"

keep childid wi_3oc hq cd sv 

rename wi_3oc wi

sort childid
save "N:\Quantitative research\Data\r3\Ethiopia\oc\constructed\wi_3oc", replace
