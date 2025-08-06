
***R1 WEALTH INDEX IN COUNTRY REPORT IS EXACTLY THE SAME AS IN THE DATA-SET I.E. FOLLOWING ANNE'S CODE 

clear
set mem 50m
set more off
capture log close

global r1yc			N:\Quantitative research\Data\r1\vietnam\yc\
global r1oc			N:\Quantitative research\Data\r1\vietnam\oc\

************

use "$r1yc/raw/vnchildlevel1yrold.dta",clear
keep childid wall roof floor numroom hhsize radio fridge bike tv motor car mobphone phone fan elec drwater cooking toilet 
label drop LABD
recode radio fridge bike tv motor car mobphone phone fan elec (2=0) (99=.)
g yc=1
sort childid
tempfile    wi1yc
save       `wi1yc'

use "$r1oc/raw/vnchildlevel8yrold.dta",clear
keep childid wall roof floor numroom hhsize radio fridge bike tv motor car mobphone phone fan elec drwater cooking toilet 
label drop LABC
recode radio fridge bike tv motor car mobphone phone fan elec (2=0) (99=.)
tempfile   wi1oc
save      `wi1oc'
append using `wi1yc'
replace yc=0 if yc==.
sort childid
tempfile   wi1
save      `wi1'

******* WEALTH INDEX CALCULATIONS

*****************************************************************************************************
* Housing quality index (hq)
* There are 4 components of this index:
* 1 - Scaled number of rooms per person (capping at 1.5) - 
*      any values greater than 1 are set to 1.
* 2 - Add 1 if the walls are made of brick or concrete - ie wall=1
* 3 - Add 1 if the roof is made of concrete/cement, galvanished/corrugated iron, or tiles/slates - 
*      ie roof=5, 4, 6
* 4 - Add 1 if the floor is made of cement/tile, stone/brick - 
*      ie floor=4, 3 
* The total is then divided by 4 to give the housing quality index
* If any of the component variables are missing (99) then they are set to "no".
* With the exception of hhsize or roomnum - if these are missing, hq is set to missing
******************************************************************************************************

// NOTE. compared to round 2, many people have earth floors in round 1 which are then recorded as concrete/cement in round 2 (30% of earth in r1 become concrete/cement in r2)

gen wall_hq = wall==1
gen roof_hq = roof==4 | roof==5 | roof==6 
gen floor_hq = floor==3 | floor==4

replace numroom=. if numroom>70
gen temp=(numroom/hhsize)/1.5

*HQ

gen hq=(temp+wall_hq+roof_hq+floor_hq)/4
replace hq=. if numroom==. | hhsize==. 
label var hq "Housing quality index"

************************************************************************
* Consumer Durable index (cd)
* For this index we add 1 for each asset the household owns
* then divide by the total number of assets
* Productive assets (eg sewing machines) are not included in this calculation
* For Vietnam 9 assets are considered - Radio, Refrigerator, Bicycle,
* Television, Motorbike/scooter, Car, Mobile phone, Landline telephone, and Fan.
* If any of the component variables are missing (99) then this index, they are set to "no".
**********************************************************************.
foreach i in radio fridge bike tv motor car mobphone phone fan {
recode `i' 2=0 77=0 99=0 88=0 .=0
tab `i' if yc==1
tab `i' if yc==0
}

gen cd = (0+radio+fridge+bike+tv+motor+car+mobphone+phone+fan)/9

label var cd "Consumer durables index"

************************************************************************
* Services index (sv)
* For this index we look at whether or not the household has electricity,
* the source of drinking water, type of toilet facility and the most
* common type of fuel used for cooking.  
* To calculate the variable we add 1 if the household has electricity,
* (elec=1);  add 1 if drinking water is piped into the dwelling or the yard,
* (drwater=3); add 1 if the household has their own toilet facility, 
* (toilet=1 or 6) and add 1 if gas/electricity or paraffin/kerosene is used 
* for cooking (cooking=8 or 9)
* The resulting value is divided by 4 to give an index between 0 and 1
* If any of the component variables are missing (.) then this they are treated as "no"
***********************************************************************.

gen elec_sv    = elec==1
gen drwater_sv = drwater==1
gen toilet_sv  = toilet==1 | toilet==2
gen cooking_sv = cooking==2 | cooking==4 
foreach i in elec_sv drwater_sv toilet_sv cooking_sv {
tab `i' if yc==1
tab `i' if yc==0
}
gen sv = (0+elec_sv+drwater_sv+toilet_sv+cooking_sv)/4
label var sv "Services index"

***********************************************************
* Wealth index (wi)
* The wealth index is the average of the 3 indices just created, 
* ie Housing Quality index, Consumer Durables index, Services index.
* The three variables hq, cd and sv are added together and divided by 3
* to give an overall wealth index of between 0 and 1.
* If any of the component indices are missing, wi is set to missing 
***********************************************************.

gen wi=(hq+cd+sv)/3 if hq~=. & cd~=. & sv~=.
label var wi "Wealth Index"
keep childid yc wall_hq roof_hq floor_hq hq elec_sv drwater_sv toilet_sv cooking_sv sv cd wi

preserve 
keep if yc==1
drop yc wall_hq roof_hq floor_hq elec_sv drwater_sv toilet_sv cooking_sv 
sort childid
save "$r1yc/constructed/wi_1yc.dta", replace
restore

preserve 
keep if yc==0
drop yc wall_hq roof_hq floor_hq elec_sv drwater_sv toilet_sv cooking_sv 
sort childid
save "$r1oc/constructed/wi_1oc.dta", replace
restore

