/*THIS DO-FILE IS BASED ON CODE FROM "main indicators 5yr_sk.do" WHICH CONSTRUCTS INDICES*/

clear
set mem 50m
set more off
capture log close

global r2oc		  N:\Quantitative research\Data\r2\vietnam\oc\
global r2yc		  N:\Quantitative research\Data\r2\vietnam\yc\

******************************************************************************************

use "$r2yc/raw/vnchildlevel5yrold.dta",clear
keep childid wall roof floor numroom hhsize radio fridge bike tv motor car mobphone phone fan elec drwater cooking toilet 
gen yc=1
sort childid 
tempfile yc
save    `yc'

use "$r2oc/raw/vnchildlevel12yrold.dta",clear
keep childid wall roof floor numroom hhsize radio fridge bike tv motor car mobphone phone fan elec drwater cooking toilet 
sort childid 
tempfile oc 
save `oc'
append using `yc'
replace yc=0 if yc==.
sort childid
tempfile wi2
save    `wi2'


**************************************************************************
* WEALTH INDEX CALCULATIONS
**************************************************************************
* Housing quality index (hq)
* There are 4 components of this index:
* 1 - Scaled number of rooms per person (capping at 1.5) - 
*      any values greater than 1 are set to 1.
* 2 - Add 1 if the walls are made of brick or concrete - ie wall=3
* 3 - Add 1 if the roof is made of ac roofing sheets, asbestos sheets, concrete/cement, galvanished iron, or tiles/slates - 
*      ie roof=1, 2, 4, 6, or 15
* 4 - Add 1 if the floor is made of cement/tile, concret/cement, granite stone, marble stone, or polished stone - 
*      ie floor=1, 3, 5, 7, or 8  
* The total is then divided by 4 to give the housing quality index
* If any of the component variables are missing (99) then they are treated as "no".
* With the exception of cases where hhsize or number of rooms is (.) - then hq = .
*************************************************************************.

* WALL
gen wall_hq  = wall==3

* ROOF

gen roof_hq  =  roof==4 | roof==6 | roof==15

* FLOOR

gen floor_hq = floor==1 | floor==3 | floor==5 | floor==7 | floor==8 | floor==9

* HQ

replace numroom=. if numroom>70
gen temp=(numroom/hhsize)/1.5

*new - as is most consistent across the three rounds
gen hq = (temp+wall_hq+roof_hq+floor_hq)/4
replace hq=. if numroom==. | hhsize==. 
label var hq "Housing quality index"

************************************************************************
* Consumer Durable index (cd)
* For this index we add 1 for each asset the household owns
* then divide by the total number of assets
* Productive assets (eg sewing machines) are not included in this calculation
* For Vietnam 9 assets are considered - Radio, Refrigerator, Bicycle,
* Television, Motorbike/scooter, Car, Mobile phone, Landline telephone, and Fan.
* If any of the component variables are missing (99) then they are treated as "no".
**********************************************************************.
foreach i in radio fridge bike tv motor car mobphone phone fan {
recode `i' 2=0 99=0 88=0 77=0 .=0
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
gen drwater_sv = drwater==3
gen toilet_sv  = toilet==1 | toilet==6
gen cooking_sv = cooking==8 | cooking==9 

gen sv = (0+elec_sv+drwater_sv+toilet_sv+cooking_sv)/4
label var sv "Services index"

***********************************************************
* Wealth index (wi)
* The wealth index is the average of the 3 indices just created, 
* ie Housing Quality index, Consumer Durables index, Services index.
* The three variables hq, cd and sv are added together and divided by 3
* to give an overall wealth index of between 0 and 1.
* If any of the component variables are missing (.), then the wealth index
* will be set to missing (.).
***********************************************************.

gen wi=(hq+cd+sv)/3 if hq~=. & cd~=. & sv~=.
label var wi "Wealth Index"

keep childid yc wall_hq roof_hq floor_hq hq elec_sv drwater_sv toilet_sv cooking_sv sv cd wi

preserve 
keep if yc==1
drop yc  wall_hq roof_hq floor_hq elec_sv drwater_sv toilet_sv cooking_sv 
sort childid
save "$r2yc/constructed/wi_2yc", replace
restore

preserve 
keep if yc==0
drop yc  wall_hq roof_hq floor_hq elec_sv drwater_sv toilet_sv cooking_sv 
sort childid
save "$r2oc/constructed/wi_2oc", replace
restore




