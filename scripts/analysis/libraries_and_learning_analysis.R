library(dplyr, warn.conflicts = FALSE)
library(readxl, warn.conflicts = FALSE)
library(janitor, warn.conflicts = FALSE)
library(stringr, warn.conflicts = FALSE)
library(ggplot2, warn.conflicts = FALSE)
library(ggtext, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)

plot <- function(service_name, libraries_and_learning) {
  data <- libraries_and_learning %>% filter(service_name == {{service_name}})
  
  p <- data %>% 
    ggplot(mapping = aes(x = date, y = metric)) +
    annotate("rect", xmin = as.Date(int_start(lockdown_periods)), xmax = as.Date(int_end(lockdown_periods)), ymin = 0, ymax = max(data$metric), fill = lockdown_colours, alpha = .3) +
    geom_line(size = 1.5, color = "blue") +
    geom_point(size = 2) +
    ggthemes::theme_fivethirtyeight() +
    theme(legend.position = "none", panel.grid.major.x = element_blank()) +
    scale_x_date(date_labels = paste0("%b", " '", "%y"), breaks = "2 months", limits = c(ymd("2020-01-01"), ymd("2021-09-30"))) +
    scale_y_continuous(labels = scales::label_comma()) +
    labs(
      title = paste0(data$service_name, " ", str_to_lower(data$metric_name), " since January 2020<br><span style='color:#a93226'>Alert Level 4</span>, <span style='color:#ff9f33'>Alert Level 3</span>, and <span style='color:#979a9a'>Alert Level 2</span> highlighted")
    ) +
    theme(plot.title = element_markdown(lineheight = 1.1))
  
  ggsave(filename = paste0("plots/", data$filename, ".png"), device = "png", plot = p, width = 10)
}

metadata <- read_excel(here::here("data/AllVisits_data_sources.xlsx"), sheet = 2) %>% 
  clean_names() %>% 
  select(-c(metric_definition:data_supplier)) %>% 
  mutate(id = as.character(id))

libraries_and_learning <- readRDS(here::here("data/processed/AllVisits.rds")) %>% 
  left_join(metadata, by = "id") %>% 
  mutate(date = date + days(14)) %>% 
  mutate(service_name = case_when(
    str_detect(service_name, "mobile app") ~ "Libraries App",
    service_name == "Facebook" & delivery_team == "Heritage Engagement" ~ "Facebook (Heritage)",
    TRUE ~ service_name
  )) %>% 
  mutate(metric_name = case_when(
    service_name == "Libraries App" ~ "Daily users or launches",
    TRUE ~ metric_name
  )) %>% 
  mutate(filename = str_replace_all(service_name, " ", "_") %>% str_replace_all("&|\\(|\\)", "") %>% str_to_lower()) %>% 
  filter(date >= as.Date("2020-01-01"))

lockdown_periods <- c(
  interval(ymd("2020-03-26"), ymd("2020-04-27")),
  interval(ymd("2020-04-28"), ymd("2020-05-13")),
  interval(ymd("2020-05-14"), ymd("2020-06-08")),
  interval(ymd("2020-08-12"), ymd("2020-08-30")),
  interval(ymd("2020-08-31"), ymd("2020-10-07")),
  interval(ymd("2021-02-14"), ymd("2021-02-17")),
  interval(ymd("2021-02-17"), ymd("2021-02-22")),
  interval(ymd("2021-02-28"), ymd("2021-03-07")),
  interval(ymd("2021-03-08"), ymd("2021-03-12")),
  interval(ymd("2021-08-17"), ymd("2021-09-21"))
)

lockdown_colours <- c("#a93226", "#ff9f33", "#979a9a", "#ff9f33", "#979a9a", "#ff9f33", "#979a9a", "#ff9f33","#979a9a", "#a93226")

service_names <- libraries_and_learning %>% distinct(service_name) %>% pull()
purrr::walk(service_names, plot, libraries_and_learning)
