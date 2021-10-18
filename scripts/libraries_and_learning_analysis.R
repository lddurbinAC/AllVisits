library(dplyr, warn.conflicts = FALSE)
library(readxl, warn.conflicts = FALSE)
library(janitor, warn.conflicts = FALSE)
library(stringr, warn.conflicts = FALSE)
library(ggplot2, warn.conflicts = FALSE)
library(ggtext, warn.conflicts = FALSE)
library(purrr, warn.conflicts = FALSE)

plot <- function(service_name, libraries_and_learning) {
  data <- libraries_and_learning %>% filter(service_name == {{service_name}})
  
  level4_1 <- annotate("rect", xmin = as.Date("2020-03-26"), xmax = as.Date("2020-04-27"), ymin = 0, ymax = max(data$metric), fill = "#a93226", alpha = .3)
  level3_1 <- annotate("rect", xmin = as.Date("2020-04-28"), xmax = as.Date("2020-05-13"), ymin = 0, ymax = max(data$metric), fill = "#ff9f33", alpha = .3)
  level2_1 <- annotate("rect", xmin = as.Date("2020-05-14"), xmax = as.Date("2020-06-08"), ymin = 0, ymax = max(data$metric), fill = "#979a9a", alpha = .3)
  level3_2 <- annotate("rect", xmin = as.Date("2020-08-12"), xmax = as.Date("2020-08-30"), ymin = 0, ymax = max(data$metric), fill = "#ff9f33", alpha = .3)
  level2_2 <- annotate("rect", xmin = as.Date("2020-08-31"), xmax = as.Date("2020-10-07"), ymin = 0, ymax = max(data$metric), fill = "#979a9a", alpha = .3)
  level3_3 <- annotate("rect", xmin = as.Date("2021-02-14"), xmax = as.Date("2021-02-17"), ymin = 0, ymax = max(data$metric), fill = "#ff9f33", alpha = .3)
  level2_3 <- annotate("rect", xmin = as.Date("2021-02-17"), xmax = as.Date("2021-02-22"), ymin = 0, ymax = max(data$metric), fill = "#979a9a", alpha = .3)
  level3_4 <- annotate("rect", xmin = as.Date("2021-02-28"), xmax = as.Date("2021-03-07"), ymin = 0, ymax = max(data$metric), fill = "#ff9f33", alpha = .3)
  level2_4 <- annotate("rect", xmin = as.Date("2021-03-08"), xmax = as.Date("2021-03-12"), ymin = 0, ymax = max(data$metric), fill = "#979a9a", alpha = .3)
  level4_2 <- annotate("rect", xmin = as.Date("2021-08-17"), xmax = as.Date("2021-09-21"), ymin = 0, ymax = max(data$metric), fill = "#a93226", alpha = .3)
  
  p <- data %>% 
    ggplot(mapping = aes(x = date, y = metric)) +
    level4_1 +
    level3_1 +
    level2_1 +
    level3_2 +
    level2_2 +
    level3_3 +
    level2_3 +
    level3_4 +
    level2_4 +
    level4_2 +
    geom_line(size = 1.5, color = "blue") +
    geom_point(size = 2) +
    ggthemes::theme_fivethirtyeight() +
    theme(legend.position = "none", panel.grid.major.x = element_blank()) +
    scale_x_date(date_labels = paste0("%b", " '", "%y"), breaks = "2 months") +
    scale_y_continuous(labels = scales::label_comma()) +
    labs(
      title = paste0(data$service_name, " ", str_to_lower(data$metric_name), " since January 2020<br><span style='color:#a93226'>Alert Level 4</span>, <span style='color:#ff9f33'>Alert Level 3</span>, and <span style='color:#979a9a'>Alert Level 2</span> highlighted")
    ) +
    theme(plot.title = element_markdown(lineheight = 1.1))
  
  ggsave(filename = paste0("plots/plot_", data$id[1], ".png"), device = "png", plot = p, width = 10)
}

metadata <- read_excel(here::here("data/AllVisits_data_sources.xlsx"), sheet = 2) %>% 
  clean_names() %>% 
  select(-c(metric_definition:data_supplier)) %>% 
  mutate(id = as.character(id))
  
libraries_and_learning <- readRDS(here::here("data/processed/AllVisits.rds")) %>% 
  left_join(metadata, by = "id") %>% 
  mutate(service_name = case_when(
    str_detect(service_name, "mobile app") ~ "Libraries App",
    TRUE ~ service_name
  )) %>% 
  mutate(metric_name = case_when(
    service_name == "Libraries App" ~ "Daily users or launches",
    TRUE ~ metric_name
  )) %>% 
  filter(delivery_team %in% c("Content Development & Engagement") & date >= as.Date("2020-01-01"))

service_names <- libraries_and_learning %>% distinct(service_name) %>% pull()
walk(service_names, plot, libraries_and_learning)
