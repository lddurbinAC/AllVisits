suppressPackageStartupMessages(library(dplyr)) # A Grammar of Data Manipulation
suppressPackageStartupMessages(library(janitor)) # Simple Tools for Examining and Cleaning Dirty Data
suppressPackageStartupMessages(library(ggplot2)) # Create Elegant Data Visualisations Using the Grammar of Graphics
suppressPackageStartupMessages(library(tidyr)) # Tidy Messy Data
suppressPackageStartupMessages(library(purrr)) # Functional Programming Tools
(library(scales)) # Scale Functions for Visualization
library(stringr) # Simple, Consistent Wrappers for Common String Operations
library(lubridate) # Make Dealing with Dates a Little Easier
library(ggtext) # Improved Text Rendering Support for 'ggplot2'

source(here::here("scripts/create_vector.R"))

data <- readr::read_csv(here::here("data/raw/library_stats.csv")) %>% 
  janitor::clean_names()

summary <- data %>% mutate(
  year = case_when(
    month %in% c("Jul", "Aug", "Sep", "Oct", "Nov", "Dec") ~ 1999 + as.double(str_sub(financial_year, 3)),
    TRUE ~ 2000 + as.double(str_sub(financial_year, 3))
  ),
  date = ymd(paste0(year, month, "01"))
) %>% 
  select(date, checkouts_in_library, e_issues_online, visits_in_library) %>% 
  tidyr::pivot_longer(-date) %>% 
  mutate(
    value = ifelse(value <= 1000, 0, value),
    closures = ifelse(date %in% c(ymd("2020-03-01"), ymd("2020-04-01")) & name == "checkouts_in_library", TRUE, FALSE)
  )

checkouts <- summary %>%
  filter(name != "visits_in_library") %>%
  group_by(date) %>% 
  mutate(month_total = sum(value), share = value/month_total, checkouts_cumulative = cumsum(share)) %>% 
  ungroup()

checkouts_calcs <- tibble(
  x_percent = seq(0, 1, by = 1 / 15),
  electronic_y_value = create_slope_vector(num_values = 16, start_value = 0.159, end_value = 0.334),
  physical_y_value = create_slope_vector(num_values = 16, start_value = 1, end_value = 1)
)

metrics <- c("physical_y_value", "electronic_y_value")

ggplot(checkouts_calcs, aes(x = x_percent)) +
  geom_text(aes(x = -.05, y = 1.05, label = "Share of all checkouts\nin January 2018"), size = 5) +
  geom_text(aes(x = 1.03, y = 1.05, label = "Share of all checkouts\nin January 2022"), size = 5) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 1.15), expand = c(0, 0)) +
  theme_minimal() +
  theme(axis.text = element_blank(), axis.title = element_blank(), panel.grid = element_blank(), title = element_text(size = 15), plot.title = element_markdown(lineheight = 1.1)) +
  labs(
    title = "A third of our checkouts are now from <span style='color:#56B4E9'><strong>digital items</strong></span> - twice as high as four years ago.<br>Will checkouts of <span style='color:#56B4E9'><strong>digital items</strong></span> exceed <span style='color:#E69F00'><strong>physical items</strong></span> in the <i>next</i> four years?",
    caption = "Proportion of total checkouts that are from in-person and e-issues, 2018 to 2022"
  ) +
  map2(metrics, c("#E69F00", "#56B4E9"), ~ geom_area(aes(y = .data[[{{ .x }}]]), fill = .y)) + # plot areas
  map(metrics, ~ geom_line(aes(y = .data[[{.x}]]), size = 5 / 4)) + # add line above each area
  map(metrics, ~ geom_segment(aes(x = -.17, xend = 0, y = min(.data[[{.x}]]), yend = min(.data[[{.x}]])), size = 5 / 4)) + # extend the lines to the left
  map(metrics, ~ geom_segment(aes(x = 1, xend = 1.17, y = max(.data[[{.x}]]), yend = max(.data[[{.x}]])), size = 5 / 4)) +
  pmap(list(c(-.09, -0.09, 1.09, 1.09), c(.08, .6, .16, .6), c("Digital\n16%", "Physical\n84%", "Digital\n33%", "Physical\n66%")), ~geom_text(aes(x = ..1, y = ..2, label = ..3), size = 5))
