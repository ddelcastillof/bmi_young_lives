#Paquetes
library(foreign)
library(dplyr)
library(haven)
library(panelr)
library(geepack)
library(sjPlot)
library(ggplot2)
library(cowplot)
library(survey)


#Directorio de trabajo
setwd("/Users/darwin/Documents/_1. Obesidad y rendimiento académico/Análisis")
rm(list=ls())

#Cargar datos de yl
yl.data <- read.dta("yl_final.dta", convert.factor=F, convert.underscore=T)

#Eliminar registros con missing data y limpieza final
yl.ready <- yl.data %>%
  filter(!is.na(zbfa.r3)&!is.na(zbfa.r4)&!is.na(zbfa.r5)) %>%
  filter(!is.na(zhfa.r3)&!is.na(zhfa.r4)&!is.na(zhfa.r5)) %>%
  filter(!is.na(bmiclass.r3)&!is.na(bmiclass.r4)&!is.na(bmiclass.r5)) %>%
  filter(!is.na(math.rasch.r4)&!is.na(read.rasch.r4)) %>%
  filter(!is.na(math.rasch.r5)&!is.na(read.rasch.r5)) %>%
  filter(!is.na(wi.r3)&!is.na(wi.r4)&!is.na(wi.r5)) %>%
  filter(!is.na(absent.r3)&!is.na(absent.r4)&!is.na(absent.r5)) %>%
  filter(!is.na(sleep.r3)&!is.na(sleep.r4)&!is.na(sleep.r5)) %>%
  filter(!is.na(childsex)) %>%
  filter(!is.na(absent.r3)&!is.na(absent.r4)&!is.na(absent.r5))

  yl.ready$absent.r3 <- factor(yl.ready$absent.r3, levels=c("0","1"), labels=c("No", "Yes"))
  yl.ready$absent.r4 <- factor(yl.ready$absent.r4, levels=c("0","1"), labels=c("No", "Yes"))
  yl.ready$absent.r5 <- factor(yl.ready$absent.r5, levels=c("0","1"), labels=c("No", "Yes"))
  yl.ready$childsex <- factor(yl.ready$childsex, levels = c("0","1"), labels = c("Female", "Male"))
  yl.ready$typesite.r3 <- factor(yl.ready$typesite.r3, levels = c("1","2"), labels = c("Urban", "Rural"))
  yl.ready$typesite.r5 <- factor(yl.ready$typesite.r5, levels = c("1","2"), labels = c("Urban", "Rural"))
  yl.ready$bmiclass.r3 <- factor(yl.ready$bmiclass.r3, levels=c("0","1","2"), labels=c("Normal Weight", "Overweight", "Obesity"))
  yl.ready$bmiclass.r4 <- factor(yl.ready$bmiclass.r4, levels=c("0","1","2"), labels=c("Normal Weight", "Overweight", "Obesity"))
  yl.ready$bmiclass.r5 <- factor(yl.ready$bmiclass.r5, levels=c("0","1","2"), labels=c("Normal Weight", "Overweight", "Obesity"))
  yl.ready$wi.tertiles.r3 <- factor(yl.ready$wi.tertiles.r3, levels=c("1","2","3"), labels=c("Low", "Middle", "High"))
  yl.ready$wi.tertiles.r4 <- factor(yl.ready$wi.tertiles.r4, levels=c("1","2","3"), labels=c("Low", "Middle", "High"))
  yl.ready$wi.tertiles.r5 <- factor(yl.ready$wi.tertiles.r5, levels=c("1","2","3"), labels=c("Low", "Middle", "High"))
  yl.ready$stunting.r3 <- factor(yl.ready$stunting.r3, levels=c("0","1"), labels=c("No", "Yes"))
  yl.ready$stunting.r4 <- factor(yl.ready$stunting.r4, levels=c("0","1"), labels=c("No", "Yes"))
  yl.ready$stunting.r5 <- factor(yl.ready$stunting.r5, levels=c("0","1"), labels=c("No", "Yes"))
  yl.ready$sleep.cat.r3 <- factor(yl.ready$sleep.cat.r3, levels=c("0","1"), labels=c("Insufficient", "Sufficient"))
  yl.ready$sleep.cat.r4 <- factor(yl.ready$sleep.cat.r4, levels=c("0","1"), labels=c("Insufficient", "Sufficient"))
  yl.ready$sleep.cat.r5 <- factor(yl.ready$sleep.cat.r5, levels=c("0","1"), labels=c("Insufficient", "Sufficient"))
  yl.ready$clustid <- factor(yl.ready$clustid, levels = c(1:20))
  yl.ready$childcode <- factor(yl.ready$childid)
  
  yl.ready <- yl.ready %>% 
  filter(!is.na(age.r3)&!is.na(age.r4)&!is.na(age.r5))
  
  yl.ready <- yl.ready %>%
    filter(!is.na(wi.tertiles.r3))%>%
    filter(!is.na(wi.tertiles.r4))%>%
    filter(!is.na(wi.tertiles.r5))

