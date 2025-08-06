********** Calculating Composite Variables for archiving.
********** 5yr old dataset - Ethiopia Version.

GET FILE='C:\Young Lives\Ethiopia2\ETChildLevel5YrOld.sav'.

**************************************************************************
* WEALTH INDEX CALCULATIONS
**************************************************************************
* Housing quality index (hq)
* There are 4 components of this index:
* 1 - Scaled number of rooms per person (capping at 1.5) - 
*      any values greater than 1 are set to 1.
* 2 - Add 1 if the walls are made of brick or concrete - ie wall=3
* 3 - Add 1 if the roof is made of iron, concrete, tiles or slate - 
*      ie roof=4, 15 or 6
* 4 - Add 1 if the floor is made of cement or is tiled or laminated - 
*      ie floor=1 or 6  
* The total is then divided by 4 to give the housing quality index
* If any of the compoent variables are missing (99) then hq will be missing.
*************************************************************************.

COMPUTE hq=(numroom/hhsize)/1.5.
IF (hq > 1) hq=1.
IF (wall=3) hq=hq+1.
IF (roof=4 | roof=15 | roof=6) hq=hq+1.
IF (floor=1 | floor=6) hq=hq+1.
COMPUTE hq=hq/4.

IF (MISSING(numroom) | MISSING(hhsize) | MISSING(wall) | MISSING(floor) | 
  MISSING(roof)) hq=99.
EXECUTE.

VARIABLE LABEL hq "Housing quality index".
VALUE LABEL hq 99 "Missing".
MISSING VALUES hq (99).
EXECUTE.

************************************************************************
* Consumer Durable index (cd)
* For this index we add 1 for each asset the household owns
* then divide by the total number of assets
* Productive assets (eg sewing machines) are not included in this calculation
* For Ethiopia2 12 assets are considered - Radio, Refrigerator, Bicycle,
* Television, Motorbike/scooter, Car, Mobile phone, Landline telephone, 
* Iron, Blender, electric oven, Record player.
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
IF (plancha=1) cd=cd+1.
IF (licua=1) cd=cd+1.
IF (mitad=1) cd=cd+1.
IF (tocad=1) cd=cd+1.
COMPUTE cd=cd/12.

IF (MISSING(radio) | MISSING(fridge) | MISSING(bike) | MISSING(tv) |
 MISSING(motor) | MISSING(car) | MISSING(mobphone) | MISSING(phone) |
 MISSING(plancha) | MISSING(licua) | MISSING(mitad) | MISSING(tocad)) cd=99.
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
* (drwater=1 or 10); add 1 if the household has their own toilet facility, 
* (toilet=1 or 6) and add 1 if paraffin, kerosene, gas or electricity is used 
* for cooking (cooking=8 or 9)
* The resulting value is divided by 4 to give an index between 0 and 1
* If any of the component variables are missing (99) then this 
* variable will be set to 99
***********************************************************************.

COMPUTE sv=0.
IF (elec=1) sv=sv+1.
IF (drwater=1 | drwater=10) sv=sv+1.
IF (toilet=1 | toilet=6) sv=sv+1.
IF (cooking=8 | cooking=9) sv=sv+1.
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


******************************************************************************
* Parents alive or dead (parlive)
* This variable uses code 0 from mumal (is mother alive = No) and code 0 from 
* dadal (is father alive) to work out whether the parents are dead or alive.
* Resulting codes will be 1 - Both parents alive, 2 - Mother dead/father alive
* 3 - Mother alive/father dead, 4 - Both parents dead.
* If either of the component variables are missing then parlive will be set
* to 99 and treated as missing.
******************************************************************************.

IF (MISSING(mumal) | MISSING(dadal)) parlive=99.
DO IF (mumal=1  & dadal=1).
COMPUTE parlive=1.
ELSE IF (mumal=0 | dadal=1).
COMPUTE parlive=2.
ELSE IF (mumal=1  & dadal=0).
COMPUTE parlive=3.
ELSE IF (mumal=0 & dadal=0).
COMPUTE parlive=4.
END IF.
EXECUTE.

VARIABLE LABEL parlive "Parents alive or dead".
VALUE LABEL parlive 1 "Both parents alive"
 2 "Mother dead/father alive"  3 "Mother alive/father dead"
 4 "Both parents dead" 99 "Missing".
MISSING VALUES parlive (99).
FORMAT parlive (F4.0).


*************************************************************
* Age of child in months (agechild)
* This variable is calculated from the difference between the date of birth
* (dob) and the date of interview (dint).
******************************************************************.

COMPUTE agechild = DATEDIF(DINT, dob, "months").
IF (MISSING(dint) | MISSING(dob)) agechild=-9999.
EXECUTE.

VARIABLE LABEL agechild "Age of child in months".
FORMATS agechild (F5.0).
VALUE LABEL agechild -9999 "Missing".
MISSING VALUES agechild (-9999).
EXECUTE.

SORT CASES BY childid.
SAVE OUTFILE='C:\Young Lives\Ethiopia2\ETChildLevel5YrOld.sav'.

