***** CONSUMPTION AGGREGATES R3 - BASED ON ANDREAS' COUNTRY REPORT DO FILE ********************

clear
set mem 700m
set more off 


global r1yc			N:\Quantitative research\Data\r1\india\yc
global r1oc			N:\Quantitative research\Data\r1\india\oc
global r2yc			N:\Quantitative research\Data\r2\india\yc
global r2oc			N:\Quantitative research\Data\r2\india\oc
global r3yc			N:\Quantitative research\Data\r3\india\yc
global r3oc			N:\Quantitative research\Data\r3\india\oc
global constructed 	N:\Quantitative research\Round 3 country reports\snapshots\india\constructed_data\andreas


***************************************** YOUNGER COHORT ************************************
// get commid and typesite from R2 YC

use "$r3yc\raw\in_yc_householdlevel.dta", clear
sort childid 

merge childid using "$constructed\commid_type_yc_r2.dta"

// see "\\qeh1\staff$\qehs0759\Do files\India\R3_country_report\india_R1_R2_R3_agg_calcul.do"  to see how commid_type_yc_r2 was constructed 

tab _merge 

keep if _merge~=2
drop _merge
sort childid 

// replace info on community id and urban\rural using R2 when newcomr3==88 (this is normally the case when fndhser3==1)

replace newcomr3=commid if newcomr3=="88" & commid~=""  

replace newster3=typesite if newster3==88

sort newcomr3

merge newcomr3 using "$constructed\community_prices_r3_merge.dta"

// see "\\qeh1\staff$\qehs0759\Do files\India\R3_country_report\india_R1_R2_R3_agg_calcul.do" to see how community_prices_r3_merge was constructed

// community prices are missing for few obs due to some missing community ids in hh level or due to lack of community info


// replace missing community prices with average price in the sentinel site

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
bysort newclsr3:egen xprice`i'=mean(price`i')
}

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
replace price`i'=xprice`i' if price`i'==. & xprice`i'<.
}

su vlrpr* ownvr* gftvr* spyrr* bgyrr* spndr*
recode vlrpr* ownvr* gftvr* spyrr* bgyrr* spndr* (. -88 -77=0)

replace vlrpr306=0 if  vlrpr306<0
replace spyrr303=0 if  spyrr303<0

cap drop commid
rename newcomr3 commid

// generating the total monthly expenditure on food items 

gen food1= 2*(vlrpr301 + ownvr301+gftvr301)
gen food2= 2*(vlrpr302 + ownvr302+gftvr302)
gen food7= 2*(vlrpr307 + ownvr307+gftvr307)
gen food11= 2*(vlrpr311 + ownvr311+gftvr311)
gen food13= 2*(vlrpr313 + ownvr301+gftvr313)
gen food14= 2*(vlrpr314 + ownvr314+gftvr314)
gen food15= 2*(vlrpr315 + ownvr315+gftvr315)
gen food18= 2*(vlrpr318 + ownvr318+gftvr318)

// generating total community-wide expenditure on each of the covered food and non-food items 

sort commid
by commid: egen foodsum1= total(food1)
by commid: egen foodsum2= total(food2)
by commid: egen foodsum7= total(food7)
by commid: egen foodsum11= total(food11)
by commid: egen foodsum13= total(food13)
by commid: egen foodsum14= total(food14)
by commid: egen foodsum15= total(food15)
by commid: egen foodsum18= total(food18)
by commid: egen cigarettessum1= total(spndr301)
by commid: egen kerosenesum1= total(spndr303)

// generating total community-wide expenditure on all the covered items together 

by commid: gen total = (foodsum1 +foodsum2 +foodsum7 +foodsum11 +foodsum13 +foodsum14 +foodsum15 +foodsum18 +cigarettes + kerosene)

// generating weights for each commodity equivalent to share in total expenditure at community-level 

gen share1 = foodsum1/total  
gen share2 = foodsum2/total
gen share7 = foodsum7/total
gen share11 = foodsum11/total
gen share13 = foodsum13/total
gen share14 = foodsum14/total
gen share15 = foodsum15/total
gen share18 = foodsum18/total
gen sharecig = cigarettes/total
gen sharekerosene = kerosene/total


// replace missing prices with average community shares and prices

foreach i in 1 2 7 11 13 14 15 18 cig kerosene {
bysort commid: egen avshare`i'=mean(share`i')
}

foreach i in 1 2 7 11 13 14 15 18 cig kerosene {
replace share`i'=avshare`i' if share`i'==. & avshare`i'~=.
}

// recall 2 components of the CPI. Community disparities component calculated using two different ways below

foreach i in 1 2 7{
rename share`i' share0`i'
}

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
egen mprice`i'=mean(price`i')
}

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
gen index`i'=share`i'*(price`i'/mprice`i')
}

g cpi1=index01

foreach i in 02 07 11 13 14 15 18 cig kerosene {
replace cpi1=cpi1+index`i'
}

