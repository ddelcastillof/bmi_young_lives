********************************* WEALTH INDEX PERU R3 YC AND OC *********************************

// NOTE. TAKEN FROM REVISED VERSIONS OF PERU'S DO FILES


clear
set mem 600m
set more off


global r3yc			N:\Quantitative research\Data\r3\peru\yc\
global r3oc 		N:\Quantitative research\Data\r3\peru\oc\

*******************************************************************************************************

use childid specwatr using "$r3yc\raw\older 1 july 2011\pe_yc_householdlevel.dta", clear
sort childid
tempfile wateryc
save    `wateryc'

use "$r3yc\raw\pe_yc_householdlevel.dta", clear
sort childid 
merge childid using `wateryc', unique
tab _m
drop _m


***** HOUSING QUALITY INDEX

*1. Scaled sleeping rooms per person.

tab numrmr3, m
recode numrmr3 (0=.)
gen room_pc=numrmr3/hhsize
codebook room_pc

egen min_sca=min(room_pc)
egen max_sca=max(room_pc)
gen scaled_room=(room_pc-min_sca)/(max_sca-min_sca)
sum scaled_room

*2. Floor material.

tab floor, m
gen floor1=(floorr3==1|floorr3==5|floorr3==6|floorr3==7|floorr3==8|floorr3==22)

/* for definition. (1) cement/tile (5) granite stone (6) Laminated material (7) marble stone (8) polished stone (22) parket */

*3. Roof material.

tab roof, m
gen roof1=(roofr3==4|roofr3==6|roofr3==15)

/* for definition (4) concrete/cement (6) galvanised/corrugated iron (15) tiles/slates */

*4. Wall material.

tab wall, m
gen wall1=(wallr3==3|wallr3==25)

/* for definition (3) brick/ concrete (25) concrete blocks */

***** CONSUMER DURABLES INDEX

sum radio7r3-rcdp7r3
recode radio7r3-rcdp7r3 (99=.) (88=.)

gen radio1=radio7r3==1
gen tv1=tv7r3==1
gen fridge1=fridg7r3==1
gen moto1=motor7r3==1
gen car1=car7r3==1
gen plancha1=iron7r3==1
gen phone1=phone7r3==1
gen mobphone1=mbphn7r3==1
gen bike1=bike7r3==1
gen cocgas1=mitad7r3==1
gen licua1=blnd7r3==1
gen toca1=rcdp7r3==1

***** HOUSING SERVICES INDEX

*1. Source of drinking water.

tab drwtr, m
gen drwater1=drwtrr3==1|drwtrr3==2|(drwtrr3==9&(specwatr=="AGUA DE POZO TRATADA Y ENTUBADA"| specwatr=="POZO ENTUBADO CON BOMBA ELECTRICA"))

/* for definition (1) piped water to the house/ plot (public network) (2) well, tubewell with hand pump */

*2. Having electricity.

tab elec, m
gen elec1=elecr3==1

*3. Type of toilet.

tab toilet, m
gen toilet1=toiletr3==1|toiletr3==6

/* for definition (1) flush toilet/ septic tank (6) pit latrine (household's)*/

*4. Type of cooking fuel.

tab cook, m
gen cooking1=(cookr3==8|cookr3==9)

/* for definition (8) gas/electricity (9) kerosene/ paraffin */

***** WEALTH INDEX

****Housing Quality Index.
egen ind_hq_r3=rsum(scaled_room floor1 roof1 wall1)
replace ind_hq_r3=ind_hq_r3/4

****Consumer Variables Index.
egen ind_consvar_r3=rsum(radio1 tv1 fridge1 bike1 moto1 car1 mobphone1 phone1 toca1 plancha cocgas1 licua1)
replace ind_consvar_r3=ind_consvar_r3/12

****Housing Services Index.
egen ind_sshouse_r3=rsum(drwater1 elec1 toilet1 cooking1)
replace ind_sshouse_r3=ind_sshouse_r3/4

**** WEALTH INDEX

egen wealth_index_r3=rsum(ind_hq ind_consvar ind_sshouse_r3)
replace wealth_index_r3=wealth_index_r3/3

sum wealth_index*_r3
label var wealth_index_r3 "Wealth index"

label var ind_hq_r3 "Housing quality index"

label var ind_consvar_r3 "Consumer durables index"

label var ind_sshouse_r3 "Housing services index"

keep childid  wealth_index*_r3 ind_hq_r3 ind_consvar_r3 ind_sshouse_r3

