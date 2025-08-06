								**** Obesidad y RA ****
								***Analisis de datos***
svyset clustid [pweight=clustfactor]

//Tablas univariadas//

table ( var ) ( childsex ) () [pweight=clustfactor], nototals statistic(frequency) statistic(percent) statistic(median read_rasch_r3 math_rasch_r3 bmi_r3) statistic(iqr read_rasch_r3 math_rasch_r3 bmi_r3) statistic(mean zhfa_r3 zbfa_r3 sleep_r3 age_r3) statistic(sd zhfa_r3 zbfa_r3 age_r3) statistic(fvfrequency absent_r3 typesite_r3 stunting_r3 sleep_cat_r3 bmiclass_r3 wi_tertiles_r3) statistic(fvpercent absent_r3 typesite_r3 stunting_r3 sleep_cat_r3 bmiclass_r3 wi_tertiles_r3) statistic(sd sleep_r3) nformat(%9.0f frequency) nformat(%9.1f percent) sformat("%s%%" percent) nformat(%9.1f mean) nformat(%9.2f semean) nformat(%9.1f sd) nformat(%9.0f fvfrequency) nformat(%9.1f fvpercent) nformat(%9.1f median) nformat(%9.1f iqr)

table ( var ) ( childsex ) () [pweight=clustfactor], nototals statistic(frequency) statistic(percent) statistic(median read_rasch_r5 math_rasch_r5 bmi_r5) statistic(iqr read_rasch_r5 math_rasch_r5 bmi_r5) statistic(mean zhfa_r5 zbfa_r5 sleep_r5 age_r5) statistic(sd zhfa_r5 zbfa_r5 age_r5) statistic(fvfrequency absent_r5 typesite_r5 stunting_r5 sleep_cat_r5 bmiclass_r5 wi_tertiles_r5) statistic(fvpercent absent_r5 typesite_r5 stunting_r5 sleep_cat_r5 bmiclass_r5 wi_tertiles_r5) statistic(sd sleep_r5) nformat(%9.0f frequency) nformat(%9.1f percent) sformat("%s%%" percent) nformat(%9.1f mean) nformat(%9.2f semean) nformat(%9.1f sd) nformat(%9.0f fvfrequency) nformat(%9.1f fvpercent) nformat(%9.1f median) nformat(%9.1f iqr)


//Wide to Long//
drop typesite_r3 typesite_r4 typesite_r5

reshape long absent_r read_rasch_r math_rasch_r bmi_r zhfa_r zbfa_r sleep_r sleep_cat_r wi_r bmiclass_r stunting_r age_r wi_tertiles_r, i(childid clustid) j(visit)
label drop I_HoueholdItems
label var visit ""
encode childid, gen(childcode)

xtset childcode visit

//GEE model//

**Modelos crudos**

xtgee math_rasch_r i.bmiclass_r [pweight = clustfactor], family(poisson) link (log) corr (exc) vce(robust) eform i(childcode) t(visit) 
xtgee read_rasch_r i.bmiclass_r [pweight = clustfactor], family(poisson) link (log) corr (exc) vce(robust) eform i(childcode) t(visit) 

meglm math_rasch_r i.bmiclass_r,  family(poisson) link (log) irr nocons || clustid:, pweight(clustfactor)
meglm read_rasch_r i.bmiclass_r,  family(poisson) link (log) irr nocons || clustid:, pweight(clustfactor)

**Modelos ajustados**

xtgee math_rasch_r i.bmiclass_r c.age_r i.sleep_cat_r i.wi_tertiles_r i.childsex i.stunting_r [pweight = clustfactor], family(poisson) link (log) corr (exc) vce(robust) eform i(childcode) t(visit) nocons
xtgee read_rasch_r i.bmiclass_r c.age_r i.sleep_cat_r i.wi_tertiles_r i.childsex i.stunting_r [pweight = clustfactor], family(poisson) link (log) corr (exc) vce(robust) eform i(childcode) t(visit) nocons

meglm math_rasch_r i.bmiclass_r c.age_r i.sleep_cat_r i.wi_tertiles_r i.childsex i.stunting_r,  family(poisson) link (log) irr nocons || clustid:, pweight(clustfactor)
meglm read_rasch_r i.bmiclass_r c.age_r i.sleep_cat_r i.wi_tertiles_r i.childsex i.stunting_r,  family(poisson) link (log) irr nocons || clustid:, pweight(clustfactor)


