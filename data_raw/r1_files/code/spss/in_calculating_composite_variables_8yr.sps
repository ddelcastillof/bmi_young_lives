********** Calculating Composite Variables for archiving.
********** 8Yr old dataset - India Version.

GET FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'.

************************************************************************.
* Clusters are defined by the country team as being Urban or Rural.
* The variable created is 'typesite'.
******************************************************************************.

IF (clustid=1) typesite=1.
IF (clustid=2) typesite=2.
IF (clustid=3) typesite=1.
IF (clustid=4) typesite=2.
IF (clustid=5) typesite=2.
IF (clustid=6) typesite=2.
IF (clustid=7) typesite=2.
IF (clustid=8) typesite=2.
IF (clustid=9) typesite=2.
IF (clustid=10) typesite=1.
IF (clustid=11) typesite=2.
IF (clustid=12) typesite=2.
IF (clustid=13) typesite=2.
IF (clustid=14) typesite=1.
IF (clustid=15) typesite=2.
IF (clustid=16) typesite=2.
IF (clustid=17) typesite=2.
IF (clustid=18) typesite=2.
IF (clustid=19) typesite=2.
IF (clustid=20) typesite=1.
EXECUTE.
VARIABLE LABEL typesite 'Urban or Rural'.
VALUE LABEL typesite 1 'Urban' 2 'Rural'.
FORMAT typesite (F4.0).

**************************************************************************
* WEALTH INDEX CALCULATIONS
**************************************************************************
* Housing quality index (hq)
* There are 4 components of this index:
* 1 - Scaled number of rooms per person (capping at 1.5) - 
*      any values greater than 1 are set to 1.
* 2 - Add 1 if the walls are made of brick or concrete - ie wall=1
* 3 - Add 1 if the roof is made of iron, concrete, tiles or slate - 
*      ie roof=4, 5 or 6
* 4 - Add 1 if the floor is made of cement or is tiled or laminated - 
*      ie floor=4 or 5  
* The total is then divided by 4 to give the housing quality index
* If any of the compoent variables are missing (99) then hq will be missing.
*************************************************************************.

COMPUTE hq=(numroom/hhsize)/1.5.
IF (hq > 1) hq=1.
IF (wall=1) hq=hq+1.
IF (roof=4 | roof=5 | roof=6) hq=hq+1.
IF (floor=4 | floor=5) hq=hq+1.
COMPUTE hq=hq/4.

IF (MISSING(numroom) | MISSING(hhsize) | MISSING(wall) | MISSING(floor) | 
  MISSING(roof)) hq=99.
EXECUTE.

VARIABLE LABEL hq "Housing quality index".
VALUE LABEL hq 99 "Missing".
MISSING VALUES hq (99).

************************************************************************
* Consumer Durable index (cd)
* For this index we add 1 for each asset the household owns
* then divide by the total number of assets
* Productive assets (eg sewing machines) are not included in this calculation
* For India 11 assets are considered - Radio, Refrigerator, Bicycle,
* Television, Motorbike/scooter, Car, Mobile phone, Landline telephone, 
* Fan, Almairah (wardrobe), Clock.
* If any of the component variables are missing (99) then this index 
* will be set to 99.
**********************************************************************.

COMPUTE cd=0.
IF (radio=1) cd=cd+1.
IF (fridge=1) cd=cd+1.
IF (bike=1) cd=cd+1.
IF (tv=1) cd=cd+1.
IF (motor=1) cd=cd+1.
IF (car=1) cd=cd+1.
IF (mobphone=1) cd=cd+1.
IF (phone=1) cd=cd+1.
IF (fan=1) cd=cd+1.
IF (almr=1) cd=cd+1.
IF (clck=1) cd=cd+1.
COMPUTE cd=cd/11.

IF (MISSING(radio) | MISSING(fridge) | MISSING(bike) | MISSING(tv) |
 MISSING(motor) | MISSING(car) | MISSING(mobphone) | MISSING(phone) |
 MISSING(fan) | MISSING(almr) | MISSING(clck)) cd=99.
EXECUTE.

VARIABLE LABEL cd "Consumer durables index".
VALUE LABEL cd 99 "Missing".
MISSING VALUES cd (99).

************************************************************************
* Services index (sv)
* For this index we look at whether or not the household has electricity,
* the source of drinking water, type of toilet facility and the most
* common type of fuel used for cooking.  
* To calculate the variable we add 1 if the household has electricity,
* (elec=1);  add 1 if drinking water is piped into the dwelling or the yard,
* (drwater=1); add 1 if the household has their own toilet facility, 
* (toilet=1 or 2) and add 1 if paraffin, kerosene, gas or electricity is used 
* for cooking (cooking=2 or 4)
* The resulting value is divided by 4 to give an index between 0 and 1
* If any of the component variables are missing (99) then this 
* variable will be set to 99
***********************************************************************.

COMPUTE sv=0.
IF (elec=1) sv=sv+1.
IF (drwater=1) sv=sv+1.
IF (toilet=1 | toilet=2) sv=sv+1.
IF (cooking=2 | cooking=4) sv=sv+1.
COMPUTE sv=sv/4.

IF (MISSING(elec) | MISSING(drwater) | MISSING(toilet) | MISSING(cooking))
 sv=99.
EXECUTE.

VARIABLE LABEL sv "Services index".
VALUE LABEL sv 99 "Missing".
MISSING VALUES sv (99).

***********************************************************
* Wealth index (wi)
* The wealth index is the average of the 3 indices just created, 
* ie Housing Quality index, Consumer Durables index, Services index.
* The three variables hq, cd and sv are added together and divided by 3
* to give an overall wealth index of between 0 and 1.
* If any of the component variables are missing (99), then the wealth index
* will be set to 99 (Missing).
***********************************************************.

IF (~MISSING(hq) & ~MISSING(cd) & ~MISSING(sv)) wi=(hq+cd+sv)/3.
RECODE wi (SYSMIS=99).
EXECUTE.
VARIABLE LABEL wi "Wealth index".
VALUE LABEL wi 99 "Missing".
MISSING VALUES wi (99).

***********************************************************
* Number of groups caregiver is a member of (norgs)
* In the questionnaire we look at 7 types of group that may be present in
* the community:
* 1 - Work related, 2 - Community association, 3 - Womens group
* 4 - Political group, 5 - Religious group, 6 - Credit/funeral group
* 7 - Sports group
* For this variable we simply count the number of groups that the
* caregiver is a member of.
* If any of the component variables (member1, member2, member3,
* member4, member5, member6, member7) are unknown (99), then
* the value of norgs will be set to 99 (Missing)
***********************************************************.

COMPUTE norgs=0.
IF (member1=1) norgs=norgs+1.
IF (member2=1) norgs=norgs+1.
IF (member3=1) norgs=norgs+1.
IF (member4=1) norgs=norgs+1.
IF (member5=1) norgs=norgs+1.
IF (member6=1) norgs=norgs+1.
IF (member7=1) norgs=norgs+1.

IF (MISSING(member1) | MISSING(member2) | MISSING(member3)  | MISSING(member4) 
 | MISSING(member5) | MISSING(member6) | MISSING(member7)) norgs=99.
EXECUTE.

VARIABLE LABEL norgs "Number of groups".
VALUE LABEL norgs 99 "Missing".
MISSING VALUES norgs (99).
FORMAT norgs (F4.0).

******************************************************************************
* Group Membership (grpmem)
* This variable is a grouping of the calculated variable norgs
* If the caregiver is a member of no groups they are classified as having
* low group membership, if they are members of 1 or 2 groups then they have
* medium group membership and if they are members of 3 or more groups then 
* they have high group membership
* If norgs=99 (Missing) then grpmem will be set to 99 (Missing)
******************************************************************************.

RECODE norgs (0=0) (1 thru 2=1) (3 thru 7=2) (99=99) INTO grpmem.
EXECUTE.

VARIABLE LABEL grpmem "Group membership".
VALUE LABEL grpmem 0 "Low" 1 "Medium" 2 "High" 99 "Missing".
MISSING VALUES grpmem (99).
FORMAT grpmem (F4.0).

***********************************************************
* Cognitive Social Capital (csc)
* This index value is a combination of the responses to the questions on 
* whether the caregiver feels part of the community, whether they feel people
* in general can be trusted, whether they feel people would try and take
* advantage of them if they could, and whether they feel people generally get
* along with each other okay
* We count the number of Yes responses to the questions:
* Can people around here be trusted? (trust)
* Do people generally get along with each other? (along)
* Do you feel part of the community? (part)
* then add 1 for a "no" response to the question 
* Do you think people would take advantage of you given the chance? (advantag)
* This gives a value between 0 and 4 which we group so that 0=Low,
* 1 or 2=Medium, 3 or 4=High.
* If any of the component variables are missing (99), then assc will
* be set to 99 (Missing).
***********************************************************.

COMPUTE csc=0.
IF (trust=1) csc=csc+1.
IF (along=1) csc=csc+1.
IF (part=1) csc=csc+1.
IF (advantag=2) csc=csc+1.
RECODE csc (0=0) (1 thru 2=1) (3 thru 4=2).

IF (MISSING(trust) | MISSING(along) | MISSING(part) | MISSING(advantag))
 csc=99.
EXECUTE.

VARIABLE LABEL csc "Cognitive Social Capital".
VALUE LABEL csc 0 "Low" 1 "Medium" 2 "High" 99 "Missing".
MISSING VALUES csc (99).
FORMAT csc (F4.0).

