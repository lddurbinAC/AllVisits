# Load libraries
library(dplyr, warn.conflicts = FALSE) # A Grammar of Data Manipulation
library(readr) # Read Rectangular Text Data 
library(stringr) # Simple, Consistent Wrappers for Common String Operations 
library(tidyr) # Tidy Messy Data 
library(purrr) # Functional Programming Tools
library(readxl, warn.conflicts = FALSE) # Read Excel Files
library(janitor, warn.conflicts = FALSE) # Simple Tools for Examining and Cleaning Dirty Data
library(lubridate, warn.conflicts = FALSE) # Make Dealing with Dates a Little Easier

# Prep all data files and save output to RDS
data_prep_scripts <- list.files(here::here("scripts/"), pattern = "^AllVisits", full.names = TRUE)
walk(data_prep_scripts, source)

# Create one data frame for everything, add date, replace NAs with 0, filter out current month
AllVisits <- lapply(list.files(here::here("data/rds"), full.names = TRUE), readRDS) %>% 
  bind_rows() %>% 
  mutate(date = as.Date(paste(Month, "01", Year, sep="/"), format="%b/%d/%Y"), id = as.character(id)) %>% 
  select(-Month, -Year, metric = Metric) %>% 
  complete(fill = list(Metric = 0)) %>% 
  filter(date != as.Date(format(Sys.Date(), paste("%Y-%m", "01", sep="-"))))

# Change infinite values to zero
AllVisits[AllVisits == Inf] <- 0

# Save combined data to RDS
AllVisits %>% saveRDS(here::here("data/processed/AllVisits.rds"))

# Export combined data to CSV and Excel
source(here::here("scripts/exports.R"))