yl.ready.long <- long_panel(yl.ready, 
                 prefix=".r",
                 begin=3,
                 end=5,
                 label_location = "end")

#Graficos descriptivos: variables que varian en el tiempo
ggplot(data=yl.ready.long, aes(x=as.factor(wave), y=zbfa, group=childid, color=childsex)) + 
  geom_line() + geom_point() +
  ggtitle("Changes on z-BMI over time", subtitle = "Young lives study rounds 3,4 and 5") +
  labs(x="Rounds", y="z-BMI for age") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +
  scale_color_discrete(name="Sexo")
ggplot(data=yl.ready.long, aes(x=as.factor(wave), y=math.rasch, group=childid, color=childsex)) +
  geom_line() + geom_point() +
  ggtitle("Changes on math scores over time", subtitle = "Young lives study rounds 3,4 and 5") +
  labs(x="Rounds", y="Math test rasch scores") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +
  scale_color_discrete(name="Sex")
ggplot(data=yl.ready.long, aes(x=as.factor(wave), y=read.rasch, group=childid)) + 
  geom_line() + geom_point() + 
  ggtitle("Changes on reading scores over time", subtitle = "Young lives study rounds 3,4 and 5") +
  labs(x="Rounds", y="Reading test rasch scores") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +
  scale_color_discrete(name="Sex")
ggplot(data=yl.ready.long, aes(x=as.factor(wave), y=zhfa, group=childid,  color=childsex)) + 
  geom_line() + geom_point() +
  ggtitle("Changes on z-height for age over time", subtitle = "Young lives study rounds 3,4 and 5") +
  labs(x="Rounds", y="z-height for age") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +
  scale_color_discrete(name="Sex")
ggplot(data=yl.ready.long, aes(x=as.factor(wave), y=wi.tertiles, group=childid,  color=childsex)) + 
  geom_line() + geom_point() +
  ggtitle("Changes on wealth index tertiles over time", subtitle = "Young lives study rounds 3,4 and 5") +
  labs(x="Rounds", y="Wealth index tertiles") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +
  scale_color_discrete(name="Sex")

#Seteo de diseño de muestra
yl_sampling_design <- svydesign(data=yl.ready.long,
                                probs=~clustfactor,
                                strata=NULL,
                                id=~clustid)

#Funcion de ajuste del modelo
fitflm <- function(x){
  geeglm(x, id=childcode, data = as.data.frame(yl.ready.long), 
      family = poisson(link="log"),
      corstr="exchangeable",
      waves=wave,
      weights=clustfactor)
}

#Modelos crudos
fitflm(math.rasch ~ bmiclass) -> gee.math
fitflm(read.rasch ~ bmiclass) -> gee.read

#Modelos ajustados
#Efecto total sin absentismo
fitflm(math.rasch ~ bmiclass + 
         age +
         sleep.cat + 
         wi.tertiles + 
         childsex +
         stunting) -> gee.math.full

fitflm(read.rasch ~ bmiclass +
         age +
         sleep.cat + 
         wi.tertiles +
         childsex +
         stunting) -> gee.read.full

#Modelo con mediación
#Efecto con absentismo escolar
fitflm(math.rasch ~ bmiclass + 
         age +
         sleep.cat + 
         wi.tertiles + 
         childsex +
         stunting +
         absent) -> gee.math.mediation

fitflm(read.rasch ~ bmiclass +
         age +
         sleep.cat + 
         wi.tertiles +
         childsex +
         stunting +
         absent) -> gee.read.mediation


#Tablas 
tab_model(gee.math, gee.math.full, gee.math.mediation,
          file = "output/regtable_math.html", 
          show.intercept=F,
          show.obs = F,
          show.ngroups = F,
          show.reflvl = T,
          collapse.ci=T,
          dv.labels = c("Modelo crudo", "Modelo ajustado", "Modelo mediado por absentismo"),
          pred.labels = c("Clasificacion IMC (Sobrepeso)", "Clasificacion IMC (Obesidad)",
                          "Edad", "Horas de sueno (Suficientes)", "Terciles de riqueza (Medio)",
                          "Terciles de riqueza (Alto)", "Sexo (Masculino)", "Desnutricion cronica", "Absentismo (Si)"),
          title="Tabla 3.3. Analisis multivariado longitudinal de la asociacion entre obesidad y rendimiento academico en matematicas",
          string.p="p-valor",
          string.ci="Intervalo de confianza",
          string.est="RR",
          string.pred = "Variables")

tab_model(gee.read, gee.read.full, gee.read.mediation,
          file = "output/regtable_read.html",
          show.intercept=F,
          show.obs = F,
          show.ngroups = F,
          show.reflvl = T,
          collapse.ci=T,
          dv.labels = c("Modelo crudo", "Modelo ajustado", "Modelo mediado por absentismo"),
          pred.labels = c("Clasificacion IMC (Sobrepeso)", "Clasificacion IMC (Obesidad)",
                          "Edad", "Horas de sueno (Suficientes)", "Terciles de riqueza (Medio)",
                          "Terciles de riqueza (Alto)", "Sexo (Masculino)", "Desnutricion cronica", "Absentismo (Si)"),
          title="Tabla 3.4. Analisis multivariado longitudinal de la asociacion entre obesidad y rendimiento academico en lectura",
          string.p="p-valor",
          string.ci="Intervalo de confianza",
          string.est="RR",
          string.pred = "Variables")

