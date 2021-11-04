# Prepare Archives and Records data
AandR_prep <- function(x, id) {
  read_excel(list.files(x, full.names = TRUE, pattern="*.xlsx")) %>% 
    select(-c(Metric_source, Metric_type, Data_source)) %>% 
    mutate(across(c(1:2), as.character), id := {{id}})
}

# Get Records and Archives email enquiries and website sessions
AandR_prep(here::here("data/raw/AandR_enquiries"), id = 1) %>% saveRDS(here::here("data/rds/AandR_enquiries.rds"))
AandR_prep(here::here("data/raw/AandR_sessions"), id = 2) %>% saveRDS(here::here("data/rds/AandR_sessions.rds"))

# library(googlesheets4, warn.conflicts = FALSE)
# 
# gs4_deauth()
# 
# read_sheet(
#   "https://docs.google.com/spreadsheets/d/1NFj65L8iCrCQJg0ABJq-onsm9Wb0IZR_WqbF84pN5jk/edit#gid=697526476",
#   range = "B2:H"
#   ) %>% 
#   clean_names() %>% 
#   select(month, starts_with("sessions")) %>% 
#   mutate(
#     year = year(month),
#     month = month(month, label = TRUE)
#     ) %>% 
#   rowwise() %>% 
#   mutate(metric = sum(across(starts_with("sessions")), na.rm = TRUE), .keep = "unused") %>% 
#   ungroup()