g wprsumr3=0

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
replace wprsumr3=wprsumr3+share`i'*price`i'
}

egen mwprsumr3=mean(wprsumr3)

g cpi2=wprsumr3/mwprsumr3

su cpi2 

gen dint2=dofc(dint)
format dint2 %td
drop dint
rename dint2 dint

// drop max value as it is driven by outliers in one community IN021 they report a huge amount spent in rice

replace cpi2=. if cpi2>2 

/*add Indian Labour bureau CPI for completeness and validation checks-see "\\qeh1\staff$\qehs0759\Data\India\R3\AP_CPI_IW_RL_06_09_10.xls" for all data
extracted from the Indin Labour Bureau-see folder "\\qeh1\staff$\qehs0759\Country reports for all relevant CPI tables.*/

// rural 

g cpi3=1.36 if dint>=18113 & dint<=18140 & newster==2
replace cpi3=1.35 if dint>=18141 & dint<=18170 & newster3==2
replace cpi3=1.36 if dint>=18171 & dint<=18201 & newster3==2
replace cpi3=1.36 if dint>=18202 & dint<=18231 & newster3==2
replace cpi3=1.36 if dint>=18232 & dint<=18262 & newster3==2
replace cpi3=1.49 if dint>=18263 & dint<=18306 & newster3==2
replace cpi3=1.51 if dint>=18307 & dint<=181334 & newster3==2
replace cpi3=1.51 if dint>=18335 & dint<=18339 & newster3==2

// urban

replace cpi3=1.35 if dint>=18113 & dint<=18140 & newster==1
replace cpi3=1.35 if dint>=18141 & dint<=18170 & newster3==1
replace cpi3=1.37 if dint>=18171 & dint<=18201 & newster3==1
replace cpi3=1.39 if dint>=18202 & dint<=18231 & newster3==1
replace cpi3=1.4 if dint>=18232 & dint<=18262 & newster3==1
replace cpi3=1.52 if dint>=18263 & dint<=18306 & newster3==1
replace cpi3=1.51 if dint>=18307 & dint<=181334 & newster3==1
replace cpi3=1.50 if dint>=18335 & dint<=18339 & newster3==1

// adjust cpi2 for temporal element by multiplying by CPI3

replace cpi2=cpi2*cpi3

// we will calculate monthly food and non-food expenditure

// food
recode vlrpr* (-88 -77 =0)
recode ownvr* (-88 -77 =0)
recode gftvr* (-88 -77 =0)

egen svlrpr=rowtotal(vlrpr300-vlrpr324)
egen sownvr1=rowtotal(ownvr300-ownvr317)
gen sownvr2=ownvr318+ownvr319+ownvr320+ownvr321+ownvr324
g sownvr=sownvr1+sownvr2
egen sgftvr1=rowtotal(gftvr300-gftvr317)
gen sgftvr2=gftvr318+gftvr319+gftvr320+gftvr321+gftvr324
g sgftvr=sgftvr1+sgftvr2

g foodexp=2*(svlrpr+sownvr+sgftvr)

/*non-food-will exclude school fees for adult men and women spyrr324-325 (not included in R2) but include all medical expenses as although individual medical
expenses may not be comparable aggregate expenses seem to be, i.e. there is big discrepancy between medical consultation expenses in R2 and R3 and 
all other medical expenses but the aggregates do not seem to suggest implausible changes in aggregate spending.*/

recode spyrr* (-88 -77=0)
recode bgyrr* (-88 -77=0)
recode spndr* (-88 -77=0)

egen sspyrr1=rowtotal(spyrr301-spyrr312)
egen sspyrr2=rowtotal(spyrr313-spyrr323)
g sspyrr=sspyrr1+sspyrr2+spyrr326+spyrr327
egen sbgyrr=rowtotal(bgyrr307-bgyrr311)
egen sspndr=rowtotal(spndr301-spndr306)

g nfexp=(0.083333333*(sspyrr+sbgyrr))+sspndr

g texp=foodexp+nfexp

// hh size doesn't seem to be reported in this data should be calculated by the houshold member data and then merged to this

drop _merge

sort childid 

merge childid using "$constructed\hhsize_yc_r3.dta"

/* see "\\qeh1\staff$\qehs0759\Do files\India\R3\R3_country_report\R3_construction of aggregates.do to see how india_R1_R2_R3_agg_calcul.do" to see how 
hhsize_yc_r3.dta was constructed.*/

keep if _merge==3

g percapexp=texp/hhsize

replace percapexp=. if percapexp<310 | percapexp>4100

