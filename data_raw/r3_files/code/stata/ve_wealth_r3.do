clear
set mem 50m
set more off
capture log close

global r2yc			N:\Quantitative research\Data\r2\vietnam\yc
global r2oc			N:\Quantitative research\Data\r2\vietnam\oc

global r3yc			N:\Quantitative research\Data\r3\vietnam\yc
global r3oc			N:\Quantitative research\Data\r3\vietnam\oc

**********************YOUNGER AND OLDER COHORT (NB: SINCE THE EXACT SAME HH INSTRUMENT WAS ADMINISTERED TO YC AND OC CAN JUST APPEND THEM TOGETHER) ****


use "$r2yc/raw/vnchildlevel5yrold.dta",clear
qui append using "$r2oc/raw/vnchildlevel12yrold.dta"
keep childid  floor 
ren floor floor_r2
sort childid 
tempfile floor_r2
save `floor_r2'

use "$r3yc/constructed/hhsize_adeqhhsize.dta", clear
qui append using "$r3oc/constructed/hhsize_adeqhhsize.dta"
sort childid
tempfile hhsize_r3
save `hhsize_r3'

use "$r3yc/raw/vn_yc_householdlevel.dta", clear
gen yc = 1
qui append using "$r3oc/raw/vn_oc_householdlevel.dta"
replace yc=0 if yc==.
*merge in hhsize
sort childid 
merge childid using `hhsize_r3'
*label hhsize variable properly
keep if _m==3 /*_m=1 are all blank*/
drop _m
sort childid 
merge childid using `floor_r2'
tab _m
drop if _m==2
drop _m


******** WEALTH INDEX CALCULATIONS


**************************************************************************
* Housing quality index (hq)
* There are 4 components of this index:
* 1 - Scaled number of rooms per person (capping at 1.5) - 
*      any values greater than 1 are set to 1.
* 2 - Add 1 if the walls are made of brick or concrete - ie wall=3
* 3 - Add 1 if the roof is made of ac roofing sheets, asbestos sheets, concrete/cement, galvanished/corrugated iron, or tiles/slates - 
*      ie roof=1, 2, 4, 6, or 15
* 4 - Add 1 if the floor is made of cement tile, concret/cement, granite stone, marble stone, or polished stone -     
* ie floor=1, 3, 5, 7, or 8  9
* The total is then divided by 4 to give the housing quality index
* If any of the component variables are missing (99) then they are treated as "no".
* With the exception of hhsize or numrooms - if these are missing hq is set to missing 
*************************************************************************

***ISSUE WITH FLOOR MATERIAL - TRANSLATED DIFFERENTLY IN THE 2 ROUNDS
*temporary solution - recode those who say ceramic in r3 to what they said in r2

* WALL
gen wall_hq = wallr3==3 

* ROOF
gen roof_hq =  roofr3==4 | roofr3==6 | roofr3==15  

* FLOOR

/*dealing with new large category = ceramic - currently wrongly translated as laminated*/
replace floorr3=floor_r2 if floorr3==6 

*checked that labels in round2 are the same as in round 3
gen floor_hq = floorr3==1 | floorr3==3 | floorr3==5 | floorr3==7 | floorr3==8 | floorr3==9

*HQ

replace numrmr=. if numrmr>70
gen temp = (numrmr/hhsize)/1.5

gen hq	 = (temp+wall_hq+roof_hq+floor_hq)/4
replace hq=. if numrmr3==. | hhsize_r3==. 
label var hq "Housing quality index"


************************************************************************
* Consumer Durable index (cd)
* For this index we add 1 for each asset the household owns
* then divide by the total number of assets
* Productive assets (eg sewing machines) are not included in this calculation
* For Vietnam 9 assets are considered - Radio, Refrigerator, Bicycle,
* Television, Motorbike/scooter, Car, Mobile phone, Landline telephone, and Fan.
* If any of the component variables are missing (99) then they are treated "no".
**********************************************************************.

gen cd = (0+radio7r3+fridg7r3+bike7r3+tv7r3+motor7r3+car7r3+mbphn7r3+phone7r3+fan7r3 )/9
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
* If any of the component variables are missing (.) then they are treated as "no"
***********************************************************************.

gen elec_sv    = elecr3==1
gen drwater_sv = drwtrr3==3
gen toilet_sv  = toiletr3==1 | toiletr3==6
gen cooking_sv = cookr3==8   | cookr3==9 

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

keep childid yc wall_hq roof_hq floor_hq hq elec_sv drwater_sv toilet_sv cooking_sv sv cd wi temp

preserve 
keep if yc==1
drop yc wall_hq roof_hq floor_hq elec_sv drwater_sv toilet_sv cooking_sv temp
sort childid
save "$r3yc/constructed/wi_3yc", replace
restore


preserve 
keep if yc==0
drop yc wall_hq roof_hq floor_hq elec_sv drwater_sv toilet_sv cooking_sv temp
sort childid
save "$r3oc/constructed/wi_3oc.dta", replace
restore

