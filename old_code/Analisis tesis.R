#Paquetes
library(foreign)
library(dplyr)
library(lavaan.survey)
library (haven)
library (semPlot)
library (semTools)
library (survey)
library(psych)

#Directorio de trabajo
setwd("/Users/darwin/Documents/_1. Obesidad y rendimiento académico/Análisis")

rm(list=ls())

#Cargar datos de yl
yl.data <- read.dta("yl_final.dta", convert.factor=F, convert.underscore=T)
yl.CFA <- subset(yl.data, select = c(istole, sostole, stdhitu, sohit, insulted, soinsult, clustid, clustfactor))
yl.CFA <- yl.CFA %>% na_if(99)
yl.CFA <- yl.CFA %>%
  filter(!is.na(istole)&!is.na(sostole)&!is.na(stdhitu)&!is.na(sohit)&!is.na(insulted)&!is.na(soinsult)) 
yl.data <- yl.data %>%
  filter(!is.na(zbfa.r3)&!is.na(zbfa.r3)&!is.na(zbfa.r3)&
         !is.na(read.rasch.r3)&!is.na(percolang.r4)&!is.na(percoread.r5)&
         !is.na(math.rasch.r3)&!is.na(percomath.r4)&!is.na(percomath.r5)) 


#Analisis factorial confirmatorio ajustado por diseño de encuesta
    #Declarando diseño de encuesta
        cluster.group <- svydesign(ids=~clustid, weights=~clustfactor, data=yl.CFA)
        cluster.group
    #Matriz de covarianzas
        yl.CFA.2 <- subset(yl.CFA, select=c(istole, sostole, insulted, soinsult, stdhitu, sohit))
        cov(yl.CFA.2)
    #1-factor
        one.myCFAmodel <- '
                          school.climate =~ istole + sostole + stdhitu + sohit + insulted + soinsult
                          '
        myCFA.fit.one = sem(one.myCFAmodel, data=yl.CFA.2, estimator="MLR", )
        
        summary(myCFA.fit.one, fit.measures = T)
        semPaths(myCFA.fit.one,whatLabels="std",layout="tree",edge.label.cex=0.9,rotation=2,nCharNodes=15,
                 sizeLat=7,sizeMan=7,style="lisrel")
        head(modificationindices(myCFA.fit.one)[order((modificationindices(myCFA.fit.one))$mi,decreasing=TRUE),],15)
        
        
    #2-factor
        two.myCFAmodel <- '
                          stolehit1 =~ istole + sostole + stdhitu + sohit
                          insult1 =~ insulted + soinsult
                          '
        myCFA.fit.two = sem(two.myCFAmodel, data=yl.CFA.2, estimator="MLR")
        
        summary(myCFA.fit.two, fit.measures = T)
        semPaths(myCFA.fit.two,whatLabels="std",layout="tree",edge.label.cex=0.9,rotation=2,nCharNodes=15,
                 sizeLat=7,sizeMan=7,style="lisrel")
        head(modificationindices(myCFA.fit.two)[order((modificationindices(myCFA.fit.two))$mi,decreasing=TRUE),],15)
        
    #3-factor model
        three.myCFAmodel <- '
                          stole1 =~ sostole  
                          insult1 =~  insulted + soinsult + stdhitu + istole
                          hit1 =~ sohit
                          scholar.climate~stole1+insult1+hit1
                          '
        myCFA.fit.three = sem(three.myCFAmodel, data=yl.CFA.2, estimator="MLR")
    
        summary(myCFA.fit.three, fit.measures = T)
        semPaths(myCFA.fit.three,whatLabels="std",layout="tree",edge.label.cex=0.9,rotation=2,nCharNodes=15,
                 sizeLat=7,sizeMan=7,style="lisrel")
        head(modificationindices(myCFA.fit.three)[order((modificationindices(myCFA.fit.three))$mi,decreasing=TRUE),],15)
        alpha(yl.CFA.2)
        alpha.ci(alpha.CFA)
        omega(yl.CFA.2, nfactors=3, poly=T, n.obs=497)
        
#Curvas de crecimiento latente
    #BMI
        #Declarando el modelo
            BMIfa = '#intercept
                        intercept =~ 1*zbfa.r3 + 1*zbfa.r4 + 1*zbfa.r5
                     #slope
                        slope =~ 0*zbfa.r3 + 1*zbfa.r4 + 1*zbfa.r5'
        #Model fit
            LGCbmifa = sem(BMIfa, data=yl.data, estimator="MLR")
        
            summary(LGCbmifa, fit.measures = T)
            semPaths(LGCbmifa,whatLabels="std",layout="tree",edge.label.cex=0.9,rotation=2,nCharNodes=15,
                 sizeLat=7,sizeMan=7,style="lisrel")
            head(modificationindices(LGCbmifa)[order((modificationindices(LGCbmifa))$mi,decreasing=TRUE),],15)
    #Achievement
        #Declarando el modelo
            achievement.yl = '#achievement
                        Achievement R3 ~~ math.rasch.r3 + read.rasch.r3
                        Achievement R4 ~~ percomath.r4 + percolang.r4
                        Achievement R5 ~~ percomath.r5 + percoread.r5
                      #intercept
                        intercept =~ 1*Achievement R3 + 1*Achievement R4 + 1*Achievement R5
                      #slope
                        slope =~ 0*Achievement R3 + 1*Achievement R4 + 1*Achievement R5'
        #Model fit
            LGCachievement = sem(achievement.yl, data=yl.data, estimator="MLR")
            
            summary(LGCachievement, fit.measures = T)
            semPaths(LGCachievement,whatLabels="std",layout="tree",edge.label.cex=0.9,rotation=2,nCharNodes=15,
                     sizeLat=7,sizeMan=7,style="lisrel")
            head(modificationindices(LGCachievement)[order((modificationindices(LGCachievement))$mi,decreasing=TRUE),],15)
            
