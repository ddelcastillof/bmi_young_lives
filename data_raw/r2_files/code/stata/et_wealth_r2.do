**************************************************************************************************************************
************************************ WEALTH INDEX - ETHIOPIA ROUND 2 *****************************************************
**************************************************************************************************************************

clear
set mem 500m
set more off


**************************************************************************************************************************
***************************************** YOUNGER COHORT - 5 year old ****************************************************
**************************************************************************************************************************

use "N:\Quantitative research\Data\r2\ethiopia\yc\raw\etchildlevel5yrold.dta", clear


************************************ HOUSEHOLD QUALITY INDEX (HQ1) ******************************************************

recode numroom (77 88 = .)

gen hq2=(numroom/hhsize)/1.5
replace hq2=1 if hq2>1

*if wall's material is brick/concrete - we take other categories to be consistent with R1 - added categories: mud & brick; mud & stones; stone
replace hq2=hq2+1 if (wall==3 | wall==8 | wall==9 | wall==14)

*if roof's material is concrete/ galvanised iron/ tiles slates/ corrugated iron
replace hq2=hq2+1 if (roof==4 | roof==6 | roof==15 | roof==20)

*if floor's material is cement/ tiles/ laminated material/ concrete cememt/ marble stone
replace hq2=hq2+1 if (floor==1 | floor==6 | floor==3 | floor==7)

gen hq1=hq2/4

label var hq1 "Housing quality index"


************************************** CONSUMER DURABLES - CD1 **********************************************************

gen cd1=(radio+bike+tv+motor+car+mobphone+phone+bedsted+tabchair+sofa)/10

label var cd1 "Consumer durables index"   // consistent across rounds, using all 10 cds that are recorded in all rounds

************************************** SERVICES - SV1 ********************************************************************

gen sv2=0

replace sv2=sv2+1 if elec==1
gen elec1=elec==1

/*source of drinking water: piped into dwelling/ yard; tube well in dwelling yard*/
replace sv2=sv2+1 if (drwater==3 | drwater==8 | drwater==10)
label l drwater
gen drwater1=drwater==3 | drwater==8 | drwater==10

/*type of toilet facility: flush toilet/ septic tank; pit latrine (household's)*/
replace sv2=sv2+1 if (toilet==1 | toilet==6)
label l toilet
gen toilet1=toilet==1 | toilet==6

/*cooking fuel: gas/ electricity; kerosene/paraffin*/
replace sv2=sv2+1 if (cooking==8 | cooking==9)
label l cooking

gen sv1=sv2/4

label var sv1 " Services quality index"

************************************** WEALTH INDEX **********************************************************************

gen wi_2yc=(hq1+cd1+sv1)/3
label var wi_2yc "Wealth Index - Round 2 YC"

keep childid wi_2yc hq1 cd1 sv1 

rename wi_2yc wi
rename hq1    hq
rename sv1    sv
rename cd1    cd

sort childid
save "N:\Quantitative research\Data\r2\ethiopia\yc\constructed\wi_2yc.dta", replace


*************************************************************************************************************************
************************************** OLDER COHORT - 15 YEARS OLD ******************************************************
*************************************************************************************************************************

use "N:\Quantitative research\Data\r2\ethiopia\oc\raw\etchildlevel12yrold.dta", clear


************************************ HOUSEHOLD QUALITY INDEX (HQ1) ******************************************************

gen hq2=(numroom/hhsize)/1.5
replace hq2=1 if hq2>1

*if wall's material is brick/concrete
replace hq2=hq2+1 if (wall==3 | wall==8 | wall==9 | wall==14)

*if roof's material is concrete/ galvanised iron
replace hq2=hq2+1 if (roof==4 | roof==6 | roof==15 | roof==20)

*if floor's material is cement/ tiles/ laminated material
replace hq2=hq2+1 if (floor==1 | floor==6 | floor==3 | floor==7 | floor==8)

gen hq1=hq2/4

label var hq1 "Housing quality index"        //re-estimated to be consistent


************************************** CONSUMER DURABLES - CD1 **********************************************************

gen cd1=(radio+bike+tv+motor+car+mobphone+phone+bedsted+tabchair+sofa)/10

label var cd1 "Consumer durables index"      // consistent across rounds

************************************** SERVICES - SV1 ********************************************************************

gen sv2=0

replace sv2=sv2+1 if elec==1
gen elec1=elec==1

/*source of drinking water: piped into dwelling/ yard; tube well in dwelling yard*/
replace sv2=sv2+1 if (drwater==3 | drwater==8 | drwater==10)
gen drwater1=drwater==3 | drwater==8 | drwater==10

/*type of toilet facility: flush toilet/ septic tank; pit latrine (household's)*/
replace sv2=sv2+1 if (toilet==1 | toilet==6)
gen toilet1=toilet==1 | toilet==6

/*cooking fuel: gas/ electricity; kerosene/paraffin*/
replace sv2=sv2+1 if (cooking==8 | cooking==9)

gen sv1=sv2/4

label var sv1 " Services quality index"     // consistent across rounds

************************************** WEALTH INDEX **********************************************************************

gen wi_2oc=(hq1+cd1+sv1)/3
label  var wi_2oc "Wealth Index - Round 2 OC"

keep childid wi_2oc hq1 cd1 sv1 

rename wi_2oc wi
rename hq1    hq
rename sv1    sv
rename cd1    cd

sort childid
save "N:\Quantitative research\Data\r2\ethiopia\oc\constructed\wi_2oc.dta", replace




