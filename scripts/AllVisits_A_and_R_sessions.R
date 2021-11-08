library(googlesheets4, warn.conflicts = FALSE)

gs4_deauth()

google_sheet_url <- read_excel(here::here("data/AllVisits_data_sources.xlsx"), sheet = "Metadata") %>% 
  clean_names() %>% 
  filter(service_name == "Records & Archives website") %>% 
  pull(data_source)

read_sheet(
  google_sheet_url,
  range = "B2:H"
) %>%
  clean_names() %>%
  select(month, starts_with("sessions")) %>%
  mutate(Year = year(month), Month = month(month, label = TRUE), across(c(Year, Month), as.character), .keep = "unused") %>%
  rowwise() %>%
  mutate(Metric = sum(across(starts_with("sessions")), na.rm = TRUE), id = 2, .keep = "unused") %>%
  ungroup() %>% 
  saveRDS(here::here("data/rds/AandR_sessions.rds"))
