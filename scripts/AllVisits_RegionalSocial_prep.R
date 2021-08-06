metrics <- c(" engagement|sound cloud podcast listens|youtube views|page views")

# Prepare regional social data, irrespective of the FY
RegionalSocialPrep <- function(x) {
  x %>% read_excel(range = cell_cols("A:N")) %>%
    select(1:Total) %>% 
    pivot_longer(2:(length(.)-1), values_to = "Metric", names_transform = list(name = as.integer)) %>%
    filter(str_detect(str_to_lower(...1), metrics) & (!is.na(Metric) & Metric > 0)) %>%
    mutate(Month = format(excel_numeric_to_date(name), "%b"), Year = format(excel_numeric_to_date(name), "%Y")) %>% 
    select(platform = 1, 4, 5, 6)
}

# filter the regional social data based on a platform of choice
assign_variable <- function(platform_pattern) {
  RegionalSocial %>% filter(str_detect(str_to_lower(platform), platform_pattern)) %>% 
    select(-1)
}

# List all regional social data files
files <- list.files("data/raw/RegionalSocial", full.names = TRUE)

# Load and clean all regional social data files
RegionalSocial <- lapply(files, RegionalSocialPrep) %>% 
  bind_rows()

# Assign each regional social media platform to its own variable
RegionalBlog <- assign_variable("blog page views")
RegionalFacebook <- assign_variable("facebook")
RegionalTwitter <- assign_variable("twitter")
RegionalInstagram <- assign_variable("instagram")
RegionalSoundCloud <- assign_variable("sound cloud")
RegionalYouTube <- assign_variable("youtube")
