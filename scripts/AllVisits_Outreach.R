raw_data <- readRDS(here::here("data/raw/Outreach/joined_data.rds"))

raw_data %>%
  filter(what_was_the_format_of_the_session != "Book a Librarian", in_person, !is.na(delivery_datetime) & location %in% c("Another Council-managed facility", "A community-led facility", "Other")) %>% 
  select(id, delivery_datetime, location, delivery_library_names, unit_1_teams, unit_3_teams, ends_with("in_person_at_this_session")) %>% 
  pivot_longer(c(delivery_library_names, unit_1_teams, unit_3_teams), names_to = "team_type", values_to = "team_name") %>% 
  filter(str_detect(team_name, "Library|Hub|Heritage|Research")) %>% 
  rowwise() %>% 
  mutate(
    Month = month(floor_date(as_date(delivery_datetime), unit = "months"), label = TRUE),
    Year = year(as_date(delivery_datetime)),
    team_type = ifelse(team_type == "delivery_library_names", "Libraries", "Research and Heritage"),
    participation = sum(across(ends_with("in_person_at_this_session")), na.rm = TRUE),
    .keep = "unused") %>% 
  ungroup() %>% 
  distinct(id, Month, Year, team_type, participation) %>% 
  with_groups(c(team_type, Month, Year), summarise, Metric = sum(participation)) %>% 
  tidyr::complete(Month = Month, nesting(team_type, Year), fill = list(Metric = 0)) %>% 
  mutate(id = ifelse(team_type == "Libraries", 4, 18), Year = as.character(Year), .keep = "unused") %>% 
  filter(ymd(paste(Year, Month, "01", sep = "-")) > ymd("2021-06-30") & ymd(paste(Year, Month, "01", sep = "-")) < floor_date(today(), "months")) %>% 
  saveRDS(here::here("data/rds/Outreach.rds"))