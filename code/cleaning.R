# ---
# Cleaning script for the datasets
# Author: Darwin Del Castillo
# Date: `r Sys.Date()`
# ---

# Load necessary libraries
pacman::p_load(
  tidyverse,
  data.table,
  skimr,
  janitor
)

# Set directories for data
r1_oc <- "data_raw/r1_files/tab/r1_oc/" #2002
r2_oc <- "data_raw/r2_files/tab/r2_oc/" #2006
r3_oc <- "data_raw/r3_files/tab/r3_oc/" #2009

r3_yc <- "data_raw/r3_files/tab/r3_yc/" #2009
r4_yc <- "data_raw/r4_files/tab/r4_yc/" #2013
r5_yc <- "data_raw/r5_files/tab/r5_yc/" #2016

# Reading data from round 1
## Individual level data for children from the older cohort
r1_oc_pe <- fread(file = paste0(r1_oc, "peru/pechildlevel8yrold.tab"))

r1_oc_vn <- fread(file = paste0(r1_oc, "vietnam/vnchildlevel8yrold.tab"))

r1_oc_in <- fread(file = paste0(r1_oc, "india/inchildlevel8yrold.tab"))

## Individual level data for children from the younger cohort
r3_yc_pe <- fread(file = paste0(r3_yc, "peru/pe_yc_childlevel.tab"))

r3_yc_vn <- fread(file = paste0(r3_yc, "vietnam/vn_yc_childlevel.tab"))

r3_yc_in <- fread(file = paste0(r3_yc, "india/in_yc_childlevel.tab"))
