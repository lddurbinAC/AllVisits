#Archive the old data output and export the new data frame to a .csv file
file.rename(here::here("data/processed/AllVisits.csv"), paste(here::here("data/processed/archived/AllVisits_"), as.Date(file.info(here::here("data/processed/AllVisits.csv"))$ctime), ".csv", sep=""))

readRDS(here::here("data/processed/AllVisits.rds")) %>%
  write.csv(here::here("data/processed/AllVisits.csv"), na="")

source(here::here("scripts/CCS_export.R"))