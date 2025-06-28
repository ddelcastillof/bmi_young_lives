# ---
# Cleaning script for the datasets
# Author: Darwin Del Castillo
# Date: `r Sys.Date()`
# ---

# Load necessary libraries
pacman::p_load(
  dplyr,
  tidyr,
  stringr,
  lubridate,
  readr,
  skimr,
  janitor
)

# Set directories for data
r1_oc <- "data_raw/r1_files/tab/r1_oc/"
r2_oc <- "data_raw/r2_files/tab/r2_oc/"
r3_oc <- "data_raw/r3_files/tab/r3_oc/"

r3_yc <- "data_raw/r3_files/tab/r3_yc/"
r4_yc <- "data_raw/r4_files/tab/r4_yc/"
r5_yc <- "data_raw/r5_files/tab/r5_yc/"

# Reading data from round 1
## Individual level data for children from the older cohort
r1_oc_pe <- read_tsv(file = paste0(r1_oc, "peru/pechildlevel8yrold.tab"),
                     col_names = TRUE,
                     col_types = cols(.default = "?"))

r1_oc_vn <- read_tsv(file = paste0(r1_oc, "vietnam/vnchildlevel8yrold.tab"),
                     col_names = TRUE,
                     col_types = cols(.default = "?"))

r1_oc_in <- read_tsv(file = paste0(r1_oc, "india/inchildlevel8yrold.tab"),
                     col_names = TRUE,
                     col_types = cols(.default = "?"))

## Individual level data for children from the younger cohort
r3_yc_pe <- read_tsv(file = paste0(r3_yc, "peru/pe_yc_childlevel.tab"),
                     col_names = TRUE,
                     col_types = cols(.default = "?"))

r3_yc_vn <- read_tsv(file = paste0(r3_yc, "vietnam/vn_yc_childlevel.tab"),
                     col_names = TRUE,
                     col_types = cols(.default = "?"))

r3_yc_in <- read_tsv(file = paste0(r3_yc, "india/in_yc_childlevel.tab"),
                     col_names = TRUE,
                     col_types = cols(.default = "?"))