***********************************************************
* Level of Citizenship (citizen)
* This index is a combination of the responses to the questions of 
* whether the respondent has joined with others in the community to address
* a particular issue (join) and whether they have contacted the local 
* authority about problems in the community (authorit)
* The number of "Yes" responses are counted giving a vallue between 0 and 2
* This is then grouped so that 0=No citizenship and 1 or 2=Some citizenship.
* If either of the component variables are missing (99), then citizen will
* be set to 99 (Missing)
***********************************************************.

COMPUTE citizen=0.
IF (join=1) citizen=citizen+1.
IF (authorit=1) citizen=citizen+1.
RECODE citizen (0=0) (1 thru 2=1).

IF (MISSING(join) | MISSING(authorit)) citizen=99.
EXECUTE.

VARIABLE LABEL citizen "Level of citizenship".
VALUE LABEL citizen 0 "No citizenship" 1 "Some citizenship" 99 "Missing".
MISSING VALUES citizen (99).
FORMAT citizen (F4.0).

***********************************************************
* Group Support (supgroup)
* When the caregiver was a member of a group we asked whether they
* received support from that group in the last year - this variable
* is a count of the number of groups from which the caregiver
* has received support - we use the variables anysup1 through to anysup7
* If any of these variables is missing (99), then supgroup will be set to 99 
* and treated as missing
*****************************************************************************.

COMPUTE supgroup=0.
IF (member1=1 & anysup1=1) supgroup=supgroup+1.
IF (member2=1 & anysup2=1) supgroup=supgroup+1.
IF (member3=1 & anysup3=1) supgroup=supgroup+1.
IF (member4=1 & anysup4=1) supgroup=supgroup+1.
IF (member5=1 & anysup5=1) supgroup=supgroup+1.
IF (member6=1 & anysup6=1) supgroup=supgroup+1.
IF (member7=1 & anysup7=1) supgroup=supgroup+1.
EXECUTE.

MISSING VALUES anysup1 anysup2 anysup3 anysup4
 anysup5 anysup6 anysup7 (99).

IF (MISSING(anysup1) | MISSING(anysup2) | MISSING(anysup3)
 | MISSING(anysup4) | MISSING(anysup5) | MISSING(anysup6)
 | MISSING(anysup7) | MISSING(member1) | MISSING(member2)
 | MISSING(member3) | MISSING(member4) | MISSING(member5)
 | MISSING(member6) | MISSING(member7)) supgroup=99.
EXECUTE.

MISSING VALUES anysup1 anysup2 anysup3 anysup4
 anysup5 anysup6 anysup7 (88, 99).

VARIABLE LABEL supgroup "Support from groups".
VALUE LABEL supgroup 99 "Missing".
MISSING VALUES supgroup (99).
FORMAT supgroup (F4.0).

******************************************************************************.
* Individual support (supindiv)
* In the questionnaire we asked whether the caregiver received support from 
* other sources - individuals or organisations - during the past year
* Nine potential sources of support were listed and Yes or No responses
* stored in the variables support1 through to support9.
* For this variable we total the number of Yes responses from these nine.
* If any of the nine support variables are missing (99), then supindiv will be
* set to 99 and treated as missing.
*****************************************************************************.

COMPUTE supindiv=0.
IF (support1=1) supindiv=supindiv+1.
IF (support2=1) supindiv=supindiv+1.
IF (support3=1) supindiv=supindiv+1.
IF (support4=1) supindiv=supindiv+1.
IF (support5=1) supindiv=supindiv+1.
IF (support6=1) supindiv=supindiv+1.
IF (support7=1) supindiv=supindiv+1.
IF (support8=1) supindiv=supindiv+1.
IF (support9=1) supindiv=supindiv+1.

IF (MISSING(support1) | MISSING(support2) | MISSING(support3)
 | MISSING(support4) | MISSING(support5) | MISSING(support6)
 | MISSING(support7) | MISSING(support8) | MISSING(support9)) supindiv=99.
EXECUTE.

VARIABLE LABEL supindiv "Support from individuals/organisations".
VALUE LABEL supindiv 99 "Missing".
MISSING VALUES supindiv (99).
FORMAT supindiv (F4.0).

*********************************************************************.
* Social Support Received in year (nss)
* For this variable we add the two previous variables (supgroup+supindiv)
* and group the result into 0="Low support", 1 to 4="Medium support",
* 5 or more="High support".
* If either of supgroup and supindiv are missing (99), then this variable is 
* also set to 99 and treated as missing.
***********************************************************.

IF (~MISSING(supgroup) & ~MISSING(supindiv)) nss=supgroup+supindiv.
RECODE nss (0=0) (1 thru 4=1) (5 thru 16=2) (SYSMIS=99).
EXECUTE.
VARIABLE LABEL nss "Social support received in last year".
VALUE LABEL nss 0 "Low" 1 "Medium" 2 "High" 99 "Missing".
MISSING VALUES nss (99).
FORMAT nss (F4.0).

******************************************************************************
* Frequency of seeing biological mother (frqmum)
* This variable is created from the questions on where does the mother lives
* (momlive) and how often the child sees the mother (seemom).
* Possible values for this variable are 1=Daily, 2=Less often, 3=Mother dead.
* If either momlive or seemom are unknown then frqmum will be set to 99
* and treated as missing
*******************************************************************************.

IF (MISSING(momlive) | MISSING(seemom)) frqmum=99.
DO IF (seemom=1).
COMPUTE frqmum=1.
ELSE IF (seemom=2 | seemom=3 | seemom=4 | seemom=5).
COMPUTE frqmum=2.
END IF.
IF (momlive=3) frqmum=3.
EXECUTE.

VARIABLE LABEL frqmum "Frequency of seeing biological mother".
VALUE LABEL frqmum 1 "Daily" 2 "Less often" 3 "Mother dead" 99 "Missing".
MISSING VALUES frqmum (99).
FORMAT frqmum (F4.0).

******************************************************************************
* Frequency of seeing biological father (frqdad)
* This variable is created from the questions on where does the father lives
* (daddead) and how often the child sees the father (seedad).
* Possible values for this variable are 1=Daily, 2=Less often, 3=Father dead.
* If either daddead or seedad are unknown then frqdad will be set to 99
* and treated as missing
*******************************************************************************.

IF (MISSING(daddead) | MISSING(seedad)) frqdad=99.
DO IF (seedad=1).
COMPUTE frqdad=1.
ELSE IF (seedad=2 | seedad=3 | seedad=4 | seedad=5).
COMPUTE frqdad=2.
END IF.
IF (daddead=3) frqdad=3.
EXECUTE.

VARIABLE LABEL frqdad "Frequency of seeing biological father".
VALUE LABEL frqdad 1 "Daily" 2 "Less often" 3 "Father dead" 99 "Missing".
MISSING VALUES frqdad (99).
FORMAT frqdad (F4.0).

**************************************************************************
* Caregiver has a partner (hhpart)
* This variable combines the responses to the questions 
* "Does the caregiver have a partner" (partner) and 
* "Does the partner live in the household" (partlive)
* Codes for this combined variable are:
* 1 - Partner living in the household
* 2 - Partner living outside the household
* 3 - No partner
* If either of the component variables are unknown (99), then this
* variable will be set to 99 and treated as missing.
**************************************************************************.

IF (MISSING(partner)) hhpart=99.
DO IF (partner=1).
IF (partlive=1) hhpart=1.
IF (partlive=2) hhpart=2.
IF (MISSING(partlive)) hhpart=99.
ELSE IF (partner=2 | partner=3 | partner=4).
COMPUTE hhpart=3.
END IF.

VARIABLE LABEL hhpart "Whereabouts of caregiver's partner".
VALUE LABEL hhpart 1 "Caregiver's partner lives in the household"
 2 "Caregiver's partner lives outside the household"
 3 "Caregiver has no partner" 99 "Missing".
MISSING VALUES hhpart (99).
FORMAT hhpart (F4.0).

******************************************************************************
* Parents alive or dead (parlive)
* This variable uses code 3 from momlive (mother dead) and code 3 from 
* daddead (father dead) to work out whether the parents are dead or alive.
* Resulting codes will be 1 - Both parents alive, 2 - Mother dead/father alive
* 3 - Mother alive/father dead, 4 - Both parents dead.
* If either of the component variables are missing then parlive will be set
* to 99 and treated as missing.
******************************************************************************.

IF (MISSING(momlive) | MISSING(daddead)) parlive=99.
DO IF ((momlive=1 | momlive=2) & (daddead=1 | daddead=2)).
COMPUTE parlive=1.
ELSE IF ((momlive=1 | momlive=2) & daddead=3).
COMPUTE parlive=3.
ELSE IF (momlive=3 & (daddead=1 | daddead=2)).
COMPUTE parlive=2.
ELSE IF (momlive=3 & daddead=3).
COMPUTE parlive=4.
END IF.
EXECUTE.

VARIABLE LABEL parlive "Parents alive or dead".
VALUE LABEL parlive 1 "Both parents alive"
 2 "Mother dead/father alive"  3 "Mother alive/father dead"
 4 "Both parents dead" 99 "Missing".
MISSING VALUES parlive (99).
FORMAT parlive (F4.0).

