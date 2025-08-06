****THIS DO-FILE CONSTRUCTS THE WEALTH INDEX, WEALTH INDEX QUINTILES AND WEALTH INDEX BASED RELATIVE POVERTY LINE FOR ROUND 1


clear
set mem 600m
set more off 


global r1yc			N:\Quantitative research\Data\r1\india\yc\
global r1oc			N:\Quantitative research\Data\r1\india\oc\

*****  WEALTH INDEX 


use "$r1yc/raw/inchildlevel1yrold.dta", clear
gen yc=1
qui append using "$r1oc/raw/inchildlevel8yrold.dta"
replace yc=0 if yc==.

// housing quality index 
su numroom hhsize wall roof floor
replace roof=. if roof==99
g double roompp=(numroom/hhsize)/1.5
replace roompp=1 if roompp>1
label l wall
g wallq=wall==1 if wall<=6
label l roof
g roofq=roof
recode roofq 4 5 6=1 1 2 3 7=0
label l floor
g floorq=floor
recode floorq 3 4 5=1 1 2 6=0
g double hqtest=(roompp+wallq+roofq+floorq)/4

// consumer durable index
su radio fridge bike tv motor car mobphone phone fan almr clck
recode radio fridge bike tv motor car mobphone phone fan almr clck (2=0)
g double cdtest=(radio+fridge+bike+tv+motor+car+mobphone+phone+fan+almr+clck)/11
su cdtest 

// quality/access to services index

su elec drwater toilet cooking 
replace toilet=. if toilet==99
label l elec
recode elec 2=0
label l drwater
g drwaterq=drwater<=2 if drwater<=5
label l toilet
g toiletq=toilet<=2 if toilet<=5
label l cooking 
g cookingq=cooking
recode cookingq 2 4=1 1 3 5 6 7 8=0 
su elec drwaterq toiletq cookingq

g svtest=0
replace svtest=1 if elec==1
replace svtest=svtest+1 if drwaterq==1 
replace svtest=svtest+1 if toiletq==1 
replace svtest=svtest+1 if cookingq==1 
replace svtest=svtest/4
su svtest 

replace hqtest=0 if hqtest==.
replace cdtest=0 if cdtest==.
replace svtest=0 if svtest==.
g witest=(hqtest+cdtest+svtest)/3
su witest 

preserve
keep if yc==1
keep childid witest hqtest cdtest svtest 
rename witest wi
rename hqtest hq
rename svtest sv
rename cdtest cd
label var wi "Wealth index"
label var hq "Housing quality index"
label var sv "Housing services index"
label var cd "Consumer durables index"
sort childid 
save "$r1yc/constructed/wi_1yc.dta", replace
restore 

keep if yc==0
keep childid witest hqtest cdtest svtest 
rename witest wi
rename hqtest hq
rename svtest sv
rename cdtest cd
label var wi "Wealth index"
label var hq "Housing quality index"
label var sv "Housing services index"
label var cd "Consumer durables index"
sort childid 
save "$r1oc/constructed/wi_1oc.dta", replace

