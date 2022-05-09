# Prepare Archives and Records data
AandR_prep <- function(x, id) {
  read_excel(list.files(x, full.names = TRUE, pattern="*.xlsx")) %>% 
    select(-c(Metric_source, Metric_type, Data_source)) %>% 
    mutate(across(c(1:2), as.character), id := {{id}})
}

# Get Records and Archives email enquiries and website sessions
AandR_prep(here::here("data/raw/AandR_enquiries"), id = 1) %>% saveRDS(here::here("data/rds/AandR_enquiries.rds"))