******************************************************************************
* Living arrangements (livarran)
* This variable uses code 2 from momlive (mother lives in the household)
* and code 2 from daddead (father lives in the household) to work out the 
* living arrangements.
* Resulting codes will be 1 - Child lives with both parents
* 2 - Child lives with mother but not father
* 3 - Child lives with father but not mother
* 4 - Child lives with neither of the biological parents
* If either of the component variables are missing then livarran will be set
* to 99 and treated as missing.
************************************************************************************.

IF (MISSING(momlive) | MISSING(daddead)) livarran=99.
DO IF (momlive=2 & daddead=2).
COMPUTE livarran=1.
ELSE IF (momlive=2 & (daddead=1 | daddead=3)).
COMPUTE livarran=2.
ELSE IF ((momlive=1 | momlive=3) & daddead=2).
COMPUTE livarran=3.
ELSE IF ((momlive=1 | momlive=3) & (daddead=1 | daddead=3)).
COMPUTE livarran=4.
END IF.
EXECUTE.

VARIABLE LABEL livarran "Living arrangements".
VALUE LABEL livarran 1 "Child lives with both parents"
 2 "Child lives with mother but not father"
 3 "Child lives with father but not mother"
 4 "Child lives with neither of the biological parents"
 99 "Missing".
MISSING VALUES livarran (99).
FORMAT livarran (F4.0).

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' /COMPRESSED.

*******************************************************************************
* Number of males in the household (males)
* Number of females in the household (females)
* For this variable we look through the household roster and count the number
* of male members of the household (sex=1) and the number of female 
* members of the household (sex=2) - we include the index child with the
* rest of the household
* If sex is missing for any household member then these variables are set to 
* 99 and treated as missing.
****************************************************************************.
COMPUTE id=0.
EXECUTE.
SAVE OUTFILE='C:\Young Lives\India\temp.sav'
 /KEEP=childid id sex /COMPRESSED.

GET FILE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'.
ADD FILES /FILE=*
 /FILE='C:\Young Lives\India\temp.sav'
 /DROP=age relate specrel still yrschool disabled support grading.
EXECUTE.

COMPUTE miss=0.
IF (MISSING(sex)) miss=1.
EXECUTE.

AGGREGATE
 /OUTFILE=*
 /BREAK=childid
 /pmales = PIN(sex 1 1) /pfemales = PIN (sex 2 2)
 /N=NU(sex) /miss=sum(miss).

DO IF (miss=0).
COMPUTE males=TRUNC(pmales*N)/100.
COMPUTE females=TRUNC(pfemales*N)/100.
ELSE.
COMPUTE males=99.
COMPUTE females=99.
END IF.
EXECUTE.

VARIABLE LABEL males "Number of males in the household".
VARIABLE LABEL females "Number of females in the household".
VALUE LABEL males females 99 "Missing".
MISSING VALUES males females (99).
FORMAT males females (F4.0).

SORT CASES BY childid.
MATCH FILES /FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /FILE=*   /BY childid   /DROP=pmales pfemales miss n.
EXECUTE.

*****************************************************************************
* Gender structure in the household (genstruc)
* For this variable we compare the number of males and females in the
* household using the variables 'males' and 'females' created above.
* Codes for this new variable will be 1 - More males than females, 
* 2 - More females than males, 3 - equal numbers of males and females.
* If one or both of the component variables are missing (99), then this
* variable will be set to 99 and treated as missing.
*****************************************************************************.

IF (males>females) genstruc=1.
IF (females>males) genstruc=2.
IF (males=females) genstruc=3.
EXECUTE.

IF (MISSING(males) | MISSING(females)) genstruc=99.
EXECUTE.

VARIABLE LABEL genstruc "Gender structure in the household".
VALUE LABEL genstruc 1 "More males than females"
 2 "More females than males" 3 "Equal numbers of males and females"
 99 "Missing".
MISSING VALUES genstruc (99).
FORMAT genstruc (F4.0).

***********************************************************************
* Sex of the household head (hdsex)
* To calculate this variable we use the variable 'headid' to find the 
* record in the roster for the household head and then take the value of the 
* variable 'sex' for that record.
* If any of the component variables are missing (99), then this variable
* will be set to 99 and treated as missing.
********************************************************************.
MATCH FILES /FILE=*
 /TABLE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'
 /RENAME (id=headid) (sex=hdsex)
 /BY childid headid
 /DROP= age disabled relate specrel still support yrschool grading.
EXECUTE.

IF (MISSING(headid)) hdsex=99.
EXECUTE.
VARIABLE LABEL hdsex "Sex of head of household".
VALUE LABEL hdsex 1 "Male" 2 "Female" 99 "Missing".
MISSING VALUE hdsex (99).

*********************************************************************
* Sex of the caregiver (cgsex).
* To calculate this variable we use the variable 'careid' to find the 
* record in the roster for the caregiver and then take the value of the 
* variable 'sex' for that record.
* If any of the component variables are missing (99), this this variable
* will be set to 99 and treated as missing.
***************************************************************.
MATCH FILES /FILE=*
 /TABLE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'
 /RENAME (id=careid) (sex=cgsex)
 /BY childid careid
 /DROP= age disabled relate specrel still support yrschool grading.
EXECUTE.

IF (MISSING(careid)) cgsex=99.
EXECUTE.
VARIABLE LABEL cgsex "Sex of the caregiver".
VALUE LABEL cgsex 1 "Male" 2 "Female" 99 "Missing".
MISSING VALUES cgsex (99).

**************************************************************************  
* Sibling status (siblings).
* This variable is set to 1 if the child's mother gave birth to other children
* and is 2 if the YL child is the only child.  
* Note this only looks at children that have been born to the mother and
* not whether they are still alive
* Also some of the siblings may no longer be living in the household.
* This uses the variable 'chdborn' to see whether other children have been
* born to the mother.
* If chdborn is missing (99), then siblings will be set to 99 and treated 
* as missing.
************************************************************************.

DO IF (chdborn=1).
COMPUTE siblings=2.
ELSE.
COMPUTE siblings=1.
END IF.
IF (MISSING(chdborn)) siblings=99.
EXECUTE.

VARIABLE LABEL siblings "Has the child's mother had other children?".
VALUE LABEL siblings 1 "Yes" 2 "No" 99 "NK".
MISSING VALUES siblings (99).
FORMAT siblings (F4.0).

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' /COMPRESSED.

***********************************************************************
* AGE STRUCTURE IN THE HOUSEHOLD
* Number of infants in the household (infkid)
* Number of school aged children in the household (schkid)
* Number of adults in the household (hhadults)
* Using the 'age' variable in the household roster we can divide household
* members into one of the age ranges 0 to 5yrs, 5 to 15yrs and 16yrs or over
* If the 'age' variable is missing for any of the household members then 
* all three of these variables will be missing (99).
************************************************************************.

GET FILE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'.

COMPUTE miss=0.
IF (MISSING(age)) miss=1.
EXECUTE.

AGGREGATE
  /OUTFILE=*
  /BREAK=childid
  /pinfkid=PIN(age 0 4) /pschkid=PIN(age 5 15) /padult=PIN(age 16 110)
  /N=NU(age) /miss=sum(miss).

DO IF (miss=0).
COMPUTE infkid=TRUNC(pinfkid*N)/100.
COMPUTE schkid=TRUNC(pschkid*N)/100.
COMPUTE hhadults=TRUNC(padult*N)/100.
ELSE.
COMPUTE infkid=99.
COMPUTE schkid=99.
COMPUTE hhadults=99.
END IF.
EXECUTE.

VARIABLE LABEL infkid 'Number of children in household under 5yrs'.
VARIABLE LABEL schkid 'Number of school aged children in household'.
VARIABLE LABEL hhadults 'Number of adults in household'.
VALUE LABELS infkid schkid hhadults 99 "Missing".
MISSING VALUES infkid schkid hhadults (99).
FORMAT infkid schkid hhadults (F4.0).

SORT CASES BY childid.

MATCH FILES /FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
  /FILE=*  /BY childid  /DROP pinfkid pschkid padult n miss.
EXECUTE.

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' /COMPRESSED.

***********************************************************************
* Number of brothers in the household (brothers)
* Number of sisters in the household (sisters)
* Siblings in the household have relate=5, half-siblings have relate=10,
* and step-siblings have relate=12.  
* For these variables we count the number of siblings (including half-siblings
* and step-siblings) in the household and divide into males (brothers) and
* females (sisters).
* We have no information about siblings living outside the household.
* If relate or sex is unknown for any household member then brothers and
* sisters are both set to 99 and treated as missing.
***********************************************************************.

GET FILE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'.

COMPUTE miss=0.
COMPUTE brother=0.
COMPUTE sister=0.
IF (MISSING(sex) | MISSING(relate)) miss=1.
IF (sex=1 & (relate=5 | relate=10 | relate=12)) brother=1.
IF (sex=2 & (relate=5 | relate=10 | relate=12)) sister=1.
EXECUTE.

AGGREGATE /OUTFILE=* /BREAK=childid
 /brothers=SUM(brother) /sisters=SUM(sister) /miss=SUM(miss).

DO IF (miss>0).
COMPUTE brothers=99.
COMPUTE sisters=99.
END IF.
EXECUTE.

VARIABLE LABEL brothers "Number of brothers (of index child) in the household".
VARIABLE LABEL sisters "Number of sisters (of index child) in the household".
VALUE LABEL brothers sisters 99 "Missing".
MISSING VALUES brothers sisters (99).
FORMAT brothers sisters (F4.0).

