**** THIS DO-FILE CONSTRUCTS THE WEALTH INDEX FOR ROUND 2

clear
set mem 600m
set more off 

global r1yc			N:\Quantitative research\Data\r1\india\yc\
global r1oc			N:\Quantitative research\Data\r1\india\oc\
global r2yc			N:\Quantitative research\Data\r2\india\yc\
global r2oc			N:\Quantitative research\Data\r2\india\oc\


* AUXILIAR

use childid drwaterq using "$r1yc\constructed\wealth_index_r1yc.dta", clear
sort childid
tempfile   drwater1yc
save      `drwater1yc'

* YOUNGER COHORT

use "$r2yc/raw/inchildlevel5yrold.dta", clear

****** HOUSING QUALITY INDEX

su numroom hhsize wall roof floor
replace numroom=. if numroom==88
replace roof=. if roof==77

g double roompp=(numroom/hhsize)/1.5
replace roompp=1 if roompp>1

label l wall
g wallq=wall
recode wallq 1=0 3 14=1
replace wallq=0 if wallq~=1 

label l roof
g roofq=roof
recode roofq 1=0 4 6 15=1
replace roofq=0 if (roof>=2 & roof<=3) |roof==5 | roof==7|(roof>=8 & roof<=14) | (roof>=16 & roof<=19)

label l floor
g floorq=floor
recode floorq 1 3 5 6 7 8 9=1 2 4 9 10 11 12=0

g double hqtest=(roompp+wallq+roofq+floorq)/4

su hqtest

****** CONSUMER DURABLES INDEX

su radio fridge bike tv motor car mobphone phone fan mitad tabchair sofa bedsted
replace mobphone=0 if mobphone==77

// exclude mitad cause it is increasing disporortionately in R3

g double cdtest=(radio+fridge+bike+tv+motor+car+mobphone+phone+fan+tabchair+sofa+bedsted)/12

su cdtest 

***** HOUSING SERVICES INDEX

// need to adjust drwater based on drwater in R1 as there is a suspicious different classification of those with superior water supply to inferior

// merge drwater from R1 into R2 

sort childid 
merge childid using `drwater1yc', unique
rename drwaterq drwater1
tab _m
keep if _merge==3 
drop _merge

* HOUSING SERVICES INDEX

su elec drwater toilet cooking 

label l LABBI                       // label electricity
label l drwater
g drwaterq=drwater
recode drwater 1=0 3 10=1
replace drwaterq=0 if drwaterq~=1
replace drwaterq=1 if drwaterq==0 & drwater1==1
label l toilet
g toiletq=toilet
recode toiletq 6=1
replace toiletq=0 if toiletq~=1
label l LABBJ                      // label values cooking
g cookingq=cooking
recode cookingq 1=0 8 9=1
replace cookingq=0 if cookingq~=1

su elec drwaterq toiletq cookingq

g svtest=0
replace svtest=1 if elec==1
replace svtest=svtest+1 if drwaterq==1 
replace svtest=svtest+1 if toiletq==1 
replace svtest=svtest+1 if cookingq==1 
replace svtest=svtest/4

su svtest 

replace hqtest=0 if hqtest==.

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
save "$r2yc/constructed/wi_2yc.dta", replace

**************************************************************** OLDER COHORT 

*** AUXILIAR

use childid drwaterq using "$r1oc\constructed\wealth_index_r1oc.dta", clear
sort childid
tempfile   drwater1oc
save      `drwater1oc'

****

use "$r2oc/raw/inchildlevel12yrold.dta", clear

****** HOUSING QUALITY INDEX

su numroom hhsize wall roof floor
replace numroom=. if numroom==88
replace roof=. if roof==77

g double roompp=(numroom/hhsize)/1.5
replace roompp=1 if roompp>1

label l wall
g wallq=wall
recode wallq 1=0 3 14=1
replace wallq=0 if wallq~=1 

label l roof
g roofq=roof
recode roofq 1=0 4 6 15=1
replace roofq=0 if (roof>=2 & roof<=3) |roof==5 | roof==7|(roof>=8 & roof<=14) | (roof>=16 & roof<=19)

label l floor
g floorq=floor
recode floorq 1 3 5 6 7 8 9=1 2 4 9 10 11 12=0

g double hqtest=(roompp+wallq+roofq+floorq)/4

su hqtest

****** CONSUMER DURABLES INDEX

su radio fridge bike tv motor car mobphone phone fan mitad tabchair sofa bedsted
replace mobphone=0 if mobphone==77

// exclude mitad cause it is increasing disporortionately in R3

g double cdtest=(radio+fridge+bike+tv+motor+car+mobphone+phone+fan+tabchair+sofa+bedsted)/12

su cdtest 

******  HOUSING SERVICES INDEX

// need to adjust drwater based on drwater in R1 as there is a suspicious different classification of those with superior water supply to inferior

// merge drwater from R1 into R2 

sort childid 
merge childid using `drwater1oc', unique
tab _m
keep if _merge==3 
drop _merge

rename drwaterq drwater1

su elec drwater toilet cooking 

label l LABBI                             // label values for electricity
label l drwater
g drwaterq=drwater
recode drwater 1=0 3 10=1
replace drwaterq=0 if drwaterq~=1
replace drwaterq=1 if drwaterq==0 & drwater1==1
label l toilet
g toiletq=toilet
recode toiletq 6=1
replace toiletq=0 if toiletq~=1

label l LABBJ                              //label values for cooking
g cookingq=cooking
recode cookingq 1=0 8 9=1
replace cookingq=0 if cookingq~=1

su elec drwaterq toiletq cookingq

g svtest=0
replace svtest=1 if elec==1
replace svtest=svtest+1 if drwaterq==1 
replace svtest=svtest+1 if toiletq==1 
replace svtest=svtest+1 if cookingq==1 
replace svtest=svtest/4

su svtest 

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
save "$r2oc/constructed/wi_2oc.dta", replace