#Efectos marginales
plot_grid((plot_model(gee.math, type = "pred", terms = "bmiclass") + ggtitle("Modelo matematicas crudo") + theme(plot.title = element_text(hjust = 0.5))),
          (plot_model(gee.math.full, type = "pred", terms = "bmiclass") + ggtitle("Modelo matematicas ajustado") + theme(plot.title = element_text(hjust = 0.5))),
          (plot_model(gee.math.mediation, type = "pred", terms = "bmiclass") + ggtitle("Modelo matematicas ajustado + mediacion") + theme(plot.title = element_text(hjust = 0.5))),
          (plot_model(gee.read, type = "pred", terms = "bmiclass") + ggtitle("Modelo lectura crudo") + theme(plot.title = element_text(hjust = 0.5))),
          (plot_model(gee.read.full, type = "pred", terms = "bmiclass") + ggtitle("Modelo lectura ajustado") + theme(plot.title = element_text(hjust = 0.5))),
          (plot_model(gee.read.mediation, type = "pred", terms = "bmiclass") + ggtitle("Modelo lectura ajustado + mediacion") + theme(plot.title = element_text(hjust = 0.5))),nrow = 2, ncol=3) %>%
  ggsave("output/marginplot.png", ., width = 16, height = 12, dpi = 120)

#Grafico de coeficientes
coef.names <- c("Clasificacion IMC (Sobrepeso)", "Clasificacion IMC (Obesidad)",
                "Edad", "Horas de sueno (Suficientes)", "Terciles de riqueza (Medio)",
                "Terciles de riqueza (Alto)", "Sexo (Masculino)", "Desnutricion cronica", "Absentismo (Si)")
(plot_models(gee.math, gee.math.full, gee.math.mediation, show.values = T, show.p = F, axis.labels = coef.names) +
    scale_color_discrete(name = "Modelo", labels = c("Ajustado + mediacion", "Ajustado", "Crudo")) +
    ggtitle("Grafico de coeficientes de modelos GEE para rendimiento en matematicas", subtitle = "Estudio Niños del Milenio, rondas 3, 4 y 5") +
    ylab("Riesgo relativo") +
    theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))) %>%
  ggsave("output/coefplot_math.png", ., width = 8, height = 7, dpi = 120)

(plot_models(gee.read, gee.read.full, gee.read.mediation, show.values = T, show.p = F, axis.labels = coef.names) +
    scale_color_discrete(name = "Modelo", labels = c("Ajustado + mediacion", "Ajustado", "Crudo")) +
    ggtitle("Grafico de coeficientes de modelos GEE para rendimiento en lectura", subtitle = "Estudio Niños del Milenio, rondas 3, 4 y 5") +
    ylab("Riesgo relativo") +
    theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))) %>%
  ggsave("output/coefplot_read.png", ., width = 8, height = 7, dpi = 120)

##Estratificación por sexo
yl.ready.long <- subset(yl.ready.long, childsex=="Female")

fitflm <- function(x){
  geeglm(x, id=childcode, data = yl.ready.long, 
         family = poisson(link="log"),
         corstr="exchangeable",
         waves=wave,
         weights=clustfactor)
}

#Modelos crudos y ajustados hombres
yl.ready.long <- subset(yl.ready.long, childsex=="Male")

fitflm(math.rasch ~ bmiclass + 
         sleep.cat + 
         age + 
         wi.tertiles +
         stunting) -> gee.math.full.male
fitflm(read.rasch ~ bmiclass + 
         sleep.cat + 
         age + 
         wi.tertiles +
         stunting) -> gee.read.full.male

yl.ready.long <- long_panel(yl.ready, 
                            prefix=".r",
                            begin=3,
                            end=5,
                            label_location = "end")

#Modelos crudos y ajustados mujeres
yl.ready.long <- subset(yl.ready.long, childsex=="Female")
fitflm(math.rasch ~ bmiclass + 
         sleep.cat + 
         age + 
         wi.tertiles +
         stunting) -> gee.math.full.female

fitflm(read.rasch ~ bmiclass + 
         sleep.cat + 
         age + 
         wi.tertiles + 
         stunting) -> gee.read.full.female

tab_model(gee.math.full.male, gee.math.full.female, file = "output/regtable_math_sex.html",
          show.intercept=F)
tab_model(gee.read.full.male, gee.read.full.female, file="output/regtable_read_sex.html",
          show.intercept=F)

yl.ready.long <- long_panel(yl.ready, 
                            prefix=".r",
                            begin=3,
                            end=5,
                            label_location = "end")