g realpce1=percapexp/cpi1
g realpce2=percapexp/cpi2

su realpce2
tab newster3,su(realpce2)
tab chcster3,su(realpce2)

g povline=433.43/0.93 if typesite==2
replace povline=563.16/0.98 if typesite==1

g abspov=realpce2<povline if realpce2<. & povline<.

keep childid foodexp nfexp texp percapexp realpce2

label var foodexp    "Consumption of food items"
label var nfexp      "Consumption of non-food items"
label var texp       "Total consumptionb"
label var percapexp  "Total consumption per capita"
label var realpce2   "Real per capita consumption"

sort childid
save "$r3yc/constructed/consumption_3yc.dta", replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep 		childid realpce2   
rename  	realpce2 tconsrpc
label var	tconsrpc "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\india\consumption_3yc.dta", replace

********************************************** OLDER COHORT ******************************************

// get commid and typesite from R2 OC

use "$r3oc\raw\in_oc_householdlevel.dta", clear
sort childid 
merge childid using "$constructed\commid_type_oc_r2.dta"

// see "\\qeh1\staff$\qehs0759\Do files\India\R3_country_report\india_R1_R2_R3_agg_calcul.do"  to see how commid_type_oc_r2 was constructed 

tab _m
keep if _merge==3

drop _merge

replace newcomr3=commid if newcomr3=="88" & fndhser3==1 & commid~=""

replace newster3=typesite if newster3==88

sort newcomr3

merge newcomr3 using "$constructed\community_prices_r3_merge.dta"

// community prices are missing for few obs due to some community ids in h level do not report price info or no context info for them

su vlrpr* ownvr* gftvr* spyrr* bgyrr* spndr*
recode vlrpr* ownvr* gftvr* spyrr* bgyrr* spndr* (. -88 -77=0)

replace vlrpr313=0 if  vlrpr313<0

// replace missing community prices with average price in the sentinel site

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
bysort newclsr3:egen xprice`i'=mean(price`i')
}

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
replace price`i'=xprice`i' if price`i'==. & xprice`i'<.

}

cap drop commid
rename newcomr3 commid

// generating the total monthly expenditure on food items 

gen food1= 2*(vlrpr301 + ownvr301+gftvr301)
gen food2= 2*(vlrpr302 + ownvr302+gftvr302)
gen food7= 2*(vlrpr307 + ownvr307+gftvr307)
gen food11= 2*(vlrpr311 + ownvr311+gftvr311)
gen food13= 2*(vlrpr313 + ownvr301+gftvr313)
gen food14= 2*(vlrpr314 + ownvr314+gftvr314)
gen food15= 2*(vlrpr315 + ownvr315+gftvr315)
gen food18= 2*vlrpr318

// generating total community-wide expenditure on each of the covered food and non-food items 

sort commid
by commid: egen foodsum1= total(food1)
by commid: egen foodsum2= total(food2)
by commid: egen foodsum7= total(food7)
by commid: egen foodsum11= total(food11)
by commid: egen foodsum13= total(food13)
by commid: egen foodsum14= total(food14)
by commid: egen foodsum15= total(food15)
by commid: egen foodsum18= total(food18)
by commid: egen cigarettessum1= total(spndr301)
by commid: egen kerosenesum1= total(spndr303)

// generating total community-wide expenditure on all the covered items together 

by commid: gen total = (foodsum1 +foodsum2 +foodsum7 +foodsum11 +foodsum13 +foodsum14 +foodsum15 +foodsum18 +cigarettes + kerosene)

// generating weights for each commodity equivalent to share in total expenditure at community-level 

gen share1 = foodsum1/total  
gen share2 = foodsum2/total
gen share7 = foodsum7/total
gen share11 = foodsum11/total
gen share13 = foodsum13/total
gen share14 = foodsum14/total
gen share15 = foodsum15/total
gen share18 = foodsum18/total
gen sharecig = cigarettes/total
gen sharekerosene = kerosene/total

// replace missing prices with average community shares and prices

foreach i in 1 2 7 11 13 14 15 18 cig kerosene {
bysort commid: egen avshare`i'=mean(share`i')
}

foreach i in 1 2 7 11 13 14 15 18 cig kerosene {
replace share`i'=avshare`i' if share`i'==. & avshare`i'~=.
}

// recall 2 components of the CPI. Community disparities component calculated using two different ways below

foreach i in 1 2 7{
rename share`i' share0`i'
}

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
egen mprice`i'=mean(price`i')
}

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
gen index`i'=share`i'*(price`i'/mprice`i')
}

g cpi1=index01

foreach i in 02 07 11 13 14 15 18 cig kerosene {
replace cpi1=cpi1+index`i'
}

