# Filter DX data by service and remove extraneous columns
service_assignment <- function(service, id, path) {
  DX %>% filter(Metric_source == service) %>% 
    select(-c(3:4)) %>% 
    mutate(id := {{id}}) %>% 
    saveRDS(here::here({{path}}))
}

# Get the DX data
DX <- read_csv(list.files("data/raw/DX", pattern = "*.csv", full.names = TRUE), col_names = T, col_types = "ccccd")

# Assign each service to its relevant RDS file
service_assignment("Community Libraries' outreach", id = 4, path = "data/rds/community_outreach.rds")
service_assignment("Mobile and Access outreach", id = 10, path = "data/rds/mobile_outreach.rds")
service_assignment("Research and Heritage outreach", id = 18, path = "data/rds/research_outreach.rds")
