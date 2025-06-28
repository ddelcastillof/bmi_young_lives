# ---
# Appendix to the article 
# Author: Darwin Del Castillo
# Date: `r Sys.Date()`
# ---

# Load necessary libraries
library(dagitty)
library(ggdag)
library(ggplot2)

# Define the DAG for the study
# This DAG represents the relationships between variables in the study
# Variables:
# - academic_achievement: Outcome variable
# - bmi_trayectories: Exposure variable
# - food_insecurity: Adjusted variable
# - scholar_abseentism: Unadjusted variable
# - self_perceived_health: Adjusted variable
# - ses: Socioeconomic status

dag <- dagitty('dag {
academic_achievement [outcome,pos="0.209,0.668"]
bmi_trayectories [exposure,pos="-1.495,0.732"]
food_insecurity [adjusted,pos="-0.925,0.443"]
scholar_abseentism [pos="-0.528,-0.126"]
self_perceived_health [adjusted,pos="-1.251,-0.567"]
ses [pos="-1.017,-0.002"]
sex [adjusted,pos="-0.473,1.044"]
bmi_trayectories -> academic_achievement
food_insecurity -> academic_achievement
food_insecurity -> bmi_trayectories
food_insecurity -> scholar_abseentism
scholar_abseentism -> academic_achievement
self_perceived_health -> bmi_trayectories
self_perceived_health -> scholar_abseentism
ses -> academic_achievement
ses -> food_insecurity
ses -> scholar_abseentism
sex -> academic_achievement
sex -> bmi_trayectories
}')

# Plot the DAG using ggdag with custom pastel colours
ggdag_status(dag,
      text_size = 3.8,
      node_size = 14,
      label_size = 4.5) +
  geom_dag_text(color = "black",
    size = 4.5) +
  scale_color_manual(
    values = c(
      exposure = "#B7E4C7",
      outcome  = "#F7C6C7",
      adjusted = "#75a0f5"
    ),
    breaks = c("exposure", NA, "outcome"),
    labels = c("exposure", "covariates", "outcome"),
    na.value = "#75a0f5"
  ) +
  theme_dag_grid() +
  theme(
    plot.title    = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    plot.caption  = element_text(hjust = 1, size = 10, face = "italic"),
    plot.margin   = margin(20, 20, 20, 20)
  ) +
  ggtitle(
    "Directed Acyclic Graph (DAG) for the Study",
    subtitle = "Relationships between BMI trajectories and academic achievement"
  )

# Save the plot
ggsave("output/figures/dag_study.jpg", width = 15, height = 10, dpi = 600)