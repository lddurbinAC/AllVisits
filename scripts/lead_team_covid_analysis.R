library(dplyr)
library(ggplot2)
library(lubridate)
library(ggtext)
library(purrr)
library(stringr)

# closure_start <- c(ymd("2020-03-24"), ymd("2021-09-01"))
# closure_end <- c(ymd("2020-05-15"), ymd("2021-10-31"))
# 
# curve_x_starts <- c(ymd("2020-01-01"), ymd("2020-02-01"), ymd("2020-12-01"), ymd("2021-06-01"), ymd("2022-02-01"))
# curve_x_ends <- c(ymd("2020-03-01"), ymd("2020-05-01"), ymd("2020-08-10"), ymd("2021-07-20"), ymd("2021-11-08"))
# curve_y_starts <- c(450000, 50000, 150000, 460000, 580000)
# curve_y_ends <- c(630000, 275000, 370000, 430000, 520000)
# 
# annotation_x <- c(ymd("2019-10-01"), ymd("2019-11-01"), ymd("2020-12-20"), ymd("2021-04-20"), ymd("2022-04-10"))
# annotation_y <- c(450000, 50000, 100000, 520000, 565000)
# annotation_txt <- c(
#   "Libraries closed\nfrom final week of March 2020",
#   "Libraries re-opened in\nlate May 2020",
#   "Libraries closed in\nlate August 2020",
#   "Libraries closed\nfrom mid-August 2021",
#   "Libraries gradually\nre-open in\nNovember 2021"
# )

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
    closures = ifelse(date %in% c(ymd("2020-03-01"), ymd("2020-04-01"), ymd("2020-05-01"), ymd("2020-08-01"), ymd("2021-08-01"), ymd("2021-09-01"), ymd("2021-10-01"), ymd("2021-11-01")), TRUE, FALSE)
    )

summary %>% 
  filter(name != "visits_in_library") %>% 
  ggplot(aes(x = date, y = value, colour = name)) +
  geom_point(aes(shape = name, fill = name), size=3) +
  geom_smooth(data=summary[summary$value>0 & summary$name!="visits_in_library",], se = FALSE, size = 1.5) +
  geom_point(data=summary[summary$closures==TRUE & summary$name!="visits_in_library",], pch=21, fill=NA, size=5, colour="black", stroke=1.5) +
  # pmap(list(curve_x_starts, curve_y_starts, curve_x_ends, curve_y_ends), ~annotate(geom = "curve", x = ..1, y = ..2, xend = ..3, yend = ..4, arrow = arrow(length = unit(0.03, "npc")))) +
  # pmap(list(annotation_x, annotation_y, annotation_txt), ~annotate(geom = "text", x = ..1, y = ..2, label = ..3)) +
  scale_y_continuous(labels = scales::comma, limits = c(0,1200000), breaks = seq(0,1200000, by = 200000)) +
  scale_x_date(limits = c(ymd("2017-06-01", "2022-05-01"))) +
  scale_shape_manual(values=c(18, 16))+
  scale_color_manual(values=c('#E69F00', '#56B4E9')) +
  theme_minimal() +
  theme(
    axis.title = element_blank(),
    axis.text = element_text(size = 11),
    legend.position = "none",
    plot.title.position = "plot",
    plot.title = element_markdown(lineheight = 1.1),
    title = element_text(size = 16),
    plot.caption = element_text(size=10),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "The rising popularity of our <span style='color:#56B4E9'><strong>e-collections</strong></span> (and corresponding fall of <span style='color:#E69F00'><strong>in-person checkouts</strong></span>) is<br>a long-term trend that pre-dates COVID-induced library closures (circled)",
    caption = "Monthly in-person library checkouts and e-issues, July 2017 to January 2022. Zero-value data excluded from regression line"
  )