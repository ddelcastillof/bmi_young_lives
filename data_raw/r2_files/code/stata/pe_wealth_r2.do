********************************* WEALTH INDEX PERU R2 YC AND OC *********************************

// NOTE. TAKEN FROM REVISED VERSIONS OF PERU'S DO FILES


clear
set mem 600m
set more off


global r2yc			N:\Quantitative research\Data\r2\peru\yc\
global r2oc 		N:\Quantitative research\Data\r2\peru\oc\


******************************** YOUNGER COHORT *************************************************

use "$r2yc\constructed\floor_spec.dta", clear
sort childid
tempfile floorspec
save    `floorspec'


use "$r2yc\raw\pechildlevel5yrold.dta", clear
sort childid
merge childid using `floorspec', unique

***** HOUSING QUALITY INDEX

*1. Scaled sleeping rooms per person.

tab numroom, m
recode numroom (99=.)
gen room_pc=numroom/hhsize
codebook room_pc

egen min_sca=min(room_pc)
egen max_sca=max(room_pc)
gen scaled_room=(room_pc-min_sca)/(max_sca-min_sca)
sum scaled_room
 
*2. Floor material.

tab floor, m
gen floor1=(floor==1|floor==5|floor==6|floor==7|floor==8 |(floor==12&(specflr=="PARKET" ///
|specflr=="PARQUET")))

/* for definition - (1) cement/floor tile (5) granite stone (6) laminated material (7) marble stone (8) polished stone (12) other+parket*/

*3. Roof material.

tab roof, m
gen roof1=(roof==4|roof==6|roof==15)

/* for definition - (4) concrete/cement (6) galvanised/ corrugated iron (15) tiles/slates */

*4. Wall material.

tab wall, m
gen wall1=(wall==3|wall==25)

/* for definition - (3) brick/ concrete (25) concrete blocks */

***** CONSUMER DURABLES INDEX

sum radio-tocad

gen radio1=radio==1
gen tv1=tv==1
gen fridge1=fridge==1
gen moto1=motor==1
gen car1=car==1
gen plancha1=plancha==1
gen phone1=phone==1
gen mobphone1=mobphone==1
gen bike1=bike==1
gen cocgas1=mitad==1
gen licua1=licua==1
gen toca1=tocad==1

***** HOUSING SERVICES INDEX

*1. Source of drinking water.

tab drwater, m
gen drwater1=drwater==1|drwater==2

/* for definition - (1) piped water into the house or plot (public network) and (2) well, tubewell with hand pump */

*2. Having electricity.

tab elec, m
gen elec1=elec==1

*3. Type of toilet.

tab toilet, m
gen toilet1=toilet==1|toilet==6

/* for definition - (1) flush toilet/septic tank inside house/ plot; (6) pit/latrine in HH */

*4. Type of cooking fuel.

tab cooking, m
gen cooking1=(cooking==8|cooking==9)

/* for definition - (8) gas/electricity (9) kerosene/paraffin  */

*****INDEX.

****Housing Quality Index.
egen ind_hq_r2=rsum(scaled_room floor1 roof1 wall1)
replace ind_hq_r2=ind_hq_r2/4

****Consumer Variables Index.
egen ind_consvar_r2=rsum(radio1 tv1 fridge1 bike1 moto1 car1 mobphone1 phone1 toca1 plancha cocgas1 licua1)
replace ind_consvar_r2=ind_consvar_r2/12

****Housing Services Index.
egen ind_sshouse_r2=rsum(drwater1 elec1 toilet1 cooking1)
replace ind_sshouse_r2=ind_sshouse_r2/4

****Total Index
egen wealth_index_r2=rsum(ind_hq ind_consvar ind_sshouse_r2)
replace wealth_index_r2=wealth_index_r2/3

sum wealth_index*_r2
label var wealth_index_r2 "Wealth index"

label var ind_hq_r2 "Housing quality index"

label var ind_consvar_r2 "Consumer durables index"

label var ind_sshouse_r2 "Housing services index"

keep childid  wealth_index*_r2 ind_hq_r2 ind_consvar_r2 ind_sshouse_r2

rename wealth_index_r2  wi 
rename ind_hq_r2        hq
rename ind_consvar_r2   cd
rename ind_sshouse_r2   sv

sort childid
save "$r2yc\constructed\wi_2yc.dta", replace

****************************************** OLDER COHORT ******************************************

use "$r2oc\raw\pechildlevel12yrold.dta", clear

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
gen floor1=(floor==1|floor==5|floor==6|floor==7|floor==8) /*|(floor==12&specflr=="PARQUET"))*/

/* for definition - (1) cement/floor tile (5) granite stone (6) laminated material (7) marble stone (8) polished stone (12) other+parket*/

*3. Roof material.

tab roof, m
gen roof1=(roof==4|roof==6|roof==15)

/* for definition - (4) concrete/cement (6) galvanised/ corrugated iron (15) tiles/slates */

*4. Wall material.

tab wall, m
gen wall1=(wall==3|wall==25)

/* for definition - (3) brick/ concrete (25) concrete blocks */

***** CONSUMER DURABLES INDEX

sum radio-tocad
recode radio-tocad (99=.)

gen radio1=radio==1
gen tv1=tv==1
gen fridge1=fridge==1
gen moto1=motor==1
gen car1=car==1
gen plancha1=plancha==1
gen phone1=phone==1
gen mobphone1=mobphone==1
gen bike1=bike==1
gen cocgas1=mitad==1
gen licua1=licua==1
gen toca1=tocad==1

***** HOUSING QUALITY INDEX

*1. Source of drinking water.

tab drwater, m
gen drwater1=drwater==1|drwater==2

/* for definition - (1) piped water into house/ plot (public network) (2) well, tubewell with hand pump*/

*2. Having electricity.

tab elec, m
gen elec1=elec==1

*3. Type of toilet.

tab toilet, m
gen toilet1=toilet==1|toilet==6

/* for definition - (1) flush toilet/septic tank inside house/ plot; (6) pit/latrine in HH */

*4. Type of cooking fuel.

tab cooking, m
gen cooking1=(cooking==8|cooking==9)

/* for definition - (8) gas/electricity (9) kerosene/paraffin  */

***** WEALTH INDEX.

****Housing Quality Index.
egen ind_hq_r2=rsum(scaled_room floor1 roof1 wall1)
replace ind_hq_r2=ind_hq_r2/4

****Consumer Variables Index.
egen ind_consvar_r2=rsum(radio1 tv1 fridge1 bike1 moto1 car1 mobphone1 phone1 toca1 ///
plancha cocgas1 licua1)
replace ind_consvar_r2=ind_consvar_r2/12

****Housing Services Index.
egen ind_sshouse_r2=rsum(drwater1 elec1 toilet1 cooking1)
replace ind_sshouse_r2=ind_sshouse_r2/4

****Total Index
egen wealth_index_r2=rsum(ind_hq ind_consvar ind_sshouse_r2)
replace wealth_index_r2=wealth_index_r2/3

sum wealth_index*_r2
label var wealth_index_r2 "Wealth index"

label var ind_hq_r2 "Housing quality index"

label var ind_consvar_r2 "Consumer durables index"

label var ind_sshouse_r2 "Housing services index"

keep childid wealth_index*_r2 ind_hq_r2 ind_consvar_r2 ind_sshouse_r2
rename wealth_index_r2  wi
rename ind_hq_r2        hq
rename ind_consvar_r2   cd
rename ind_sshouse_r2   sv

sort childid
save "$r2oc\constructed\wi_2oc.dta", replace

