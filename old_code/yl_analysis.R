# Librerias
library(haven)
library(dplyr)
library(ggplot2)
library(sjPlot)
library(cowplot)

# Funciones para transformar datos
educ_collapse <- function(x){
  case_when(x <= 3 ~ 1,
            x == 4 ~ 2,
            x >= 5 & x != 9 ~ 3)
}

fitflm <- function(x){
  lm(x, data = yl_ready)
}

# Cargar datos
yl <- read_dta("data/childyl_plussch.dta")

# Transformar datos
  # Eliminar registros con missing data
yl_ready <- yl %>%
  filter(!is.na(zbfa_r4)&!is.na(zbfa_r3)&!is.na(percoppvt_r4)) %>%
  mutate(zbch_34 = zbfa_r4 - zbfa_r3,
         mathscore_r4 = percomath_r4/100,
         max_peduc = pmax(educ_collapse(mum_educ_r3), educ_collapse(dad_educ_r3), 
                          educ_collapse(stepmum_educ_r3), educ_collapse(stepdad_educ_r3), 
                          educ_collapse(adopmum_educ_r3), educ_collapse(adopdad_educ_r3), 
                          na.rm = T)) %>%
  mutate(max_peduc = factor(max_peduc,
                            labels = c("Didn't complete secondary ed",
                                       "Complete secondary ed",
                                       "At least some higher ed")))

# Modelos
  # Asociacion marginal
fitflm(mathscore_r4 ~ poly(zbfa_r4, 2)) -> reg_marginal

  # Modelo pre-especificado via DAG
    # Efecto total - no incluye bullying
fitflm(mathscore_r4 ~ poly(zbfa_r4, 2) +
      # IQ: PPVT como proxy
      poly(percoppvt_r4, 2) +
      # Salud: sleep, ausencias, altura para edad (corto, mediano, largo plazo)
      poly(zbfa_r3, 2) + poly(sleep_r4, 2) + zhfa_r4 + absent_r4 +
      # Entorno: educacion padres (tomar el maximo de ambos)
      max_peduc) -> reg_full

    # Efecto directo - bullying retira posible mediacion
fitflm(mathscore_r4 ~ poly(zbfa_r4, 2) +
      # Mediacion por bullying
      sohit + somupset + fight + gdfrds +
      # IQ: PPVT como proxy
      poly(percoppvt_r4, 2) +
      # Salud: sleep, ausencias, altura para edad (corto, mediano, largo plazo)
      poly(zbfa_r3, 2) + poly(sleep_r4, 2) + zhfa_r4 + absent_r4 +
      # Entorno: educacion padres (tomar el maximo de ambos)
      max_peduc) -> reg_mediacion

# Resultados
  # Tabla de coeficientes
tab_model(reg_marginal, reg_full, reg_mediacion, file = "output/regtable.html")
  # Grafica de coeficientes
(plot_models(reg_marginal, reg_full, reg_mediacion) +
  scale_color_discrete(name = "Modelo", labels = c("Ajustado + mediacion", "Ajustado", "Crudo"))) %>%
  ggsave("output/coefplot.png", ., width = 8, height = 7, dpi = 120)
  # Efectos marginales
plot_grid((plot_model(reg_marginal, type = "pred", terms = "zbfa_r4") + ggtitle("Modelo crudo")),
          (plot_model(reg_full, type = "pred", terms = "zbfa_r4") + ggtitle("Modelo ajustado")),
          (plot_model(reg_mediacion, type = "pred", terms = "zbfa_r4") + ggtitle("Modelo ajustado + mediacion")), nrow = 3) %>%
  ggsave("output/marginplot.png", ., width = 6, height = 8, dpi = 120)