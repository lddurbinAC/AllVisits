# *****************************************************************************
# Setup ----

# Load libraries
library("dplyr", warn.conflicts = FALSE) # A Grammar of Data Manipulation
library("readr", warn.conflicts = FALSE) 
library("stringr", warn.conflicts = FALSE) 
library("tidyr", warn.conflicts = FALSE) 
library("purrr", warn.conflicts = FALSE) 
library("readxl", warn.conflicts = FALSE) # Read Excel Files
library("janitor", warn.conflicts = FALSE) # Simple Tools for Examining and Cleaning Dirty Data
library("lubridate", warn.conflicts = FALSE) # Make Dealing with Dates a Little Easier

# *****************************************************************************


# *****************************************************************************
# Load and prep data ---- 

# Record and Archives (enquiries and website sessions)
source("scripts/AllVisits_AandR_prep.R")

# Library app (old and new)
source("scripts/AllVisits_Boopsie_prep.R")
source("scripts/AllVisits_Solus_prep.R")

# Outreach participation (community libraries, mobile and access, research and heritage)
source("scripts/AllVisits_DX_prep.R")

# Research and Heritage Facebook
source("scripts/AllVisits_HeritageSocial_prep.R")

# Website sessions for Kura, Manuscripts Online, and Heritage Images
source("scripts/AllVisits_Kura_ManuscriptsOnline_HeritageImages_prep.R")

# Answered calls on Library Connect
source("scripts/AllVisits_LibraryConnect_prep.R")

# Daily visits to the Overdrive website
source("scripts/AllVisits_Overdrive_prep.R")

# Regional social media engagement, views, listens
source("scripts/AllVisits_RegionalSocial_prep.R")

# Subscription databases sessions
source("scripts/AllVisits_SubscriptionDatabases_prep.R")

# *****************************************************************************


# *****************************************************************************
# Create and save output file ---- 

# Create one data frame for everything, assign IDs to each service, join with categories, add date, replace NAs with 0, filter out current month
AllVisits <- bind_rows(
  AandR_enquiries,
  AandR_sessions,
  Boopsie,
  community_outreach,
  HeritageSocial,
  HeritageImages,
  Kura,
  LibraryConnect,
  ManuscriptsOnline,
  mobile_outreach,
  Overdrive,
  RegionalBlog,
  RegionalFacebook,
  RegionalInstagram,
  RegionalTwitter,
  RegionalSoundCloud,
  RegionalYouTube,
  research_outreach,
  Subscriptions,
  Solus,
  .id = "id") %>% 
  mutate(date = as.Date(paste(Month, "01", Year, sep="/"), format="%b/%d/%Y")) %>% 
  select(-Month, -Year, metric = Metric) %>% 
  complete(fill = list(Metric = 0)) %>% 
  filter(date != as.Date(format(Sys.Date(), paste("%Y-%m", "01", sep="-"))))

# Change infinite values to zero
AllVisits[AllVisits == Inf] <- 0

source(here::here("scripts/exports.R"))

# *****************************************************************************

