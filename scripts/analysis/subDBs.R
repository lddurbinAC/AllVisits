library(dplyr, warn.conflicts = FALSE)
library(readr, warn.conflicts = FALSE)

subDBs <- read_csv(here::here("data/raw/Subscriptions/AllVisits_SubDBs.csv"), col_types = "ccdcc", col_select = -1)


