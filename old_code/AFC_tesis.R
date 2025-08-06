#Paquetes
library(foreign)
library(dplyr)
library(lavaan)
library (haven)
library (semPlot)
library (semTools)
library(psych)

#Directorio de trabajo
setwd("/Users/darwin/Documents/_1. Obesidad y rendimiento académico/Análisis")

rm(list=ls())

#Cargar datos de yl
yl.data <- read.dta("childyl_plussch.dta", convert.factors=F, convert.underscore=T)
yl.exploratory <- subset(yl.data, select = c(istole, sostole, stdhitu, sohit, insulted, soinsult))

yl.exploratory <- yl.exploratory %>% na_if(99)
yl.exploratory.ready <- yl.exploratory %>%
  filter(!is.na(istole)&!is.na(sostole)&!is.na(stdhitu)&!is.na(sohit)&!is.na(insulted)&!is.na(soinsult)) 


#Analisis factorial exploratorio
nfactor.schcli <- nfactors(yl.exploratory.ready, rotate="varimax", fm="mle", cor="tet")

schcli <- fa(yl.exploratory.ready, nfactors=2, rotate = "varimax", cor="tet")
summary(schcli)

schcli <- fa(yl.exploratory.ready, nfactors=3, rotate = "varimax", cor="tet")
summary(schcli)

schcli <- fa(yl.exploratory.ready, nfactors=4, rotate = "varimax", cor="tet")
summary(schcli)

schcli <- fa(yl.exploratory.ready, nfactors=5, rotate = "varimax", cor="tet")
summary(schcli)

schcli <- fa(yl.exploratory.ready, nfactors=6, rotate = "varimax", cor="tet")
summary(schcli)
