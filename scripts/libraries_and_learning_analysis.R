library(ggplot2, warn.conflicts = FALSE)

metadata <- read_excel(here::here("data/AllVisits_data_sources.xlsx"), sheet = 2) %>% 
  clean_names() %>% 
  select(-c(metric_definition:data_supplier)) %>% 
  mutate(id = as.character(id))
  
libraries_and_learning <- AllVisits %>% 
  left_join(metadata, by = "id") %>% 
  filter(delivery_team %in% c("Content Development & Engagement", "Records and Archives")) %>% 
  mutate(service_name = case_when(
    str_detect(service_name, "mobile app") ~ word(service_name, -1),
    TRUE ~ service_name
  ))

libraries_and_learning %>% 
  ggplot(mapping = aes(x = date, y = metric)) +
  geom_line() +
  facet_wrap(~ service_name, scales = "free") +
  ggthemes::theme_fivethirtyeight() +
  scale_x_date(date_labels = "%Y")