SORT CASES BY childid.
MATCH FILES /FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /FILE=* /BY childid /DROP=miss.
EXECUTE.

*********************************************************************
* Sibling composition in the household (sibcomp)
* Using the number of brothers and sisters in the household together with
* the sex of the index child we calculate this variable with the following
* codes:
* 1 - Index child has no siblings in the household
* 2 - Index child is the only girl with male siblings
* 3 - Index child is the only boy with female siblings
* 4 - Female index child with only female siblings
* 5 - Male index child with only male siblings
* 6 - Index child has male and female siblings
* If brothers or sisters are missing then this variable is set to 99 and 
* treated as missing
**************************************************************************.

IF (MISSING(brothers) | MISSING(sisters)) sibcomp=99.
DO IF (brothers=0 & sisters=0).
COMPUTE sibcomp=1.
ELSE IF (sex=2 & brothers>0 & sisters=0).
COMPUTE sibcomp=2.
ELSE IF (sex=1 & brothers=0 & sisters>0).
COMPUTE sibcomp=3.
ELSE IF (sex=2 & brothers=0 & sisters>0).
COMPUTE sibcomp=4.
ELSE IF (sex=1 & brothers>0 & sisters=0).
COMPUTE sibcomp=5.
ELSE IF ((sex=1 | sex=2) & brothers>0 & sisters>0).
COMPUTE sibcomp=6.
END IF.
EXECUTE.

VARIABLE LABEL sibcomp "Gender composition of siblings".
VALUE LABEL sibcomp
  1 "Index child - only child"
  2 "Index child - only girl with male siblings"
  3 "Index child - only boy with female siblings"
  4 "Female index child from all female family"
  5 "'Male index child from all male family"
  6 "Index child with male and female siblings"
  99 "Missing".
MISSING VALUES sibcomp (99).
FORMAT sibcomp (F4.0).

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' /COMPRESSED.

