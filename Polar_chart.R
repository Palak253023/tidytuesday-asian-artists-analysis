# Asian Artists in the USA
# Replication and extension of TidyTuesday Week 39 (2022).
# Dataset: https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-09-27/artists.csv
# Original visualization credit: Isaac Arroyo (see README for attribution).

# ------ LOAD PACKAGES ------

packages <- c(
  "tidyverse",
  "ggtext",
  "geomtextpath",
  "sysfonts",
  "showtextdb",
  "showtext",
  "MetBrewer"
)

for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(tidyverse)
library(ggtext)
library(geomtextpath)
library(sysfonts)
library(showtextdb)
library(showtext)
library(MetBrewer)

# ------ OUTPUT DIRECTORY ------

output_dir <- file.path(".", "Output")

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# ------ LOAD DATA ------
artists <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-09-27/artists.csv')

# ------ EXPLORE DATA ------
glimpse(artists)

# ------ DATA WRANGLING ------
artists_cat <- artists %>%
  filter(race == "Asian") %>%
  replace_na(list(artists_n = 0, location_quotient = 0)) %>%
  mutate(art_expression = case_when(type %in% c("Designers", "Fine Artists, Art Directors, And Animators", "Photographers") ~ "Visual",
                                    type %in% c("Architects","Landscape Architects") ~ "Architecture",
                                    type %in% c("Writers And Authors") ~ "Literature",
                                    type %in% c("Musicians", "Music Directors And Composers") ~ "Music",
                                    type %in% c("Dancers And Choreographers") ~ "Dance",
                                    type %in% c("Producers And Directors", "Entertainers","Actors", "Announcers") ~ "Performance",
                                    TRUE ~ "Another art expression"),
         art_expression = case_when(art_expression == "Architecture" ~ "**Architecture** (_Architects and Landscape Architects)_",
                                    art_expression == "Dance" ~ "**Dance** (_Dancers and Choreographers_)",
                                    art_expression == "Literature" ~ "**Literature** (_Writers and Authors_)",
                                    art_expression == "Music" ~ "**Music** (_Musicians, Music Directors and Composers_)",
                                    art_expression == "Performance" ~ "**Performance** (_Actors, Announcers, Entertainers, Producers and Directors_)",
                                    art_expression == "Visual" ~ "**Visual** (_Designers, Photographers, Fine Artists, Art Directors and Animators_)",
                                    TRUE ~ "Another art expression"))

df_percentage_of_asian_artists <- artists_cat %>%
  group_by(state, art_expression) %>%
  summarise(
    all_workers = max(all_workers_n),
    number_of_artists = sum(artists_n),
    percentage_of_artists = 100 * (number_of_artists / all_workers)
  ) %>% ungroup() %>% rename(state_usa = state)

# ------ DATA VISUALIZATION ------
# Text
title_text <- "Where the Asian Artists at?"
subtitle_text <- "Asian artists represent less than 1% of the state's workers on average; however, some places are **THE PLACE** for artists: **New York** and **California**.<br>&bull; **New York** has the highest proportion of asian artists among all the asian workers, with approximately 2.6% (22,820 artists out of 864,770 workers).<br>&bull; **California** has the highest number of asian artists, with 61,210."

# Typography
font_add_google("Lora", "title_font")
font_add_google("Lato", "body_font")
showtext_auto()

title_font <- "title_font"
body_font <- "body_font"

# Settings
theme_set(theme_void())
theme_update(
  # General plot
  plot.margin = unit(rep(0,4), "in"),
  # Title
  plot.title.position = "plot",
  plot.title = element_textbox(family = title_font,
                               lineheight = 0.2,
                               size = rel(8),
                               face = 'bold',
                               halign = 0.5,
                               hjust = 0.5,
                               width = unit(8,"in"),
                               padding = margin(0.125,0,0,0,"in"),
                               margin = margin(0,0,0,0,"in")),
  # Subtitle
  plot.subtitle = element_textbox(family = body_font,
                                  lineheight = 0.4,
                                  size = rel(3.3),
                                  halign = 0,
                                  hjust = 0.5,
                                  width = unit(8,"in"),
                                  padding = margin(0.125,0.125,0.3,0.125,"in"),
                                  margin = margin(0,0,0,0,"in")),
  # Legend
  legend.position = "top",
  legend.title = element_markdown(family = title_font,
                                  lineheight = 0.2,
                                  size = rel(4),
                                  face = "bold",
                                  halign = 0,
                                  hjust = 0.5),
  legend.text = element_textbox(family = body_font,
                                lineheight = 0.33,
                                size = rel(2.5),
                                valign = 0.5,
                                width = unit(2,"in"),
                                margin = margin(0,0,0.0625,0.05,"in")),
  legend.spacing.x = unit(0.125,"in"),
  legend.spacing.y = unit(0.0625, "in"),
  
  # Axis
  axis.title = element_blank(),
  axis.ticks = element_blank(),
  axis.text = element_blank(),
)

# ------ Data viz (% of workers) ------
p1 <- df_percentage_of_asian_artists %>%
  ggplot(aes(x = state_usa, y = percentage_of_artists, fill = art_expression)) +
  geom_texthline(
    data = data.frame(x = 1, y = 1),
    aes(yintercept = y),
    label = "1% of workers",
    family = body_font,
    spacing = -250,
    size = 7,
    colour = "gray70",
    textcolour = "gray70",
    lineend = "round",
    linetype = "dashed",
    inherit.aes = FALSE
  ) + 
  geom_col() +
  geom_textpath(
    aes(label = state_usa, y = 3, angle = 90),
    family = title_font,
    spacing = -120,
    size = 7,
    upright = TRUE
  ) +
  ylim(c(-0.2, 3)) +
  guides(fill = guide_legend(title = "Art Expression", title.position = "top")) +
  scale_fill_manual(values = met.brewer(name = "Juarez", n = 6)) +
  coord_polar(theta = "x", start = 0) +
  labs(title = title_text, subtitle = subtitle_text)

ggsave(
  filename = file.path(output_dir, "polar_stacked_chart.png"),
  plot = p1,
  width = 8.5,
  height = 11,
  units = "in",
  dpi = 300,
  bg = "#FAFBFC"
)