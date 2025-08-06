***********************************************************************************************************************
***************************** RECONSTRUCTION OF WEALTH INDEX - ETHIOPIA (round 1) *************************************
*********************************************** YOUNGER COHORT  *******************************************************


clear
set mem 50m
set more off

use "N:\Quantitative research\Data\r1\Ethiopia\yc\raw\etchildlevel1yrold.dta", clear


******************************** HOUSEHOLD QUALITY INDEX - HQ1 (HQ already exists in the file) **************************** 

recode numroom (99=.)

gen hq2=(numroom/hhsize)/1.5
replace hq2=1 if hq2>1


*if wall's material is brick/concrete
replace hq2=hq2+1 if wall==1

*if roof's material is concrete/ iron/ tiles/ galvanised iron
replace hq2=hq2+1 if roof==4 | roof==5 | roof==6

*if floor's material is cement/ tiles/ laminated material
replace hq2=hq2+1 if floor==4 | floor==5

gen hq1=hq2/4

label var hq1 "Household quality index"

********************************* CONSUMER DURABLES - CD1 ******************************************************************

recode radio     (2 99=0)
recode fridge    (2 99=0)
recode tv        (2 99=0)
recode bike      (2 99=0)
recode motor     (2 99=0)
recode car       (2 99=0)
recode mobphone  (2 99=0)
recode phone     (2 99=0)
recode bedsted   (2 99=0)
recode tabchair  (2 99=0)
recode sofa      (2 99=0)

gen cd1=(radio+bike+tv+motor+car+mobphone+phone+bedsted+tabchair+sofa)/10

label var cd1 "Consumer durables index"


****************************************** SERVICES QUALITY INDEX SV1 *********************************************************

*GEN SERVICES - SV1

gen sv2=0

replace sv2=sv2+1 if elec==1
gen elec1=elec==1

replace sv2=sv2+1 if drwater==1 | drwater==2 | drwater==3
gen drwater1=drwater==1 | drwater==2 | drwater==3
/*includes public standpipe, as suggested by Tassew*/

replace sv2=sv2+1 if (toilet==1 | toilet==2)
gen toilet1=toilet==1 | toilet==2

replace sv2=sv2+1 if (cooking==2 | cooking==4)

gen sv1=sv2/4

label var sv1 "Services quality index"


******************************************** WEALTH INDEX YOUNGER COHORT *************************************************
gen wi_1yc=(hq1+cd1+sv1)/3

label var wi_1yc "Wealth Index - Round 1 YC"

keep childid wi_1yc hq1 sv1 cd1

rename hq1 hq
rename sv1 sv
rename cd1 cd
rename wi_1yc wi

sort childid
save "N:\Quantitative research\Data\r1\Ethiopia\yc\constructed\wi_1yc", replace

***************************************************************************************************************************
**************************************** OLDER COHORT ROUND 1 - 8 YEAR OLD ************************************************
***************************************************************************************************************************

clear
set mem 50m
set more off


use "N:\Quantitative research\Data\r1\Ethiopia\oc\raw\etchildlevel8yrold.dta", clear

******************************** HOUSEHOLD QUALITY INDEX - HQ1 (HQ already exists in the file) **************************** 

recode numroom (99=.)

gen hq2=(numroom/hhsize)/1.5
replace hq2=1 if hq2>1

*if wall's material is brick/concrete
replace hq2=hq2+1 if wall==1
*replace hq2=hq2+1 if wallr1r2==1

*if roof's material is concrete/ iron/ tiles/ galvanised iron
replace hq2=hq2+1 if roof==4 | roof==5 | roof==6

*if floor's material is cement/ tiles/ laminated material
replace hq2=hq2+1 if floor==4 | floor==5

gen hq1=hq2/4

label var hq1 "Household quality index"

********************************* CONSUMER DURABLES - CD1 ******************************************************************

recode radio     (2 99=0)
recode fridge    (2 99=0)
recode tv        (2 99=0)
recode bike      (2 99=0)
recode motor     (2 99=0)
recode car       (2 99=0)
recode mobphone  (2 99=0)
recode phone     (2 99=0)
recode bedsted   (2 99=0)
recode tabchair  (2 99=0)
recode sofa      (2 99=0)


gen cd1=(radio+bike+tv+motor+car+mobphone+phone+bedsted+tabchair+sofa)/10

label var cd1 "Consumer durables index"


****************************************** SERVICES QUALITY INDEX SV1 *********************************************************

*GEN SERVICES - SV1

gen sv2=0

replace sv2=sv2+1 if elec==1
gen elec1=elec==1

replace sv2=sv2+1 if drwater==1 | drwater==2 | drwater==3
gen drwater1=drwater==1 | drwater==2 | drwater==3
/*includes public standpipe, as suggested by Tassew*/

replace sv2=sv2+1 if (toilet==1 | toilet==2)
gen toilet1=toilet==1 | toilet==2

replace sv2=sv2+1 if (cooking==2 | cooking==4)

gen sv1=sv2/4

label var sv1 "Services quality index"


******************************************** WEALTH INDEX *****************************************************************
gen wi_1oc=(hq1+cd1+sv1)/3

label var wi_1oc "Wealth Index - Round 1 OC"

sum wi_1oc

keep childid wi_1oc hq1 cd1 sv1

rename hq1 hq
rename sv1 sv
rename cd1 cd
rename wi_1oc wi

sort childid
save "N:\Quantitative research\Data\r1\Ethiopia\oc\constructed\wi_1oc", replace


