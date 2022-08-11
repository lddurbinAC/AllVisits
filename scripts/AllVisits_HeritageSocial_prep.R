HeritageSocialPrep <- function(x) {
  x %>% read_excel() %>%
    remove_empty(which = c("rows", "cols")) %>% 
    select(metric_name = 1, everything(), -length(.)) %>% 
    mutate(across(!metric_name, ~str_replace(.x, ",", ""))) %>% 
    mutate(across(!metric_name, as.double)) %>% 
    pivot_longer(-1, names_to = "date", names_transform = list(date = as.integer), values_to = "Metric") %>% 
    mutate(Month = format(excel_numeric_to_date(date), "%b"), Year = format(excel_numeric_to_date(date), "%Y")) %>% 
    filter(str_detect(metric_name, "Facebook engagement")) %>% 
    select(Month, Year, Metric)
}

# Load the FY19 regional social data file
HeritageSocial_historic <- list.files("data/raw/HistoricHeritageSocial", full.names = TRUE) %>%
  read_excel(col_type = c("text", "text", "numeric"))

# Load and clean all post-FY19 regional social data files
HeritageSocial_recent <- lapply(list.files(c("data/raw/HeritageSocial2020", "data/raw/HeritageSocial2021"), full.names = TRUE), HeritageSocialPrep) %>% bind_rows()

# Combine the FY19 and post-FY19 data
bind_rows(HeritageSocial_recent, HeritageSocial_historic) %>% 
  mutate(id = 5) %>% 
  saveRDS(here::here("data/rds/HeritageSocial.rds"))