******************************************************************************
* Number of disabled people in the household (hhdisabl)
* For this variable we use the household roster and count the number
* of disabled members for each household (ie those where disabled=1.
* If disabled is missing for any household member then this new variable
* will be set to 99 and treated as missing.
**********************************************************************.
GET FILE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'.

COMPUTE miss=0.
IF (MISSING(disabled)) miss=1.
COMPUTE hhdisabl=0.
IF (disabled=1) hhdisabl=1.

AGGREGATE /OUTFILE=* /BREAK=childid
 /hhdisabl=SUM(hhdisabl) /miss=SUM(miss).

IF (miss>0) hhdisabl=99.
EXECUTE.

SORT CASES BY childid.

MATCH FILES /FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /FILE=* /BY childid /DROP=miss.
EXECUTE.

VARIABLE LABELS hhdisabl 'Number of disabled people in household'.
VALUE LABEL hhdisabl 99 "Missing".
MISSING VALUES hhdisabl (99).
FORMAT hhdisabl (F4.0).

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav'.

**************************************************************************
* Number of household members who support child financially (hhsupp)
* For this variable we use the variable 'support' from the roster counting
* the number of household members where support=1.
* We need to take into account that children <5yrs will not have a value
* for this variable.
* If support is missing for any of the household members (over 5yrs) then
* hhsupp will be set to 99 and treated as missing.
*************************************************************************.
GET FILE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'.

USE ALL.
SELECT IF (age>=5 | MISSING(age)).
EXECUTE.

COMPUTE miss=0.
IF (MISSING(support)) miss=1.
COMPUTE hhsupp=0.
IF (support=1) hhsupp=1.

AGGREGATE /OUTFILE=* /BREAK=childid
 /hhsupp=SUM(hhsupp) /miss=SUM(miss).

IF (miss>0) hhsupp=99.
EXECUTE.

SORT CASES BY childid.

MATCH FILES /FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /FILE=* /BY childid /DROP=miss.
EXECUTE.

VARIABLE LABELS hhsupp 
 "Number of household members giving financial support to child".
VALUE LABEL hhsupp 99 "Missing".
MISSING VALUES hhsupp (99).
FORMAT hhsupp (F4.0).

****************************************************************
* Education level of caregiver (caresch)
* Using the variable careid we find the roster record for the caregiver
* and take the corresponding value of yrschool.
* For India primary education is completed when the education level
* is 23 or higher.
* If the education level is missing then caresch will be set to 99
* and treated as missing.
**********************************************************.
MATCH FILES /FILE=*
 /TABLE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'
 /RENAME id=careid yrschool=cgschool sex=d0
 /BY childid careid
 /DROP= age d0 relate specrel still disabled support grading.
EXECUTE.

IF (MISSING(careid) | MISSING(cgschool)) caresch=99.
EXECUTE.

DO IF (cgschool>=23).
COMPUTE caresch=1.
ELSE IF (cgschool<23).
COMPUTE caresch=2.
END IF.
EXECUTE.

VARIABLE LABEL caresch "Education level of caregiver".
VALUE LABEL caresch 1 "Completed primary" 2 "Did not complete primary"
 99 "Missing".
MISSING VALUES caresch (99).
FORMAT caresch (F4.0).

****************************************************************
* Education level of household head (headsch)
* Using the variable headid we find the roster record for the household head
* and take the corresponding value of yrschool.
* For India primary education is completed when the education level
* is 23 or higher.
* If the education level is missing or headid is missing then 
* headsch will be set to 99 and treated as missing.
**********************************************************.
MATCH FILES /FILE=*
 /TABLE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'
 /RENAME id=headid yrschool=hdschool sex=d0
 /BY childid headid
 /DROP= age d0 relate specrel still disabled support grading.
EXECUTE.

IF (MISSING(headid) | MISSING(hdschool)) headsch=99.
EXECUTE.

DO IF (hdschool>=23).
COMPUTE headsch=1.
ELSE IF (hdschool<23).
COMPUTE headsch=2.
END IF.
EXECUTE.

VARIABLE LABEL headsch "Education level of household head".
VALUE LABEL headsch 1 "Completed primary" 2 "Did not complete primary"
 99 "Missing".
MISSING VALUES headsch (99).
FORMAT headsch (F4.0).

****************************************************************
* Education level of caregiver's partner (partsch)
* Using the variable partid we find the roster record for the caregiver's
* partner and take the corresponding value of yrschool.
* For India primary education is completed when the education level
* is 23 or higher.
* If the education level is missing or partid is missing then partsch will
* be set to 99 and treated as missing.
* If the caregiver has no partner living in the household then partsch 
* will be set to 88 and also treated as missing.
**********************************************************.
MATCH FILES /FILE=*
 /TABLE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'
 /RENAME id=partid yrschool=ptschool sex=d0
 /BY childid partid
 /DROP= age d0 relate specrel still disabled support grading.
EXECUTE.

IF (MISSING(partid) | MISSING(ptschool)) partsch=99.
EXECUTE.

DO IF (~partlive=1).
COMPUTE partsch=88.
ELSE IF (ptschool>=23).
COMPUTE partsch=1.
ELSE IF (ptschool<23).
COMPUTE partsch=2.
END IF.
EXECUTE.

VARIABLE LABEL partsch "Education level of caregiver's partner".
VALUE LABEL partsch 1 "Completed primary" 2 "Did not complete primary"
 99 "Missing" 88 "No partner".
MISSING VALUES partsch (88, 99).
FORMAT partsch (F4.0).

*************************************************************
* Age of child in months (agechild)
* This variable is calculated from the difference between the date of birth
* (dob) and the date of interview (dint).
******************************************************************.

COMPUTE agechild = DATEDIF(DINT, dob, "months").
IF (MISSING(dob) | MISSING(dint)) agechild=-9999.
EXECUTE.

VARIABLE LABEL agechild "Age of child in months".
FORMATS agechild (F5.0).
VALUE LABEL agechild -9999 "Missing".
MISSING VALUES agechild (-9999).

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' 
 /DROP=cgschool hdschool ptschool /COMPRESSED.

********************************************************************
* Age order of siblings in household (ageorder)
* This variable looks at surviving siblings within the household and determines
* whether the index child is the youngest, eldest, a middle child or an
* only child.
* If age or relate is missing for any household members then this
* variable will be set to 99 and treated as missing.
**********************************************************************.
GET FILE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'.

MATCH FILES FILE=* /TABLE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /BY childid /KEEP=relate age agechild childid.
EXECUTE.

COMPUTE miss=0.
COMPUTE younger=0.
COMPUTE older=0.
IF (MISSING(age) | MISSING(relate)) miss=1.
IF ((relate=5 | relate=10 | relate=12) & age<agechild/12) younger=1.
IF ((relate=5 | relate=10 | relate=12) & age>agechild/12) older=1.

AGGREGATE /OUTFILE=* /BREAK=childid
 /younger=SUM(younger) /older=SUM(older) /miss=SUM(miss).

DO IF (miss>0).
COMPUTE ageorder=99.
ELSE IF (older=0 & younger>0).
COMPUTE ageorder=1.
ELSE IF (older>0 & younger>0).
COMPUTE ageorder=2.
ELSE IF (older>0 & younger=0).
COMPUTE ageorder=3.
ELSE IF (older=0 & younger=0).
COMPUTE ageorder=4.
END IF.
EXECUTE.

VARIABLE LABELS ageorder "Age order of siblings in the household".
VALUE LABEL ageorder 1 "Index child is the eldest"
 2 "Index child is a middle child"
 3 "Index child is the youngest"
 4 "Index child has no siblings in the household"
 99 "Missing".
MISSING VALUES ageorder (99).
FORMAT ageorder (F4.0).

MATCH FILES FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /FILE=* /BY childid /DROP=younger older miss.
EXECUTE.

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' /COMPRESSED.

*********************************************************************
* Age of mother (agemum)
* We can only find the age of the mother if the mother is in the household.
* The mother will be the household record where relate=1 and sex=2.
* Once we identify this record we can pick up the corresponding value
* of age and assign this to the new variable agemum.
* Where the mother is not in the household or the age is missing then
* agemum will be set to -9999 and treated as missing.
*
* Disability status of mother (disabmum)
* When we identify the mother's record from the roster we also look at
* the variable disabled to determine whether or not the mother is disabled.
* When the mother is not in the household or the value of disabled is
* missing, then disabmum will be set to 99 and treated as missing
********************************************************************.
GET FILE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'.

USE ALL.
SELECT IF(relate=1 & sex=2).
EXECUTE.

MATCH FILES /FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /TABLE=* /RENAME (sex=sextemp) (age=agemum) (disabled=disabmum)
 /BY childid /DROP=id sextemp relate specrel still yrschool support grading.
EXECUTE.

IF (MISSING(agemum)) agemum=-9999.
EXECUTE.

VARIABLE LABEL agemum "Age of biological mother".
VALUE LABEL agemum -9999 "Missing".
MISSING VALUES agemum (-9999).

IF (MISSING(disabmum)) disabmum=99.
EXECUTE.

VARIABLE LABEL disabmum "Disability status of mother".
VALUE LABEL disabmum 1 "Mother has a disability"
 2 "Mother does not have a disability"
 99 "Missing".
MISSING VALUES disabmum (99).

************************************************************************
* Age of caregiver (agecare)
* We use careid to extract the caregiver's record from the household roster
* then pick out the age variable.
* In most cases the caregiver was the biological mother so there will
* be a great deal of overlap between this variable and agemum.
* Where the age is missing this variable will be set to -9999 and treated as
* missing.
*
* Disability status of caregiver (discare)
* We also look at the variable disabled to find the disability status of the 
* caregiver - again there will be overlap between this variable and disabmum.
***************************************************************************.

MATCH FILES /FILE=*
 /TABLE='C:\Young Lives\India\INSubSec2HouseholdRoster8.sav'
 /RENAME id=careid age=agecare disabled=discare sex=d0
 /BY childid careid
 /DROP= d0 relate specrel still yrschool support grading.
EXECUTE.

IF (MISSING(agecare)) agecare=-9999.
EXECUTE.

VARIABLE LABEL agecare "Age of caregiver".
VALUE LABEL agecare -9999 "Missing".
MISSING VALUES agecare (-9999).

IF (MISSING(discare)) discare=99.
EXECUTE.

VARIABLE LABEL discare "Disability status of caregiver".
VALUE LABEL discare 1 "Caregiver has a disability"
 2 "Caregiver does not have a disability"
 99 "Missing".
MISSING VALUES discare (99).

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' /COMPRESSED.

****************************************************************************************
* Livelihoods Sectors (sector1 through to sector9)
* For each household we look at the activities recorded and group then by
* the assigned activity code into the 9 economic sectors.  
* These variables will all have a code for Yes if the household is involved in
* that particular sector and a code for No otherwise.
* Note: some households have no activities recorded and some activities
* were not assigned codes.
**********************************************************************************.
GET FILE='C:\Young Lives\India\INSubSec7HHLivelihoods8.sav'.

RECODE actcode (01 thru 05=1) (10 thru 14=2) (15 thru 37=3) (40 thru 41=4)
 (45=5) (50 thru 55=6) (60 thru 64=7) (65 thru 74=8) (75 thru 99=9)
 INTO sector.
EXECUTE.

IF (MISSING(actcode)) sector=99.

AGGREGATE
  /OUTFILE=*
  /BREAK=childid sector
  /count=N.

AGGREGATE
  /OUTFILE=*
  /BREAK=childid
  /sector1 = PIN(sector 1 1) /sector2 = PIN(sector 2 2) /sector3 =
  PIN(sector 3 3) /sector4 = PIN(sector 4 4) /sector5 = PIN(sector 5 5)
 /sector6 = PIN(sector 6 6) /sector7 = PIN(sector 7 7) /sector8 =
  PIN(sector 8 8) /sector9 = PIN(sector 9 9) /count=N.

SORT CASES BY childid.
MATCH FILES /FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /FILE=* /BY childid.
EXECUTE.

IF(sector1>0) sector1=1.
IF(sector2>0) sector2=1.
IF(sector3>0) sector3=1.
IF(sector4>0) sector4=1.
IF(sector5>0) sector5=1.
IF(sector6>0) sector6=1.
IF(sector7>0) sector7=1.
IF(sector8>0) sector8=1.
IF(sector9>0) sector9=1.
EXECUTE.

IF (MISSING(count)) sector1=99.
IF (MISSING(count)) sector2=99.
IF (MISSING(count)) sector3=99.
IF (MISSING(count)) sector4=99.
IF (MISSING(count)) sector5=99.
IF (MISSING(count)) sector6=99.
IF (MISSING(count)) sector7=99.
IF (MISSING(count)) sector8=99.
IF (MISSING(count)) sector9=99.
EXECUTE.

VALUE LABELS sector1 sector2 sector3 sector4 sector5 sector6 sector7 sector8
  sector9 1 "Yes" 0 "No" 99 "Household has no recorded activities".
VARIABLE LABEL sector1 'Agriculture, hunting, forestry & fishing'.
VARIABLE LABEL sector2 'Mining & quarrying'.
VARIABLE LABEL sector3 'Manufacturing'.
VARIABLE LABEL sector4 'Electricity, gas & water'.
VARIABLE LABEL sector5 'Construction'.
VARIABLE LABEL sector6 'Wholesale & retail trade'.
VARIABLE LABEL sector7 'Transport, storage & communications'.
VARIABLE LABEL sector8 'Finance, insurance, real estate & business services'.
VARIABLE LABEL sector9 'Community, social & personal services'.
MISSING VALUES sector1 sector2 sector3 sector4 sector5 sector6 sector7 sector8
  sector9 (99).
FORMAT sector1 sector2 sector3 sector4 sector5 sector6 sector7 sector8
 sector9 (F4.0).

************************************************************************
* Diversification across sectors (sectors)
* Here we look at whether household members have done work in just one
* or in more sectors of the economy.
* This uses the variables created above to calculate the number of 
* sectors that household members are involved in.
*********************************************************************.

COMPUTE sectors=0.
IF (sector1=1) sectors=sectors+1.
IF (sector2=1) sectors=sectors+1.
IF (sector3=1) sectors=sectors+1.
IF (sector4=1) sectors=sectors+1.
IF (sector5=1) sectors=sectors+1.
IF (sector6=1) sectors=sectors+1.
IF (sector7=1) sectors=sectors+1.
IF (sector8=1) sectors=sectors+1.
IF (sector9=1) sectors=sectors+1.
EXECUTE.

VARIABLE LABEL sectors "Diversification between sectors".
RECODE sectors (0=0) (1=1) (2 thru highest=2).
VALUE LABEL sectors 
  0 "No recorded activity"
  1 "Activities in one sector"
  2 "Activities in more than one sector".
EXECUTE.
FORMAT sectors (F4.0).

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' /COMPRESSED
 /DROP count.

*************************************************************
* Economic activities done by caregiver (careact)
* This variable is the number of economic activities that have been
* recorded as having been done by the caregiver.  
* The ID in the livelihoods list is matched with the variable careid
* to pick out the caregiver's activities.
**********************************************************************.

GET FILE='C:\Young Lives\India\INSubSec7HHLivelihoods8.sav'.

SORT CASES BY childid id.
EXECUTE.

MATCH FILES /FILE=*
 /RENAME  id=careid 
 /TABLE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /BY childid careid
 /KEEP formno childid careid linecode.
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF(formno ~= "").
EXECUTE .

AGGREGATE
  /OUTFILE=*
  /BREAK=childid
  /careact=N.

MATCH FILES /FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /FILE=* 
 /BY childid.
EXECUTE.

IF (MISSING(careact)) careact=0.
EXECUTE.
VARIABLE LABEL careact
 "Number of activities done by caregiver in past 12 months".

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' /COMPRESSED.

*************************************************************
* Economic activities done by household head (headact)
* This variable is the number of economic activities that have been
* recorded as having been done by the household head.  
* The ID in the livelihoods list is matched with the variable headid
* to pick out the activities of the household head.
**********************************************************************.

GET FILE='C:\Young Lives\India\INSubSec7HHLivelihoods8.sav'.

SORT CASES BY childid id.
EXECUTE.

MATCH FILES /FILE=*
 /RENAME  id=headid
 /TABLE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /BY childid headid
 /KEEP formno childid headid linecode.
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF(formno ~= "").
EXECUTE .

AGGREGATE
  /OUTFILE=*
  /BREAK=childid
  /headact=N.

MATCH FILES /FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /FILE=* 
 /BY childid.
EXECUTE.

IF (MISSING(headact)) headact=0.
EXECUTE.
IF (MISSING(headid)) headact=99.
EXECUTE.
VARIABLE LABEL headact
 "Number of activities done by household head in past 12 months".
VALUE LABEL headact 99 "Missing".
MISSING VALUES headact (99).

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' /COMPRESSED.

*************************************************************
* Economic activities done by caregiver's partner (partner)
* This variable is the number of economic activities that have been
* recorded as having been done by the caregiver's partner
* The ID in the livelihoods list is matched with the variable partid
* to pick out the partner's activities.
* If there is no partner this variable is set to 99 and treated as missing
**********************************************************************.

GET FILE='C:\Young Lives\India\INSubSec7HHLivelihoods8.sav'.

SORT CASES BY childid id.
EXECUTE.

MATCH FILES /FILE=*
 /RENAME  id=partid 
 /TABLE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /BY childid partid
 /KEEP formno childid partid linecode.
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF(formno ~= "").
EXECUTE .

AGGREGATE
  /OUTFILE=*
  /BREAK=childid
  /partact=N.

MATCH FILES /FILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /FILE=* 
 /BY childid.
EXECUTE.

IF (MISSING(partact)) partact=0.
EXECUTE.
IF (MISSING(partid)) partact=99.
EXECUTE.
IF (~partlive=1) partact=88.
EXECUTE.

VARIABLE LABEL partact
 "Number of activities done by caregiver's partner in past 12 months".
VALUE LABEL partact 99 "Missing" 88 "No partner in the household".
MISSING VALUES partact (88, 99).

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav' /COMPRESSED.



***********************************************************************
* The variables that follow are specific to the 8yr old dataset.
* Variables above this point are also calculated for the 1yr old dataset.
******************************************************************************.
************************************************************************
* Ravens results Series A (ra1 - ra12)
* The correct answers for series A in the Ravens Test are:
* Item 1 = 4, Item 2 = 5, Item 3 = 1, Item 4 = 2, Item 5 = 6, Item 6 = 3
* Item 7 = 6, Item 8 = 2, Item 9 = 1, Item 10 = 3, Item 11 = 4, Item 12 = 5
* We create 12 new variables for series A each will have a value of 1
* if the answer was correct or 0 for an incorrect answer.
* 5 of the children did not take the test
* Where the response is missing it is assumed the child did not
* know the answer and these are treated as incorrect responses.
********************************************************************.

COMPUTE ra1=0.
COMPUTE ra2=0.
COMPUTE ra3=0.
COMPUTE ra4=0.
COMPUTE ra5=0.
COMPUTE ra6=0.
COMPUTE ra7=0.
COMPUTE ra8=0.
COMPUTE ra9=0.
COMPUTE ra10=0.
COMPUTE ra11=0.
COMPUTE ra12=0.

IF (a1=4) ra1=1.
IF (a2=5) ra2=1.
IF (a3=1) ra3=1.
IF (a4=2) ra4=1.
IF (a5=6) ra5=1.
IF (a6=3) ra6=1.
IF (a7=6) ra7=1.
IF (a8=2) ra8=1.
IF (a9=1) ra9=1.
IF (a10=3) ra10=1.
IF (a11=4) ra11=1.
IF (a12=5) ra12=1.

DO IF (childid="IN151042" | childid="IN021008" | childid="IN021003" | 
  childid="IN041016" | childid="IN071034").
COMPUTE ra1=88.
COMPUTE ra2=88.
COMPUTE ra3=88.
COMPUTE ra4=88.
COMPUTE ra5=88.
COMPUTE ra6=88.
COMPUTE ra7=88.
COMPUTE ra8=88.
COMPUTE ra9=88.
COMPUTE ra10=88.
COMPUTE ra11=88.
COMPUTE ra12=88.
END IF.

EXECUTE.

VARIABLE LABELS 
 ra1 "Ravens Series A - Item 1 result"
 ra2 "Ravens Series A - Item 2 result"
 ra3 "Ravens Series A - Item 3 result"
 ra4 "Ravens Series A - Item 4 result"
 ra5 "Ravens Series A - Item 5 result"
 ra6 "Ravens Series A - Item 6 result"
 ra7 "Ravens Series A - Item 7 result"
 ra8 "Ravens Series A - Item 8 result"
 ra9 "Ravens Series A - Item 9 result"
 ra10 "Ravens Series A - Item 10 result"
 ra11 "Ravens Series A - Item 11 result"
 ra12 "Ravens Series A - Item 12 result".
VALUE LABEL ra1 ra2 ra3 ra4 ra5 ra6 ra7 ra8 ra9 ra10 ra11 ra12
 0 "Incorrect answer" 1 "Correct answer" 88 "Child did not take Ravens test".
MISSING VALUES ra1 ra2 ra3 ra4 ra5 ra6 ra7 ra8 ra9 ra10 ra11 ra12 (88).
FORMAT ra1 ra2 ra3 ra4 ra5 ra6 ra7 ra8 ra9 ra10 ra11 ra12 (F4.0).

************************************************************************
* Ravens results Series AB (rab1 - rab12)
* The correct answers for series AB in the Ravens Test are:
* Item 1 = 4, Item 2 = 5, Item 3 = 1, Item 4 = 6, Item 5 = 2, Item 6 = 1
* Item 7 = 3, Item 8 = 4, Item 9 = 6, Item 10 = 3, Item 11 = 5, Item 12 = 2
* We create 12 new variables for series AB each will have a value of 1
* if the answer was correct or 0 for an incorrect answer.
* 5 of the children did not take the test
* Where the response is missing it is assumed the child did not
* know the answer and these are treated as incorrect responses.
********************************************************************.

COMPUTE rab1=0.
COMPUTE rab2=0.
COMPUTE rab3=0.
COMPUTE rab4=0.
COMPUTE rab5=0.
COMPUTE rab6=0.
COMPUTE rab7=0.
COMPUTE rab8=0.
COMPUTE rab9=0.
COMPUTE rab10=0.
COMPUTE rab11=0.
COMPUTE rab12=0.

IF (ab1=4) rab1=1.
IF (ab2=5) rab2=1.
IF (ab3=1) rab3=1.
IF (ab4=6) rab4=1.
IF (ab5=2) rab5=1.
IF (ab6=1) rab6=1.
IF (ab7=3) rab7=1.
IF (ab8=4) rab8=1.
IF (ab9=6) rab9=1.
IF (ab10=3) rab10=1.
IF (ab11=5) rab11=1.
IF (ab12=2) rab12=1.

DO IF (childid="IN151042" | childid="IN021008" | childid="IN021003" | 
  childid="IN041016" | childid="IN071034").
COMPUTE rab1=88.
COMPUTE rab2=88.
COMPUTE rab3=88.
COMPUTE rab4=88.
COMPUTE rab5=88.
COMPUTE rab6=88.
COMPUTE rab7=88.
COMPUTE rab8=88.
COMPUTE rab9=88.
COMPUTE rab10=88.
COMPUTE rab11=88.
COMPUTE rab12=88.
END IF.

EXECUTE.

VARIABLE LABELS 
 rab1 "Ravens Series AB - Item 1 result"
 rab2 "Ravens Series AB - Item 2 result"
 rab3 "Ravens Series AB - Item 3 result"
 rab4 "Ravens Series AB - Item 4 result"
 rab5 "Ravens Series AB - Item 5 result"
 rab6 "Ravens Series AB - Item 6 result"
 rab7 "Ravens Series AB - Item 7 result"
 rab8 "Ravens Series AB - Item 8 result"
 rab9 "Ravens Series AB - Item 9 result"
 rab10 "Ravens Series AB - Item 10 result"
 rab11 "Ravens Series AB - Item 11 result"
 rab12 "Ravens Series AB - Item 12 result".
VALUE LABEL rab1 rab2 rab3 rab4 rab5 rab6 rab7 rab8 rab9 rab10 rab11 rab12
 0 "Incorrect answer" 1 "Correct answer" 88 "Child did not take Ravens test".
MISSING VALUES rab1 rab2 rab3 rab4 rab5 rab6 rab7 rab8 rab9 rab10 rab11 rab12
  (88).
FORMAT rab1 rab2 rab3 rab4 rab5 rab6 rab7 rab8 rab9 rab10 rab11 rab12 (F4.0).

************************************************************************
* Ravens results Series B (rb1 - rb12)
* The correct answers for series B in the Ravens Test are:
* Item 1 = 2, Item 2 = 6, Item 3 = 1, Item 4 = 2, Item 5 = 1, Item 6 = 3
* Item 7 = 5, Item 8 = 6, Item 9 = 4, Item 10 = 3, Item 11 = 4, Item 12 = 5
* We create 12 new variables for series B each will have a value of 1
* if the answer was correct or 0 for an incorrect answer.
* 5 of the children did not take the test
* Where the response is missing it is assumed the child did not
* know the answer and these are treated as incorrect responses.
********************************************************************.

COMPUTE rb1=0.
COMPUTE rb2=0.
COMPUTE rb3=0.
COMPUTE rb4=0.
COMPUTE rb5=0.
COMPUTE rb6=0.
COMPUTE rb7=0.
COMPUTE rb8=0.
COMPUTE rb9=0.
COMPUTE rb10=0.
COMPUTE rb11=0.
COMPUTE rb12=0.

IF (b1=2) rb1=1.
IF (b2=6) rb2=1.
IF (b3=1) rb3=1.
IF (b4=2) rb4=1.
IF (b5=1) rb5=1.
IF (b6=3) rb6=1.
IF (b7=5) rb7=1.
IF (b8=6) rb8=1.
IF (b9=4) rb9=1.
IF (b10=3) rb10=1.
IF (b11=4) rb11=1.
IF (b12=5) rb12=1.

DO IF (childid="IN151042" | childid="IN021008" | childid="IN021003" | 
  childid="IN041016" | childid="IN071034").
COMPUTE rb1=88.
COMPUTE rb2=88.
COMPUTE rb3=88.
COMPUTE rb4=88.
COMPUTE rb5=88.
COMPUTE rb6=88.
COMPUTE rb7=88.
COMPUTE rb8=88.
COMPUTE rb9=88.
COMPUTE rb10=88.
COMPUTE rb11=88.
COMPUTE rb12=88.
END IF.

EXECUTE.

VARIABLE LABELS 
 rb1 "Ravens Series B - Item 1 result"
 rb2 "Ravens Series B - Item 2 result"
 rb3 "Ravens Series B - Item 3 result"
 rb4 "Ravens Series B - Item 4 result"
 rb5 "Ravens Series B - Item 5 result"
 rb6 "Ravens Series B - Item 6 result"
 rb7 "Ravens Series B - Item 7 result"
 rb8 "Ravens Series B - Item 8 result"
 rb9 "Ravens Series B - Item 9 result"
 rb10 "Ravens Series B - Item 10 result"
 rb11 "Ravens Series B - Item 11 result"
 rb12 "Ravens Series B - Item 12 result".
VALUE LABEL rb1 rb2 rb3 rb4 rb5 rb6 rb7 rb8 rb9 rb10 rb11 rb12
 0 "Incorrect answer" 1 "Correct answer" 88 "Child did not take Ravens test".
MISSING VALUES rb1 rb2 rb3 rb4 rb5 rb6 rb7 rb8 rb9 rb10 rb11 rb12  (88).
FORMAT rb1 rb2 rb3 rb4 rb5 rb6 rb7 rb8 rb9 rb10 rb11 rb12 (F4.0).

******************************************************************************
* Score for Series (seta), Score for Series AB (setab)
* Score for Series B (setb), Total Ravens Score (ravens)
* These variables will contain the total number of correct responses for
* each of the three series - seta, setab and setb will all be numbers between
* 0 and 12 - Ravens will be the sum of these 3 variables and will be a number
* between 0 and 36.
* Where the child did not take the test the 3 variables are set to 88.
* *************************************************************************.

COMPUTE seta=ra1+ra2+ra3+ra4+ra5+ra6+ra7+ra8+ra9+ra10+ra11+ra12.
COMPUTE setab=rab1+rab2+rab3+rab4+rab5+rab6+rab7+rab8+rab9+rab10+rab11+rab12.
COMPUTE setb=rb1+rb2+rb3+rb4+rb5+rb6+rb7+rb8+rb9+rb10+rb11+rb12.
COMPUTE ravens=seta+setab+setb.

DO IF (childid="IN151042" | childid="IN021008" | childid="IN021003" | 
  childid="IN041016" | childid="IN071034").
COMPUTE seta=88.
COMPUTE setab=88.
COMPUTE setb=88.
COMPUTE ravens=88.
END IF.

VARIABLE LABEL seta "Number of correct responses in Series A".
VARIABLE LABEL setab "Number of correct responses in Series AB".
VARIABLE LABEL setb "Number of correct responses in Series B".
VARIABLE LABEL ravens "Number of correct responses in Ravens test".
VALUE LABEL seta setb setab ravens 88 "Child did not take Ravens test".
MISSING VALUES seta setab setb ravens (88).
FORMAT seta setab setb ravens (F4.0).

**************************************************************************
* Long term health problem (longterm)
* This is a combination of the responses to the questions on whether
* the child has health problems that affect how they make friends (hpfriend),
* how they work or go to school (hpwork), or any other long term health
* problem (hpoth).  
* If there is a Yes response to any of these questions then this new
* variable is set to Yes, otherwise it is set to No.
* If any of the component variables are missing then this new variable
* is set to 99 and treated as missing.
**************************************************************************.

COMPUTE longterm=0.
IF (hpfriend=1 | hpwork=1 | hpoth=1) longterm=1.
IF (MISSING(hpfriend) | MISSING(hpwork) | MISSING(hpoth)) longterm=99.
EXECUTE.

VARIABLE LABEL longterm "Any long term health problems?".
VALUE LABEL longterm 1 "Yes" 0 "No" 99 "Missing".
MISSING VALUES longterm (99).
FORMAT longterm (F4.0).

************************************************************************
* Child's schooling status (schlstat)
* For this variable we combine responses to the questions "Has the child
* ever attended school?" (eversch) and "Is the child currently in school?"
* (schnow).
* Codes for this new variable are 1 - Child currently in school,
* 2 - Child dropped out of school, 3 - Child never attended school.
* If either of the component variables are missing then this variable is
* set to 99 and treated as missing.
***********************************************************************.

DO IF (eversch=1 & schnow=1).
COMPUTE schlstat=1.
ELSE IF (eversch=1 & schnow=2).
COMPUTE schlstat=2.
ELSE IF (eversch=2).
COMPUTE schlstat=3.
END IF.

IF (MISSING(eversch) | MISSING(schnow)) schlstat=99.
EXECUTE.

VARIABLE LABEL schlstat "Child's schooling status".
VALUE LABEl schlstat 1 "Currently in school" 2 "Dropped out of school"
  3 "Never attended school" 99 "Missing".
MISSING VALUES schlstat (99).
FORMAT schlstat (F4.0).

***************************************************************************
* Child's working status (chwkstat)
* This is a combination of the responses to the questions on whether or not
* the child has done any formal work (namewrk) and whether or not the child 
* does household chores (chores)
* Resulting codes for this variable are: 1 - Child does not work
* 2 - Child has done formal work, 3 - Child does household chores
* 4 - Child has done formal work and does household chores.
* If either of the component variables are missing then this variable will
* be set to 99 and treated as missing.
*************************************************************************.

DO IF (namewrk=2 & chores=2).
COMPUTE chwkstat=1.
ELSE IF (namewrk=1 & chores=2).
COMPUTE chwkstat=2.
ELSE IF (namewrk=2 & chores=1).
COMPUTE chwkstat=3.
ELSE IF (namewrk=1 & chores=1).
COMPUTE chwkstat=4.
END IF.

IF (MISSING(chores) | MISSING(namewrk)) chwkstat=99.
EXECUTE.

VARIABLE LABEL chwkstat "Child's working status".
VALUE LABEL chwkstat
 1 "Child has not done any formal work nor regular chores"
 2 "Child has done formal work but not regular chores"
 3 "Child has not done formal work but does regular chores"
 4 "Child has done formal work and does regular chores"
 99 "Missing".
MISSING VALUES chwkstat (99).
FORMAT chwkstat (F4.0).

**********************************************************************
* Child's perception of well being (chldpowb)
* To calculate this variable we look at the responses to the questions
* from the child questionnaire about the state of the water (water), 
* the air quality (air), the amount of rubbish in the area (rubbish), 
* whether the area is safe (safe), how others in the community treat the
* child (respect), and do they get enough food to eat (food).
* We count the number of positive responses to these 6 questions and 
* group the results so that 0 to 3 positive responses gives a bad perception
* and 4 to 6 positive responses gives a good perception.
* If any of the component variables are missing, then this variable is
* set to 99 and treated as missing.
***************************************************************************.
COMPUTE chldpowb=0.
IF (water=1) chldpowb=chldpowb+1.
IF (air=1) chldpowb=chldpowb+1.
IF (rubbish=1) chldpowb=chldpowb+1.
IF (respect=1) chldpowb=chldpowb+1.
IF (safe=1) chldpowb=chldpowb+1.
IF (food=1) chldpowb=chldpowb+1.

IF (MISSING(water) | MISSING(air) | MISSING(rubbish) | MISSING(respect) | 
 MISSING(safe) | MISSING(food)) chldpowb=99.
EXECUTE.

RECODE chldpowb (0 thru 3=0) (4 thru 6=1).
EXECUTE.

VARIABLE LABEL chldpowb "Child's Perception of Well-being".
VALUE LABEL chldpowb 1 "Good" 0 "Bad" 99 "Missing".
MISSING VALUES chldpowb (99).
FORMAT chldpowb (F4.0).

*****************************************************************************
* Child Mental Health - SDQ
* Emotional Symptoms Score (ess)
* The emotional symptoms score is based on responses to the 5 questions:
* 1 - Often complains of headaches, stomach-aches or sickness (chhead)
* 2 - Many worries, often seems worried (worries)
* 3 - Often unhappy, downhearted or tearful (chunhap)
* 4 - Nervous or clingy in new situations (clingy)
* 5 - Many fears, easily scared (fears)
* These variables have the coding 1 = Not true, 2 = Somewhat true,
* 3 = Certainly true.
* Recoding is done to make the codes 0, 1, & 2.
* The variables are then summed to give a score which is then 
* grouped into Abnormal, Borderline and Normal.
* If any of the component variables are missing then this variable
* will be set to 99 and treated as missing.
**************************************************************************.

RECODE chhead worries chunhapy clingy fears (1=0) (2=1) (3=2) INTO
 rchhead rworries rchunhap rclingy rfears.
COMPUTE ess=rchhead+rworries+rchunhap+rclingy+rfears.
EXECUTE.

IF (MISSING(chhead) | MISSING(worries) | MISSING(chunhapy) | MISSING(clingy)
 | MISSING(fears)) ess=99.
EXECUTE.

RECODE ess (0 thru 3=0) (4=1) (5 thru 10=2).
EXECUTE.

VARIABLE LABEL ess "Emotional Symptoms Score".
VALUE LABEL ess 0 "Normal" 1 "Borderline" 2 "Abnormal"
 99 "Missing".
MISSING VALUES ess (99).
FORMAT ess (F4.0).

*****************************************************************************
* Conduct Problems Score (cps)
* The Conduct Problems Score is based on responses to the 5 questions:
* 1 - Often has temper tantrums (temper)
* 2 - Generally obedient, usually does what adult requests (obedient)
* 3 - Often fights with other children or bullies them (fights)
* 4 - Often lies or cheats (lies)
* 5 - Steals from home, school or elsewhere (steals)
* These variables have the coding 1 = Not true, 2 = Somewhat true,
* 3 = Certainly true.
* Recoding is done to make the codes 0, 1, & 2 with the exception of
* the variable obedient which is recoded so that 2=Not true, 1 =Somewhat true
* and 0=Certainly true.
* The variables are then summed to give a score which is then 
* grouped into Abnormal, Borderline and Normal.
* If any of the component variables are missing then this variable
* will be set to 99 and treated as missing.
**************************************************************************.

RECODE temper fights lies steals (1=0) (2=1) (3=2) INTO
 rtemper rfights rlies rsteals.
RECODE obedient (1=2) (2=1) (3=0) INTO robedien.
COMPUTE cps=rtemper+robedien+rfights+rlies+rsteals.
EXECUTE.

IF (MISSING(temper) | MISSING(obedient) | MISSING(fights) | MISSING(lies)
 | MISSING(steals)) cps=99.
EXECUTE.

RECODE cps (0 thru 2=0) (3=1) (4 thru 10=2).
EXECUTE.

VARIABLE LABEL cps "Conduct Problems Score".
VALUE LABEL cps 0 "Normal" 1 "Borderline" 2 "Abnormal"
 99 "Missing".
MISSING VALUES cps (99).
FORMAT cps (F4.0).

*****************************************************************************
* Hyperactivity score (hs)
* The Hyperactivity Score is based on responses to the 5 questions:
* 1 - Restless, overactive, cannot stay still for long (restless)
* 2 - Constantly fidgeting or squirming (fidget)
* 3 - Easily distracted, concentration wanders (distract)
* 4 - Thinks things out before acting (thinks)
* 5 - Sees tasks through to the end, good attention span (tasks)
* These variables have the coding 1 = Not true, 2 = Somewhat true,
* 3 = Certainly true.
* Recoding is done for the first 3 of these variables to make the codes 
* 0=Not true, 1=Somewhat true, & 2=certainly true.
* thinks and tasks are recoded so that 2=Not true, 1 =Somewhat true
* and 0=Certainly true.
* The variables are then summed to give a score which is then 
* grouped into Abnormal, Borderline and Normal.
* If any of the component variables are missing then this variable
* will be set to 99 and treated as missing.
**************************************************************************.

RECODE restless fidget distract (1=0) (2=1) (3=2) INTO
 rrestles rfidget rdistrac.
RECODE thinks tasks (1=2) (2=1) (3=0) INTO rthinks rtasks.
COMPUTE hs=rrestles+rfidget+rdistrac+rthinks+rtasks.
EXECUTE.

IF (MISSING(restless) | MISSING(fidget) | MISSING(distract) | MISSING(thinks)
 | MISSING(tasks)) hs=99.
EXECUTE.

RECODE hs (0 thru 5=0) (6=1) (7 thru 10=2).
EXECUTE.

VARIABLE LABEL hs "Hyperactivity Score".
VALUE LABEL hs 0 "Normal" 1 "Borderline" 2 "Abnormal"
 99 "Missing".
MISSING VALUES hs (99).
FORMAT hs (F4.0).

*****************************************************************************
* Peer Problems Score (pps)
* The Peer Problems Score is based on responses to the 5 questions:
* 1 - Rather solitary, tends to play alone (solitary)
* 2 - Has at least one good friend (friend)
* 3 - Generally liked by other children (liked)
* 4 - Picked on or bullied by other children (bullied)
* 5 - Gets on better with adults than with other children (adults)
* These variables have the coding 1 = Not true, 2 = Somewhat true,
* 3 = Certainly true.
* Recoding is done for 'solitary', 'bullied' and 'adults' to make the codes 
* 0=Not true, 1=Somewhat true, & 2=certainly true.
* 'friend' and 'liked' are recoded so that 2=Not true, 1 =Somewhat true
* and 0=Certainly true.
* The variables are then summed to give a score which is then 
* grouped into Abnormal, Borderline and Normal.
* If any of the component variables are missing then this variable
* will be set to 99 and treated as missing.
**************************************************************************.

RECODE solitary bullied adults (1=0) (2=1) (3=2) INTO
 rsolitar rbullied radults.
RECODE friend liked (1=2) (2=1) (3=0) INTO rfriend rliked.
COMPUTE pps=rsolitar+rfriend+rliked+rbullied+radults.
EXECUTE.

IF (MISSING(solitary) | MISSING(friend) | MISSING(liked) | MISSING(bullied)
 | MISSING(adults)) pps=99.
EXECUTE.

RECODE pps (0 thru 2=0) (3=1) (4 thru 10=2).
EXECUTE.

VARIABLE LABEL pps "Peer Problems Score".
VALUE LABEL pps 0 "Normal" 1 "Borderline" 2 "Abnormal"
 99 "Missing".
MISSING VALUES pps (99).
FORMAT pps (F4.0).

*****************************************************************************
* Prosocial Behaviour Score (pbs)
* The Prosocial Behaviour Score is based on responses to the 5 questions:
* 1 - Considerate of other people's feelings (feel)
* 2 - Shares readily with other children (shares)
* 3 - Helpful if someone is hurt, upset or feeling ill (helpful)
* 4 - Kind to younger children (kind)
* 5 - Often volunteers to help others (volunter)
* These variables have the coding 1 = Not true, 2 = Somewhat true,
* 3 = Certainly true.
* Recoding is done for codes  0=Not true, 1=Somewhat true, & 2=certainly true
* The variables are then summed to give a score which is then 
* grouped into Abnormal, Borderline and Normal.
* If any of the component variables are missing then this variable
* will be set to 99 and treated as missing.
**************************************************************************.

RECODE feel shares helpful kind volunter (1=0) (2=1) (3=2) INTO
 rfeel rshares rhelpful rkind rvolunte.
COMPUTE pbs=rfeel+rshares+rhelpful+rkind+rvolunte.
EXECUTE.

IF (MISSING(feel) | MISSING(shares) | MISSING(helpful) | MISSING(kind)
 | MISSING(volunter)) pbs=99.
EXECUTE.

RECODE pbs (6 thru 10=0) (5=1) (0 thru 4=2).
EXECUTE.

VARIABLE LABEL pbs "Prosocial Behaviour Score".
VALUE LABEL pbs 0 "Normal" 1 "Borderline" 2 "Abnormal"
 99 "Missing".
MISSING VALUES pbs (99).
FORMAT pbs (F4.0).

*****************************************************************************
* Total Difficulties Score (tds)
* The Total Difficulties Score is based on responses to the 20 questions
* that comprise the Emotional Symptoms Score, the Conduct Problems Score,
* The Hyperactivity Score, and the Peer Problems Score.
* The 15 variables have already been recoded so they are now just summed and
* grouped into Abnormal, Borderline and Normal.
* If any of the component variables are missing then this variable
* will be set to 99 and treated as missing.
**************************************************************************.

COMPUTE tds=rchhead+rworries+rchunhap+rclingy+rfears+
 rtemper+robedien+rfights+rlies+rsteals+
 rrestles+rfidget+rdistrac+rthinks+rtasks+
 rsolitar+rfriend+rliked+rbullied+radults.
EXECUTE.

IF (MISSING(chhead) | MISSING(worries) | MISSING(chunhapy) | MISSING(clingy)
 | MISSING(fears) | MISSING(temper) | MISSING(obedient) | MISSING(fights)
 | MISSING(lies) | MISSING(steals) | MISSING(restless) | MISSING(fidget)
 | MISSING(distract) | MISSING(thinks) | MISSING(tasks) | MISSING(solitary)
 | MISSING(friend) | MISSING(liked) | MISSING(bullied) | MISSING(adults))
 tds=99.
EXECUTE.

RECODE tds (1 thru 13=0) (14 thru 16=1) (17 thru 40=2).
EXECUTE.

VARIABLE LABEL tds "Total Difficulties Score".
VALUE LABEL tds 0 "Normal" 1 "Borderline" 2 "Abnormal"
 99 "Missing".
MISSING VALUES tds (99).
FORMAT tds (F4.0).

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\India\INChildLevel8YrOld.sav'
 /DROP rchhead rworries rchunhap rclingy rfears rtemper robedien rfights rlies
 rsteals rrestles rfidget rdistrac rthinks rtasks rsolitar rfriend rliked
 rbullied radults rfeel rshares rhelpful rkind rvolunte.


