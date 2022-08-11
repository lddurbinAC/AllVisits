metrics <- c(" engagement|sound cloud podcast listens|sound cloud podcast plays|youtube views|page views")

# Prepare regional social data, irrespective of the FY
RegionalSocialPrep <- function(x) {
  x %>% read_excel(range = cell_cols("A:N"), col_types = "text") %>%
    select(1:Total) %>% 
    pivot_longer(2:(length(.)-1), values_to = "Metric", names_transform = list(name = as.integer)) %>%
    filter(str_detect(str_to_lower(...1), metrics) & (!is.na(Metric) & Metric > 0)) %>%
    mutate(Month = format(excel_numeric_to_date(name), "%b"), Year = format(excel_numeric_to_date(name), "%Y"), Metric = as.double(Metric)) %>% 
    select(platform = 1, 4, 5, 6)
}

# filter the regional social data based on a platform of choice
assign_variable <- function(platform_pattern, id, path) {
  RegionalSocial %>% filter(str_detect(str_to_lower(platform), platform_pattern)) %>% 
    select(-1) %>% 
    mutate(id := {{id}}) %>% 
    saveRDS(here::here({{path}}))
}

# List all regional social data files
files <- list.files("data/raw/RegionalSocial", full.names = TRUE)

# Load and clean all regional social data files
RegionalSocial <- lapply(files, RegionalSocialPrep) %>% 
  bind_rows()

# Assign each regional social media platform to its own RDS file
assign_variable("blog page views", id = 12, path = "data/rds/RegionalBlog.rds")
assign_variable("facebook", id = 13, path = "data/rds/RegionalFacebook.rds")
assign_variable("twitter", id = 15, path = "data/rds/RegionalTwitter.rds")
assign_variable("instagram", id = 14, path = "data/rds/RegionalInstagram.rds")
assign_variable("sound cloud", id = 16, path = "data/rds/RegionalSoundCloud.rds")
assign_variable("youtube", id = 17, path = "data/rds/RegionalYouTube.rds")