rename wealth_index_r3 wi
rename ind_hq_r3        hq
rename ind_consvar_r3   cd 
rename ind_sshouse_r3   sv
sort childid

save "$r3yc\constructed\wi_3yc.dta", replace

*************************************** OLDER COHORT *************************************************

use childid specwatr using "$r3oc\raw\older 1 july 2011\pe_oc_householdlevel.dta", clear
sort childid
tempfile wateroc
save    `wateroc'

use "$r3oc\raw\pe_oc_householdlevel.dta", clear
sort childid
merge childid using `wateroc', unique
tab _m
drop _m


***** HOUSING QUALITY INDEX

*1. Scaled sleeping rooms per person.

tab numrmr3, m
recode numrmr3 (88=.)
gen room_pc=numrmr3/hhsize
codebook room_pc

egen min_sca=min(room_pc)
egen max_sca=max(room_pc)
gen scaled_room=(room_pc-min_sca)/(max_sca-min_sca)
sum scaled_room

*2. Floor material.

tab floorr3, m
gen floor1=(floorr3==1|floorr3==5|floorr3==6|floorr3==7|floorr3==8|floorr3==22)

/* for definition. (1) cement/tile (5) granite stone (6) Laminated material (7) marble stone (8) polished stone (22) parket */

*3. Roof material.

tab roof, m
recode roof (88=.)
gen roof1=(roofr3==4|roofr3==6|roofr3==15)

/* for definition (4) concrete/cement (6) galvanised/corrugated iron (15) tiles/slates */

*4. Wall material.

tab wall, m
recode wall (88=.)
gen wall1=(wallr3==3|wallr3==25)

/* for definition (3) brick/ concrete (25) concrete blocks */

***** CONSUMER DURABLES INDEX

sum radio7r3-rcdp7r3
recode radio7r3-rcdp7r3 (99=.) 

gen radio1=radio7r3==1
gen tv1=tv7r3==1
gen fridge1=fridg7r3==1
gen moto1=motor7r3==1
gen car1=car7r3==1
gen plancha1=iron7r3==1
gen phone1=phone7r3==1
gen mobphone1=mbphn7r3==1
gen bike1=bike7r3==1
gen cocgas1=mitad7r3==1
gen licua1=blnd7r3==1
gen toca1=rcdp7r3==1

***** HOUSING SERVICES INDEX

*1. Source of drinking water.

tab drwtr, m
recode drwtr (99=.)
gen drwater1=drwtrr3==1|drwtrr3==2

/* for definition (1) piped water to the house/ plot (public network) (2) well, tubewell with hand pump */

*2. Having electricity.

tab elec, m
recode elec (88=.)
gen elec1=elecr3==1

*3. Type of toilet.

tab toilet, m
recode toilet (88=.)
gen toilet1=toiletr3==1|toiletr3==6

/* for definition (1) flush toilet/ septic tank (6) pit latrine (household's)*/

*4. Type of cooking fuel.

tab cook, m
recode cook (88=.)
gen cooking1=(cookr3==8|cookr3==9)

/* for definition (8) gas/electricity (9) kerosene/ paraffin */

***** WEALTH INDEX

****Housing Quality Index.
egen ind_hq_r3=rsum(scaled_room floor1 roof1 wall1)
replace ind_hq_r3=ind_hq_r3/4

****Consumer Variables Index.
egen ind_consvar_r3=rsum(radio1 tv1 fridge1 bike1 moto1 car1 mobphone1 phone1 toca1 ///
plancha cocgas1 licua1)
replace ind_consvar_r3=ind_consvar_r3/12

****Housing Services Index.
egen ind_sshouse_r3=rsum(drwater1 elec1 toilet1 cooking1)
replace ind_sshouse_r3=ind_sshouse_r3/4

****Total Index
egen wealth_index_r3=rsum(ind_hq ind_consvar ind_sshouse_r3)
replace wealth_index_r3=wealth_index_r3/3

sum wealth_index*_r3
label var wealth_index_r3 "Wealth index"

label var ind_hq_r3 "Housing quality index"

label var ind_consvar_r3 "Consumer durables index"

label var ind_sshouse_r3 "Housing services index"

keep childid  wealth_index*_r3 ind_hq_r3 ind_consvar_r3 ind_sshouse_r3

rename wealth_index_r3 wi
rename ind_hq_r3        hq
rename ind_consvar_r3   cd
rename ind_sshouse_r3   sv

sort childid

save "$r3oc\constructed\wi_3oc.dta", replace
