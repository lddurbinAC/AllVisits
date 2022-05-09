library(dplyr)
library(ggplot2)
library(lubridate)
library(ggtext)
library(purrr)
library(stringr)

curve_x_starts <- c(ymd("2019-09-01"), ymd("2019-10-01"), ymd("2020-07-10"))
curve_x_ends <- c(ymd("2020-02-01"), ymd("2020-03-18"), ymd("2020-05-01"))
curve_y_starts <- c(700000, 40000, 470000)
curve_y_ends <- c(675000, 0, 365000)
curvature <- c(-0.15, 0.2, 0.3)

annotation_x <- c(ymd("2019-05-01"), ymd("2019-06-10"), ymd("2020-07-20"))
annotation_y <- c(700000, 55000, 505000)
annotation_txt <- c(
  "Libraries closed\nfor part of this month",
  "Libraries closed for\nentire month",
  "Rise in e-issues\nwhen libraries closed"
)

closure_dates <- map(c("2020-03-01", "2020-04-01", "2020-05-01", "2020-08-01", "2021-02-01", "2021-08-01", "2021-09-01", "2021-10-01", "2021-11-01"), ymd)
omicron_dates <- map(c("2020-03-01", "2020-04-01", "2020-05-01", "2020-08-01", "2021-02-01"), ymd)

data <- readr::read_csv(here::here("data/raw/library_stats.csv")) %>% 
  janitor::clean_names()

summary <- data %>% mutate(
  year = case_when(
    month %in% c("Jul", "Aug", "Sep", "Oct", "Nov", "Dec") ~ 1999 + as.double(str_sub(financial_year, 3)),
    TRUE ~ 2000 + as.double(str_sub(financial_year, 3))
  ),
  date = ymd(paste0(year, month, "01"))
) %>% 
  select(date, checkouts_in_library, e_issues_online) %>% 
  tidyr::pivot_longer(-date) %>% 
  mutate(
    value = ifelse(value <= 1000, 0, value)
    )

any_closures_data <- summary %>% 
  filter(name == "e_issues_online" | !date %in% closure_dates)

total_closures_data <- summary %>% 
  filter(name == "e_issues_online" | !date %in% omicron_dates)

points <- anti_join(summary, any_closures_data, by = c("date", "name"))

lines <- anti_join(summary, total_closures_data, by = c("date", "name"))

stage <- 1:3

summary %>% 
  ggplot(aes(x = date, y = value, colour = name)) +
  geom_point(aes(shape = name, fill = name), size=3) +
  geom_smooth(data = any_closures_data, se = FALSE, size = 1.5) +
  geom_point(data = points, pch=21, fill=NA, size=4, colour="black", stroke=0.75) +
  pmap(list(curve_x_starts[stage], curve_y_starts[stage], curve_x_ends[stage], curve_y_ends[stage], curvature[stage]), ~annotate(geom = "curve", x = ..1, y = ..2, xend = ..3, yend = ..4, curvature =..5, arrow = arrow(length = unit(0.02, "npc")))) +
  pmap(list(annotation_x[stage], annotation_y[stage], annotation_txt[stage]), ~annotate(geom = "text", x = ..1, y = ..2, label = ..3)) +
  scale_y_continuous(labels = scales::comma, limits = c(0,1250000), breaks = seq(0,1200000, by = 200000)) +
  scale_x_date(limits = c(ymd("2017-06-01", "2022-03-01")), breaks = "6 months", date_labels = "%b %Y") +
  scale_shape_manual(values=c(18, 16))+
  scale_color_manual(values=c('#E69F00', '#56B4E9')) +
  geom_segment(aes(x = ymd("2020-03-01"), y = 0, xend = ymd("2020-03-01"), yend = 1200000), colour = "grey", linetype = "dashed") +
  geom_segment(aes(x = ymd("2021-08-01"), y = 0, xend = ymd("2021-08-01"), yend = 1200000), colour = "grey", linetype = "dashed") +
  annotate(geom = "text", x = ymd("2020-03-01"), y = 1225000, label = "First COVID lockdown") +
  annotate(geom = "text", x = ymd("2021-08-01"), y = 1225000, label = "Delta & Omicron") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),
    axis.text = element_text(size = 11),
    legend.position = "none",
    plot.title.position = "plot",
    plot.title = element_markdown(lineheight = 1.1),
    title = element_text(size = 16),
    plot.caption = element_text(size=9),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "Since at least mid-2017, our <span style='color:#56B4E9'><strong>e-collections</strong></span> have been steadily growing in popularity as our<br><span style='color:#E69F00'><strong>in-person checkouts</strong></span> have been declining - but it's too early to say if COVID has permanently<br>accelerated the downward trend",
    caption = "Monthly in-person checkouts and e-issues, July 2017 to February 2022. Encircled points excluded from orange trend line."
  )
