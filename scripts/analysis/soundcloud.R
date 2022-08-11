library(dplyr) # A Grammar of Data Manipulation
library(ggplot2) # Create Elegant Data Visualisations Using the Grammar of Graphics

path <- here::here("data/raw")

soundcloud <- readxl::read_excel(fs::dir_ls(path, glob = "*.xlsx"))

plot <- ggplot(soundcloud, aes(x = date, y = metric)) +
  geom_smooth(se = FALSE, size = 1.5, colour = "orange2") +
  geom_point(size=3, colour = "blue") +
  theme_minimal() +
  theme(
    plot.title.position = "plot",
    plot.title = element_text(size=18),
    axis.title = element_blank(),
    axis.text = element_text(size=10),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  ) +
  labs(
    title = "After many months of growing or sustained numbers, our podcasts seemed to attract fewer listeners in recent months",
    subtitle = "Total podcast listens per month | Source: SoundCloud"
  )

ggsave("podcast_listen.png", plot = plot, path = "plots", bg = "white", device = "png")