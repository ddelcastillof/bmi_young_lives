#Paquetes
library(foreign)
library(dplyr)
library(haven)
library(survey)
library(ggplot2)
library(sjPlot)
library(cowplot)
library(splines)
library(mgcv)

#Directorio de trabajo
setwd("/Users/darwin/Documents/_1. Obesidad y rendimiento académico/Análisis")
rm(list=ls())

#Cargar datos de yl
yl.data <- read.dta("yl_final.dta", convert.factor=F, convert.underscore=T)

#Eliminar registros con missing data
yl.ready <- yl.data %>%
  filter(!is.na(zbfa.r4)&!is.na(zbfa.r3)&!is.na(zbfa.r5)) %>%
  mutate(math.rasch.r4 = percomath.r4,
         read.rasch.r4 = percolang.r4) %>%
  filter(!is.na(math.rasch.r4)&!is.na(read.rasch.r4)) %>%
  filter(!is.na(wi.r3)&!is.na(wi.r4)) %>%
  filter(!is.na(absent.r3)&!is.na(absent.r4)) %>%
  filter(!is.na(sleep.r3)&!is.na(sleep.r4)) %>%
  filter(!is.na(childsex))

#Graficos descriptivos
plot(math.rasch.r4 ~ zbfa.r3, yl.ready ,main="zBMI for age R3 vs Math in R4")
plot(read.rasch.r4 ~ zbfa.r3, yl.ready ,main="zBMI for age R3 vs Reading in R4")

#Declarando diseño de encuesta
yl.design <- svydesign(ids=~clustid, weights=~clustfactor, nest=T, data=yl.ready)

#Funcion de ajuste del modelo
fitflm <- function(x){
  gam(x, data = yl.ready)
}
#Modelos crudos marginales
fitflm(math.rasch.r4 ~ s(zbfa.r3)) -> reg.marginal.math
fitflm(read.rasch.r4 ~ s(zbfa.r3)) -> reg.marginal.read


#Modelos ajustados marginales
  #Efecto total sin bullying ni absentismo
  fitflm(math.rasch.r4 ~ s(zbfa.r3) + math.rasch.r3 + 
           sleep.r3 + s(zbfa.r4) + wi.r3 + 
           wi.r4 + sleep.r4 + zhfa.r4 + childsex) -> reg.marginal.math.full
  
  fitflm(read.rasch.r4 ~ s(zbfa.r3) + read.rasch.r3 + 
           sleep.r3 + s(zbfa.r4) + wi.r3 + 
           wi.r4 + sleep.r4 + zhfa.r4 + childsex) -> reg.marginal.read.full
  
  #Efecto total con mediacion por clima escolar
  fitflm(math.rasch.r4 ~ s(zbfa.r3) + math.rasch.r3 + 
           sleep.r3 + s(zbfa.r4) + wi.r3 + 
           wi.r4 + sleep.r4 + zhfa.r4 +
           sohit + stdhitu + sostole + istole + insulted + soinsult + childsex) -> reg.marginal.math.mediated
  
  fitflm(read.rasch.r4 ~ s(zbfa.r3) + read.rasch.r3 + 
           sleep.r3 + s(zbfa.r4) + wi.r3 + 
           wi.r4 + sleep.r4 + zhfa.r4 +
           sohit + stdhitu + sostole + istole + insulted + soinsult + childsex) -> reg.marginal.read.mediated
  
  
(plot_models(reg.marginal.math, reg.marginal.read, reg.marginal.math.full, reg.marginal.read.full, reg.marginal.math.mediated, reg.marginal.read.mediated) +
    scale_color_discrete(name = "Modelo", labels = c("Modelo crudo matematica",
                                                     "Modelo crudo lectura",
                                                     "Modelo ajustado matematica",
                                                     "Modelo ajustado lectura",
                                                     "Modelo ajustado matematica + bullying",
                                                     "Modelo ajustado lectura + bullying"))) %>%
    ggsave("output/coefplot.png", ., width = 8, height = 7, dpi = 120)
# Efectos marginales
plot_grid((plot_model(reg.marginal.math, type = "pred", terms = "zbfa.r3", axis.title=c("z-IMC para la edad", "Rendimiento en matematica")) + ggtitle("Modelo crudo matematica")),
          (plot_model(reg.marginal.math.full, type = "pred", terms = "zbfa.r3", axis.title=c("z-IMC para la edad", "Rendimiento en matematica")) + ggtitle("Modelo ajustado matematica")),
          (plot_model(reg.marginal.math.mediated, type = "pred", terms = "zbfa.r3", axis.title=c("z-IMC para la edad", "Rendimiento en matematica")) + ggtitle("Modelo ajustado matematica+clima escolar")),
          (plot_model(reg.marginal.read, type = "pred", terms = "zbfa.r3", axis.title=c("z-IMC para la edad", "Rendimiento en lectura")) + ggtitle("Modelo crudo lectura")),
          (plot_model(reg.marginal.read.full, type = "pred", terms = "zbfa.r3", axis.title=c("z-IMC para la edad", "Rendimiento en lectura")) + ggtitle("Modelo ajustado lectura")),
          (plot_model(reg.marginal.read.mediated, type = "pred", terms = "zbfa.r3", axis.title=c("z-IMC para la edad", "Rendimiento en lectura")) + ggtitle("Modelo ajustado lectura+clima escolar")),
           nrow = 2, ncol = 3) %>%
          ggsave("output/marginplot.png", ., width = 16, height = 12, dpi = 120)

#Tablas 
tab_model(reg.marginal.math, reg.marginal.math.full, reg.marginal.math.mediated,
          reg.marginal.read, reg.marginal.read.full, reg.marginal.read.mediated, file = "output/regtable.html")
