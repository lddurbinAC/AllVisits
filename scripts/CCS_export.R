metadata <- read_excel(here::here("data/AllVisits_data_sources.xlsx"), sheet = 2, col_types = "text") %>% 
  select(1:4) %>% 
  filter(ID != "21" & ID != "22")

CCS <- readRDS(here::here("data/processed/AllVisits.rds")) %>% 
  filter(date >= ymd("2018-07-01")) %>% 
  arrange(date) %>% 
  mutate(
    FY_Q = quarter(date, with_year = TRUE, fiscal_start = 7),
    "Financial Date Hierarchy - Financial Year" = word(FY_Q, 1, sep = fixed(".")),
    "Financial Date Hierarchy - Financial Quarter" = paste0("Q", word(FY_Q, 2, sep = fixed("."))),
    "Financial Date Hierarchy - Financial Month" = month(date, label = TRUE, abbr = TRUE),
    date = format(date, "%d/%m/%Y")
    ) %>% 
  left_join(metadata, by = c("id" = "ID")) %>% 
  select(
    "Financial Date Hierarchy - Financial Year",
    "Financial Date Hierarchy - Financial Quarter",
    "Financial Date Hierarchy - Financial Month",
    "Financial Date Hierarchy - Calendar Date" = date,
    "Monthly Actuals" = metric,
    "Service Channel",
    "Service Cluster",
    "Service Name"
    )

writexl::write_xlsx(CCS, path = here::here("data/processed/CCS.xlsx"))