**Modelos con mediacion**
*Path analysis*

gsem (i.bmiclass_r -> math_rasch_r, ) (i.bmiclass_r -> i.absent_r, ) (i.childsex -> math_rasch_r, ) (age_r -> math_rasch_r, ) (i.wi_tertiles_r -> math_rasch_r, ) (i.sleep_cat_r -> math_rasch_r, ) (i.absent_r -> math_rasch_r, ) (i.stunting_r -> math_rasch_r, ) [pweight = clustfactor], covstructure(i.bmiclass_r c.age_r i.sleep_cat_r i.wi_tertiles_r i.childsex i.stunting_r, exchangeable) covariance( i.bmiclass_r*i.childsex c.age_r*i.bmiclass_r c.age_r*i.childsex i.wi_tertiles_r*i.bmiclass_r i.wi_tertiles_r*i.childsex i.wi_tertiles_r*c.age_r i.sleep_cat_r*i.bmiclass_r i.sleep_cat_r*i.childsex i.sleep_cat_r*c.age_r i.sleep_cat_r*i.wi_tertiles_r i.stunting_r*i.bmiclass_r i.stunting_r*i.childsex i.stunting_r*c.age_r i.stunting_r*i.wi_tertiles_r i.stunting_r*i.sleep_cat_r) family(poisson) link(log) vce(robust)

estat teffects


gsem (bmiclass_r -> read_rasch_r, ) (bmiclass_r -> absent_r, ) (childsex -> read_rasch_r, ) (age_r -> read_rasch_r, ) (wi_tertiles_r -> read_rasch_r, ) (sleep_cat_r -> read_rasch_r, ) (absent_r -> read_rasch_r, ) (stunting_r -> read_rasch_r, ) [pweight = clustfactor], vce(robust) standardized covstructure(age_r wi_tertiles_r stunting_r childsex sleep_cat_r , exchangeable) cov( childsex*bmiclass_r age_r*bmiclass_r age_r*childsex wi_tertiles_r*bmiclass_r wi_tertiles_r*childsex wi_tertiles_r*age_r sleep_cat_r*bmiclass_r sleep_cat_r*childsex sleep_cat_r*age_r sleep_cat_r*wi_tertiles_r stunting_r*bmiclass_r stunting_r*childsex stunting_r*age_r stunting_r*wi_tertiles_r stunting_r*sleep_cat_r) nocapslatent

estat teffects


xtgee math_rasch_r i.bmiclass_r age_r i.sleep_cat_r i.wi_tertiles_r i.childsex i.stunting_r i.absent_r [pweight = clustfactor], family(poisson) link (log) corr (exc) vce(robust) eform  i(childcode) t(visit) nocons

xtgee read_rasch_r i.bmiclass_r age_r i.sleep_cat_r i.wi_tertiles_r i.childsex i.stunting_r i.absent_r [pweight = clustfactor], family(poisson) link (log) corr (exc) vce(robust) eform i(childcode) t(visit) nocons

**Interaccion con sexo**
xtgee math_rasch_r i.bmiclass_r#i.childsex c.age_r i.sleep_cat_r i.wi_tertiles_r i.stunting_r [pweight = clustfactor], family(nb) link (log) corr (exc) vce(robust) eform allbaselevels i(childcode) t(visit) nocons
margins, at (childsex=(0 1) bmiclass_r=(0 1 2))
marginsplot, x(bmiclass_r) 


xtgee read_rasch_r i.bmiclass_r#i.childsex c.age_r i.sleep_cat_r i.wi_tertiles_r i.stunting_r [pweight = clustfactor], family(poisson) link (log) corr (exc) vce(robust) eform allbaselevels i(childcode) t(visit) nocons
margins, at (childsex=(0 1) bmiclass_r=(0 1 2))
marginsplot, x(bmiclass_r)

sort childsex

by childsex: xtgee math_rasch_r i.bmiclass_r c.age_r i.sleep_cat_r i.wi_tertiles_r i.stunting_r [pweight = clustfactor], family(poisson) link (log) corr (exc) vce(robust) eform i(childcode) t(visit) nocons
by childsex: xtgee read_rasch_r i.bmiclass_r c.age_r i.sleep_cat_r i.wi_tertiles_r i.stunting_r [pweight = clustfactor], family(poisson) link (log) corr (exc) vce(robust) eform i(childcode) t(visit) nocons



