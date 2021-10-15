old_system_data <- list.files("data/raw/LibraryConnect", full.names = TRUE) %>% as_tibble() %>% filter(str_sub(value, 25, 39) == "Libraries Calls") %>% pull()
new_system_data <- list.files("data/raw/LibraryConnect", full.names = TRUE) %>% as_tibble() %>% filter(str_sub(value, 25, 39) != "Libraries Calls") %>% pull()

# Load and clean the LibraryConnect data
prep_data <- function(x, sheet, skip_rows) {
  x %>% read_excel(sheet = sheet, col_names = T, skip = skip_rows) %>% 
    select(date = 1, Metric = "Answered") %>% 
    replace_na(list(Metric = 0)) %>% 
    slice(1:n()-1) %>% 
    mutate(date = convert_to_date(date), Month = month(date, label = TRUE, abbr = TRUE), Year = year(date)) %>% 
    group_by(Month, Year) %>% 
    summarise(Metric = sum(Metric), .groups = "drop") %>% 
    mutate(across(c(1:2), as.character))
}

LibrariesConnect_old <- map(old_system_data, prep_data, sheet = 2, skip_rows = 3)
LibrariesConnect_new <- map(new_system_data, prep_data, sheet = 1, skip_rows = 0)

bind_rows(LibrariesConnect_old, LibrariesConnect_new) %>% 
  mutate(id = 8) %>% 
  saveRDS(here::here("data/rds/LibraryConnect.rds"))
