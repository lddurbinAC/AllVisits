# Prepare Google Analytics data
wrangle_data <- function(x, id, path) {
  sapply(list.files(paste0("data/raw/", x), full.names = TRUE), read_excel, sheet=2, simplify=FALSE) %>%
    bind_rows() %>% 
    clean_names() %>% 
    mutate(Month = format(day_index, "%b"), Year = format(day_index, "%Y")) %>% 
    filter(!is.na(day_index)) %>% 
    group_by_if(is.character) %>% 
    summarise(Metric = sum(sessions), .groups = "drop") %>% 
    mutate(id := {{id}}) %>% 
    saveRDS(here::here({{path}}))
}

# Load and clean the Kura data
wrangle_data("Kura", id = 7, path = "data/rds/Kura.rds")

# Load and clean the Heritage Images data
wrangle_data("HeritageImages", id = 6, path = "data/rds/HeritageImages.rds")

# Load and clean the Manuscripts Online data
wrangle_data("Manuscripts", id = 9, path = "data/rds/ManuscriptsOnline.rds")
