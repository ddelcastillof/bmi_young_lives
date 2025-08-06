
****THIS DO-FILE CONSTRUCTS THE WEALTH INDEX FOR ROUND 3

clear
set mem 600m
set more off 


global r1yc			N:\Quantitative research\Data\r1\india\yc\
global r1oc			N:\Quantitative research\Data\r1\india\oc\
global r2yc			N:\Quantitative research\Data\r2\india\yc\
global r2oc			N:\Quantitative research\Data\r2\india\oc\
global r3yc			N:\Quantitative research\Data\r3\india\yc\
global r3oc			N:\Quantitative research\Data\r3\india\oc\

***** YOUNGER COHORT

use childid livhse using "$r3yc\raw\in_yc_householdmemberlevel.dta", clear
gen live=.
replace live=1 if livhse==1
egen hhsize=count(live), by(childid)
collapse (first) hhsize, by(childid)
sort childid
tempfile    hhsizeyc
save       `hhsizeyc'

* AUXILIAR

use childid drwaterq using "$r1yc\constructed\wealth_index_r1yc.dta", clear
sort childid
tempfile   drwater1yc
save      `drwater1yc'

*****

use "$r3yc/raw/in_yc_householdlevel.dta", clear
sort childid
merge childid using `hhsizeyc', unique
tab _m
drop _m

***** HOUSING QUALITY INDEX

su numrmr3 hhsize wallr3 roofr3 floorr3 

g double roompp=(numrmr3/hhsize)/1.5
replace roompp=1 if roompp>1

label l wallr3
g wallq=wallr3==3 if wallr3<=25
replace wallq=1 if wallr3==14 | wallr3==25

label l roofr3
g roofq=roofr3==4 if roofr3<=25
replace roofq=1 if roofr3==6 | roofr3==15

label l floorr3
g floorq=floorr3==1
replace floorq=1 if floorr3==3 |(floorr3>=5 & floorr3<=7)|floorr3==9

g double hqtest=(roompp+wallq+roofq+floorq)/4

su hqtest

****** CONSUMER DURABLES INDEX

su radio7r3 fridg7r3 bike7r3 tv7r3 motor7r3 car7r3 mbphn7r3 phone7r3 fan7r3 mitad7r3 tabch7r3 sofa7r3 bedst7r3 cmpt7r3 vdeo7r3 gmes7r3 mcro7r3 wshg7r3 dryr7r3
egen cd=rowtotal(tv7r3-dryr7r3)
g double cdtest=(cd)/19
su cdtest 

***** HOUSING SERVICES INDEX

// merge drwater1 i.e. drwater from R1

sort childid 
merge childid using `drwater1yc', unique
rename drwaterq drwater1

keep if _merge==3 
drop _merge
su elecr3 drwtrr3 toiletr3 cookr3

label l LABBP
g elec=elecr3

label l drwtrr3
g drwaterq=drwtrr3==3 if drwtrr3<=14
replace drwaterq=1 if drwtrr3==10
replace drwaterq=1 if drwaterq==0 & drwater1==1

label l toiletr3 
g toiletq=toiletr3==1 if toiletr3<=10
replace toiletq=1 if toiletr3==6

label l LABBQ
g cookingq=cookr3==8 if cookr3<=16
replace cookingq=1 if cookr3==9

g svtest=0
replace svtest=1 if elec==1
replace svtest=svtest+1 if drwaterq==1 
replace svtest=svtest+1 if toiletq==1 
replace svtest=svtest+1 if cookingq==1 
replace svtest=svtest/4

su svtest 

replace hqtest=0 if hqtest==.
replace cdtest=0 if cdtest==.

g witest=(hqtest+cdtest+svtest)/3
su witest 

keep childid witest hqtest cdtest svtest
rename witest wi
rename cdtest cd
rename hqtest hq
rename svtest sv

label var wi "Wealth index"
label var cd "Consumer durables index"
label var sv "Housing services index"
label var hq "Housing quality index"
sort childid

save "$r3yc/constructed/wi_3yc", replace
kk
******************************* OLDER COHORT

use childid livhse using "$r3oc\raw\in_oc_householdmemberlevel.dta", clear
gen live=.
replace live=1 if livhse==1
egen hhsize=count(live), by(childid)
collapse (first) hhsize, by(childid)
sort childid
tempfile    hhsizeoc
save       `hhsizeoc'

* AUXILIAR

use childid drwaterq using "$r1oc\constructed\wealth_index_r1oc.dta", clear
sort childid
tempfile   drwater1oc
save      `drwater1oc'

use "$r3oc/raw/in_oc_householdlevel.dta", clear
sort childid
merge childid using `hhsizeyc', unique
tab _m
drop _m

// hh size is not readily available in R3 HH data and thus should map from the household member data

****** HOUSING QUALITY INDEX

su numrmr3 hhsize wallr3 roofr3 floorr3 

g double roompp=(numrmr3/hhsize)/1.5
replace roompp=1 if roompp>1

label l wallr3
g wallq=wallr3==3 if wallr3<=25
replace wallq=1 if wallr3==14 | wallr3==25

label l roofr3
g roofq=roofr3==4 if roofr3<=25
replace roofq=1 if roofr3==6 | roofr3==15

label l floorr3
g floorq=floorr3==1
replace floorq=1 if floorr3==3 |(floorr3>=5 & floorr3<=7)|floorr3==9

g double hqtest=(roompp+wallq+roofq+floorq)/4

su hqtest

***** CONSUMER DURABLES INDEX

su radio7r3 fridg7r3 bike7r3 tv7r3 motor7r3 car7r3 mbphn7r3 phone7r3 fan7r3 mitad7r3 tabch7r3 sofa7r3 bedst7r3 cmpt7r3 vdeo7r3 gmes7r3 mcro7r3 wshg7r3 dryr7r3 
egen cd=rowtotal(tv7r3-dryr7r3)
g double cdtest=(cd)/19
su cdtest 

**** HOUSING SERVICES INDEX

// merge drwater1 i.e. drwater from R1
sort childid 
merge childid using `drwater1oc', unique
rename drwaterq drwater1
keep if _merge==3
drop _merge
su elecr3 drwtrr3 toiletr3 cookr3

label l LABBP
g elec=elecr3

label l drwtrr3
g drwaterq=drwtrr3==3 if drwtrr3<=14
replace drwaterq=1 if drwtrr3==10
replace drwaterq=1 if drwaterq==0 & drwater1==1

label l toiletr3 
g toiletq=toiletr3==1 if toiletr3<=10
replace toiletq=1 if toiletr3==6

label l LABBQ
g cookingq=cookr3==8 if cookr3<=16
replace cookingq=1 if cookr3==9

g svtest=0
replace svtest=1 if elec==1
replace svtest=svtest+1 if drwaterq==1 
replace svtest=svtest+1 if toiletq==1 
replace svtest=svtest+1 if cookingq==1 
replace svtest=svtest/4

su svtest 

replace hqtest=0 if hqtest==.
replace cdtest=0 if cdtest==.

g witest=(hqtest+cdtest+svtest)/3
su witest 

keep childid witest hqtest cdtest svtest 
rename witest wi
rename cdtest cd
rename hqtest hq
rename svtest sv

label var wi "Wealth index"
label var cd "Consumer durables index"
label var sv "Housing services index"
label var hq "Housing quality index"

sort childid
save "$r3oc/constructed/wi_3oc.dta", replace



