********************************* WEALTH INDEX PERU R1 YC AND OC *********************************

// NOTE. TAKEN FROM REVISED VERSIONS OF PERU'S DO FILES


clear
set mem 600m
set more off


global r1yc			N:\Quantitative research\Data\r1\peru\yc\
global r1oc 		N:\Quantitative research\Data\r1\peru\oc\


****************************** YOUNGER COHORT ******************************************************

use "$r1yc\raw\pechildlevel1yrold.dta", clear

***** HOUSING QUALITY INDEX

*1. Scaled sleeping rooms per person.

tab numroom, m
gen room_pc=numroom/hhsize
codebook room_pc

egen min_sca=min(room_pc)
egen max_sca=max(room_pc)
gen scaled_room=(room_pc-min_sca)/(max_sca-min_sca)
sum scaled_room

*2. Floor material.

tab floor, m
gen floor1=(floor==4|floor==5)

*3. Roof material.

tab roof, m
gen roof1=(roof==5|roof==4|roof==6)

*4. Wall material.

tab wall, m
gen wall1=(wall==1)

***** CONSUMER DURABLES INDEX

sum radio-tocad
recode radio-tocad (9=.)

gen radio1=radio==1
gen tv1=tv==1
gen fridge1=fridge==1
gen moto1=motor==1
gen car1=car==1
gen plancha1=plancha==1
gen phone1=phone==1
gen mobphone1=mobphone==1
gen bike1=bike==1
gen cocgas1=cocgas==1
gen licua1=licua==1
gen toca1=tocad==1

**** HOUSING QUALITY INDEX

*1. Source of drinking water.

tab drwater, m
gen drwater1=drwater==1|drwater==2

*2. Having electricity.

tab elec, m
gen elec1=elec==1

*3. Type of toilet.

tab toilet, m
gen toilet1=toilet==1|toilet==3

*4. Type of cooking fuel.

tab cooking, m
gen cooking1=(cooking==5|cooking==3)

***** WEALTH INDEX.

****Housing Quality Index.
egen ind_hq_r1=rsum(scaled_room floor1 roof1 wall1)
replace ind_hq_r1=ind_hq_r1/4

****Consumer Variables Index.
egen ind_consvar_r1=rsum(radio1 tv1 fridge1 bike1 moto1 car1 mobphone1 phone1 toca1 plancha cocgas1 licua1)
replace ind_consvar_r1=ind_consvar_r1/12

****Housing Services Index.
egen ind_sshouse_r1=rsum(drwater1 elec1 toilet1 cooking1)
replace ind_sshouse_r1=ind_sshouse_r1/4

****Total Index
egen wealth_index_r1=rsum(ind_hq ind_consvar ind_sshouse_r1)
replace wealth_index_r1=wealth_index_r1/3

sum wealth_index*_r1
label var wealth_index_r1 "Wealth index"

label var ind_hq_r1 "Housing quality index"

label var ind_consvar_r1 "Consumer durables index"

label var ind_sshouse_r1 "Housing services index"

keep childid  ind_hq_r1 ind_consvar_r1 ind_sshouse_r1 wealth_index_r1
rename ind_hq_r1         hq
rename ind_consvar_r1    cd
rename ind_sshouse_r1    sv
rename wealth_index_r1   wi

sort childid
save "$r1yc\constructed\wi_1yc.dta",replace


***************************************** OLDER COHORT **************************************

use "$r1oc\raw\pechildlevel8yrold.dta" , clear

**** HOUSING QUALITY INDEX

** 1. Scaled sleeping rooms per person.

tab numroom, m
gen room_pc=numroom/hhsize
codebook room_pc

egen min_sca=min(room_pc)
egen max_sca=max(room_pc)
gen scaled_room=(room_pc-min_sca)/(max_sca-min_sca)
sum scaled_room

** 2. Floor material.

tab floor, m
gen floor1=(floor==4|floor==5)

** 3. Roof material.

tab roof, m
gen roof1=(roof==5|roof==4|roof==6)

** 4. Wall material.

tab wall, m
gen wall1=(wall==1)

**** CONSUMER DURABLES INDEX

sum radio-tocad
recode radio-tocad (8=.)

gen radio1=radio==1
gen tv1=tv==1
gen fridge1=fridge==1
gen moto1=motor==1
gen car1=car==1
gen plancha1=plancha==1
gen phone1=phone==1
gen mobphone1=mobphone==1
gen bike1=bike==1
gen cocgas1=cocgas==1
gen licua1=licua==1
gen toca1=tocad==1

**** HOUSING SERVICES INDEX

*1. Source of drinking water.

gen drwater1=drwater==1|drwater==2

*2. Having electricity.

tab elec, m
gen elec1=elec==1

*3. Type of toilet.

tab toilet, m
gen toilet1=toilet==1|toilet==3

*4. Type of cooking fuel.

tab cooking, m
gen cooking1=(cooking==5|cooking==3)


***** WEALTH INDEX.

****Housing Quality Index.
egen ind_hq_r1=rsum(scaled_room floor1 roof1 wall1)
replace ind_hq_r1=ind_hq_r1/4

****Consumer Variables Index.
egen ind_consvar_r1=rsum(radio1 tv1 fridge1 bike1 moto1 car1 mobphone1 phone1 toca1 plancha cocgas1 licua1)
replace ind_consvar_r1=ind_consvar_r1/12

****Housing Services Index.
egen ind_sshouse_r1=rsum(drwater1 elec1 toilet1 cooking1)
replace ind_sshouse_r1=ind_sshouse_r1/4

****Total Index
egen wealth_index_r1=rsum(ind_hq ind_consvar ind_sshouse_r1)
replace wealth_index_r1=wealth_index_r1/3

sum wealth_index*_r1
label var wealth_index_r1 "Wealth index"

label var ind_hq_r1 "Housing quality index"

label var ind_consvar_r1 "Consumer durables index"

label var ind_sshouse_r1 "Housing services index"

keep childid  ind_hq_r1 ind_consvar_r1 ind_sshouse_r1 wealth_index_r1

rename ind_hq_r1         hq
rename ind_consvar_r1    cd
rename ind_sshouse_r1    sv
rename wealth_index_r1   wi

sort childid

save "$r1oc\constructed\wi_1oc",replace

