# Clean and summarise the Solus app data
Solus_prep <- function(spreadsheet) {
  read_excel(spreadsheet, range = cell_cols("A:C"), col_names = FALSE, sheet = 2) %>% 
    filter(row_number() >= which(...1 == "Usage over time")) %>% 
    row_to_names(1) %>% 
    clean_names() %>% 
    filter(str_detect(usage_over_time, "[:digit:]")) %>% 
    mutate(date = excel_numeric_to_date(as.double(usage_over_time)), .keep = "unused") %>% 
    filter(date > ymd("2021-06-30")) %>% 
    mutate(Month = format(date, "%b"), Year = format(date, "%Y"), Metric = as.double(launches), .keep = "unused") %>% 
    select(-devices)
}
  
lapply(list.files("data/raw/Solus", full.names = TRUE), Solus_prep) %>% 
  bind_rows() %>% 
  mutate(id = 20) %>% 
  saveRDS(here::here("data/rds/Solus.rds"))