g wprsumr3=0

foreach i in 01 02 07 11 13 14 15 18 cig kerosene {
replace wprsumr3=wprsumr3+share`i'*price`i'
}

egen mwprsumr3=mean(wprsumr3)

g cpi2=wprsumr3/mwprsumr3

gen 		dint2=dofc(dint)
format 	dint2 %td
drop 		dint
rename 	dint2 dint

// rural 

g cpi3=1.36 if dint>=18113 & dint<=18140 & newster==2
replace cpi3=1.35 if dint>=18141 & dint<=18170 & newster3==2
replace cpi3=1.36 if dint>=18171 & dint<=18201 & newster3==2
replace cpi3=1.36 if dint>=18202 & dint<=18231 & newster3==2
replace cpi3=1.36 if dint>=18232 & dint<=18262 & newster3==2
replace cpi3=1.49 if dint>=18263 & dint<=18306 & newster3==2
replace cpi3=1.51 if dint>=18307 & dint<18325 & newster3==2
replace cpi3=1.5 if dint==18325 & newster3==2

// urban

replace cpi3=1.35 if dint>=18113 & dint<=18140 & newster==1
replace cpi3=1.35 if dint>=18141 & dint<=18170 & newster3==1
replace cpi3=1.37 if dint>=18171 & dint<=18201 & newster3==1
replace cpi3=1.39 if dint>=18202 & dint<=18231 & newster3==1
replace cpi3=1.4 if dint>=18232 & dint<=18262 & newster3==1
replace cpi3=1.52 if dint>=18263 & dint<=18306 & newster3==1

// adjust cpi2 for temporal element by multiplying by CPI3

replace cpi2=cpi2*cpi3

// we will calculate monthly food and non-food expenditure

// food
recode vlrpr* (-88 -77 =0)
recode ownvr* (-88 -77 =0)
recode gftvr* (-88 -77 =0)

egen svlrpr=rowtotal(vlrpr300-vlrpr324)
egen sownvr=rowtotal(ownvr300-ownvr317)
egen sgftvr=rowtotal(gftvr300-gftvr317)

g foodexp=2*(svlrpr+sownvr+sgftvr)

/*non-food-will exclude school fees for adult men and women spyrr24-25 (not included in R2) but include all medical expenses as although individual medical
expenses may not be comparable aggregate expenses seem to be, i.e. there is big discrepancy between medical consultation expenses in R2 and R3 and 
all other medical expenses but the aggregates do not seem to suggest implausible changes in aggregate spending.*/

recode spyrr* (-88 -77=0)
recode bgyrr* (-88 -77=0)
recode spndr* (-88 -77=0)

egen sspyrr1=rowtotal(spyrr301-spyrr312)
egen sspyrr2=rowtotal(spyrr313-spyrr323)
g sspyrr=sspyrr1+sspyrr2+spyrr326+spyrr327
egen sbgyrr=rowtotal(bgyrr307-bgyrr311)
egen sspndr=rowtotal(spndr301-spndr306)

g nfexp=(0.083333333*(sspyrr+sbgyrr))+sspndr

g texp=foodexp+nfexp

// hh size doesn't seem to be reported in this data should be calculated by the houshold member data and then merged to this

drop _merge

sort childid 

merge childid using "$constructed\hhsize_oc_r3.dta"

/* see "\\qeh1\staff$\qehs0759\Do files\India\R3\R3_country_report\R3_construction of aggregates.do to see how ndia_R1_R2_R3_agg_calcul.do" to see how 
hhsize_oc_r3.dta was constructed.*/

keep if _merge==3

g percapexp=texp/hhsize

// trim percap to get rid of extreme values

*replace percapexp=. if percapexp<357 | percapexp>5687

g realpce1=percapexp/cpi1
g realpce2=percapexp/cpi2

su realpce2
tab newster3,su(realpce2)
tab chcster3,su(realpce2)

g povline=433.43/0.93 if typesite==2
replace povline=563.16/0.98 if typesite==1

g abspov=realpce2<povline if realpce2<. & povline<.
poverty realpce2 if typesite==2, line(466.0537) gen(povrur) h
poverty realpce2 if typesite==1, line(574.65) gen(povurb) h
egen poverty=rowtotal(povrur povurb)

keep childid foodexp nfexp texp percapexp realpce2

label var foodexp    "Consumption of food items"
label var nfexp      "Consumption of non-food items"
label var texp       "Total consumption"
label var percapexp  "Total consumption per capita"
label var realpce2   "Real per capita consumption"

sort childid
save "$r3oc/constructed/consumption_3oc.dta", replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep 		childid realpce2   
rename  	realpce2 tconsrpc
label var	tconsrpc "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\india\consumption_3oc.dta", replace

PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

