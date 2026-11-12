# Asian Artists in the USA
# Replication and extension of TidyTuesday Week 39 (2022).
# Dataset: https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-09-27/artists.csv
# Original visualization credit: Isaac Arroyo (see README for attribution).

# ------ PACKAGES ------

packages <- c(
  "tidyverse",
  "MetBrewer",
  "showtext",
  "sysfonts",
  "gridExtra",
  "scales"
)

for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(tidyverse)
library(MetBrewer)
library(showtext)
library(sysfonts)
library(gridExtra)
library(grid)

# ------ LOAD DATA ------

artists <- readr::read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-09-27/artists.csv",
  show_col_types = FALSE
)

# ------ SETTINGS ------

output_dir <- file.path(".", "Output")

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

font_add_google("Lora", "title_font")
font_add_google("Lato", "body_font")

showtext_auto()

# ------ CATEGORY LABELS ------

category_labels <- c(
  "Visual" = "Visual (Designers, Photographers, Fine Artists, Art Directors and Animators)",
  "Architecture" = "Architecture (Architects and Landscape Architects)",
  "Literature" = "Literature (Writers and Authors)",
  "Music" = "Music (Musicians, Music Directors and Composers)",
  "Dance" = "Dance (Dancers and Choreographers)",
  "Performance" = "Performance (Actors, Announcers, Entertainers, Producers and Directors)"
)

category_order <- names(category_labels)

# ------ COLOUR PALETTE ------

juarez_colours <- MetBrewer::met.brewer(
  name = "Juarez",
  n = 6
)

names(juarez_colours) <- category_order

# ------ DATA WRANGLING ------

artists_cat <- artists %>%
  filter(race == "Asian") %>%
  mutate(
    artists_n = replace_na(artists_n, 0),
    location_quotient = replace_na(location_quotient, 0),
    type = str_squish(type),
    
    art_expression = case_when(
      type %in% c(
        "Designers",
        "Fine Artists, Art Directors, And Animators",
        "Photographers"
      ) ~ "Visual",
      
      type %in% c(
        "Architects",
        "Landscape Architects"
      ) ~ "Architecture",
      
      type == "Writers And Authors" ~ "Literature",
      
      type %in% c(
        "Musicians",
        "Music Directors And Composers"
      ) ~ "Music",
      
      type == "Dancers And Choreographers" ~ "Dance",
      
      type %in% c(
        "Producers And Directors",
        "Entertainers",
        "Actors",
        "Announcers"
      ) ~ "Performance",
      
      TRUE ~ NA_character_
    ),
    
    art_expression = factor(
      art_expression,
      levels = category_order
    )
  ) %>%
  filter(!is.na(art_expression))

# ------ SHARED CHART THEME ------

clean_theme <- theme_minimal(
  base_family = "body_font",
  base_size = 10
) +
  theme(
    plot.title = element_text(
      family = "title_font",
      face = "bold",
      size = 11,
      hjust = 0.5
    ),
    
    plot.subtitle = element_text(
      size = 8,
      hjust = 0.5
    ),
    
    axis.title = element_text(size = 9),
    
    axis.text = element_text(size = 8),
    
    panel.grid.minor = element_blank(),
    
    plot.background = element_rect(
      fill = "#FAFBFC",
      colour = NA
    ),
    
    panel.background = element_rect(
      fill = "#FAFBFC",
      colour = NA
    )
  )

# ------ CHART 1: TOP 10 JURISDICTIONS ------

state_totals <- artists_cat %>%
  group_by(state) %>%
  summarise(
    total_artists = sum(artists_n, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(total_artists)) %>%
  slice_head(n = 10) %>%
  mutate(
    state_order = reorder(state, total_artists)
  )

plot_states <- ggplot(
  state_totals,
  aes(
    x = state_order,
    y = total_artists
  )
) +
  geom_col(
    fill = "#4776A8",
    width = 0.7
  ) +
  
  geom_text(
    aes(
      label = scales::comma(total_artists)
    ),
    hjust = -0.12,
    size = 2.7,
    family = "body_font"
  ) +
  
  coord_flip() +
  
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(
      mult = c(0, 0.18)
    )
  ) +
  
  labs(
    title = NULL,
    x = NULL,
    y = NULL
  ) +
  
  clean_theme +
  
  theme(
    plot.title = element_blank(),
    
    plot.margin = margin(
      t = 0,
      r = 12,
      b = 8,
      l = 8
    )
  )

# ------ CHART 1 TITLE ------

state_title <- grid::textGrob(
  "Top 10 Jurisdictions by Estimated Asian Artist Count",
  
  gp = grid::gpar(
    fontsize = 11,
    fontface = "bold",
    fontfamily = "title_font",
    col = "#222222"
  )
)

# Chart 1 title and chart in separate sections

state_panel <- gridExtra::arrangeGrob(
  state_title,
  plot_states,
  
  ncol = 1,
  
  heights = c(
    0.08,
    0.92
  )
)

# ------ CHART 2: CATEGORY COMPOSITION, TOP 8 ------

top_8_states <- state_totals %>%
  slice_head(n = 8) %>%
  pull(state)

composition_data <- artists_cat %>%
  filter(state %in% top_8_states) %>%
  group_by(state, art_expression) %>%
  summarise(
    total_artists = sum(artists_n, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    state,
    art_expression,
    fill = list(total_artists = 0)
  ) %>%
  mutate(
    state = factor(
      state,
      levels = top_8_states
    ),
    
    art_expression = factor(
      art_expression,
      levels = category_order
    )
  )

# Stacked bar chart without automatic legend

plot_composition <- ggplot(
  composition_data,
  aes(
    x = state,
    y = total_artists,
    fill = art_expression
  )
) +
  geom_col(width = 0.65) +
  
  scale_fill_manual(
    values = juarez_colours,
    breaks = category_order,
    limits = category_order,
    drop = FALSE
  ) +
  
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(
      mult = c(0, 0.05)
    )
  ) +
  
  labs(
    title = NULL,
    x = NULL,
    y = NULL
  ) +
  
  clean_theme +
  
  theme(
    legend.position = "none",
    
    axis.text.x = element_text(
      angle = 35,
      hjust = 1,
      size = 7
    ),
    
    plot.margin = margin(
      t = 0,
      r = 10,
      b = 8,
      l = 10
    )
  )

# ------ MANUAL LEGEND: COMPACT THREE-COLUMN LAYOUT ------

legend_cell <- function(category, label) {
  
  gridExtra::arrangeGrob(
    
    grid::rectGrob(
      gp = grid::gpar(
        fill = juarez_colours[category],
        col = NA
      ),
      width = unit(0.17, "in"),
      height = unit(0.17, "in")
    ),
    
    grid::textGrob(
      label = label,
      x = unit(0, "npc"),
      y = unit(0.5, "npc"),
      just = c("left", "centre"),
      gp = grid::gpar(
        fontsize = 7.5,
        fontfamily = "body_font",
        col = "#222222",
        lineheight = 1.0
      )
    ),
    
    ncol = 2,
    
    widths = unit.c(
      unit(0.21, "in"),
      unit(1, "null")
    ),
    
    padding = unit(0, "in")
  )
}

legend_items <- list(
  legend_cell(
    "Visual",
    "Visual (Designers, Photographers,\nFine Artists, Art Directors and Animators)"
  ),
  
  legend_cell(
    "Architecture",
    "Architecture (Architects and\nLandscape Architects)"
  ),
  
  legend_cell(
    "Literature",
    "Literature (Writers and Authors)"
  ),
  
  legend_cell(
    "Music",
    "Music (Musicians, Music Directors\nand Composers)"
  ),
  
  legend_cell(
    "Dance",
    "Dance (Dancers and Choreographers)"
  ),
  
  legend_cell(
    "Performance",
    "Performance (Actors, Announcers,\nEntertainers, Producers and Directors)"
  )
)

manual_legend <- gridExtra::arrangeGrob(
  grobs = legend_items,
  ncol = 3,
  nrow = 2,
  
  widths = rep(
    unit(1, "null"),
    3
  ),
  
  heights = unit(
    c(0.30, 0.30),
    "in"
  ),
  
  padding = unit(0.01, "in")
)

# ------ CHART 2 TITLE ------

composition_title <- grid::textGrob(
  "Art-Expression Composition in the Eight Highest-Count Jurisdictions",
  
  gp = grid::gpar(
    fontsize = 11,
    fontface = "bold",
    fontfamily = "title_font",
    col = "#222222"
  )
)

# Chart 2 title, legend and chart

composition_panel <- gridExtra::arrangeGrob(
  composition_title,
  manual_legend,
  plot_composition,
  
  ncol = 1,
  
  heights = c(
    0.08,
    0.12,
    0.80
  )
)

# ------ CHART 3: TOTAL ARTISTS BY CATEGORY ------

category_totals <- artists_cat %>%
  group_by(art_expression) %>%
  summarise(
    total_artists = sum(artists_n, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    art_expression,
    fill = list(total_artists = 0)
  ) %>%
  mutate(
    art_expression = factor(
      art_expression,
      levels = category_order
    ),
    
    category_label = factor(
      as.character(art_expression),
      levels = rev(category_order)
    )
  )

bottom_labels <- c(
  "Visual" =
    "Visual (Designers, Photographers,\nFine Artists, Art Directors and Animators)",
  
  "Architecture" =
    "Architecture (Architects and\nLandscape Architects)",
  
  "Literature" =
    "Literature (Writers and Authors)",
  
  "Music" =
    "Music (Musicians, Music Directors\nand Composers)",
  
  "Dance" =
    "Dance (Dancers and Choreographers)",
  
  "Performance" =
    "Performance (Actors, Announcers,\nEntertainers, Producers and Directors)"
)

plot_categories <- ggplot(
  category_totals,
  aes(
    x = category_label,
    y = total_artists,
    fill = art_expression
  )
) +
  geom_col(
    width = 0.65,
    show.legend = FALSE
  ) +
  
  geom_text(
    aes(
      label = scales::comma(total_artists)
    ),
    hjust = -0.12,
    size = 2.7,
    family = "body_font"
  ) +
  
  coord_flip(clip = "off") +
  
  scale_fill_manual(
    values = juarez_colours,
    drop = FALSE
  ) +
  
  scale_x_discrete(
    labels = function(x) {
      unname(
        bottom_labels[as.character(x)]
      )
    }
  ) +
  
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(
      mult = c(0, 0.18)
    )
  ) +
  
  labs(
    title = "Summed Estimated Asian Artists by Category",
    x = NULL,
    y = NULL
  ) +
  
  clean_theme +
  
  theme(
    plot.title = element_text(
      size = 10,
      hjust = 0.5,
      margin = margin(b = 8)
    ),
    
    axis.text.y = element_text(
      size = 7,
      lineheight = 1.1,
      hjust = 1,
      margin = margin(r = 22)
    ),
    
    plot.margin = margin(
      t = 8,
      r = 20,
      b = 8,
      l = 85
    )
  )

# ------ COMBINE CHARTS ------

combined_plot <- gridExtra::arrangeGrob(
  state_panel,
  composition_panel,
  plot_categories,
  
  layout_matrix = rbind(
    c(1, 2),
    c(3, 3)
  ),
  
  widths = c(1, 1),
  
  heights = c(
    1.7,
    0.7
  ),
  
  top = grid::textGrob(
    "ASIAN ARTISTS IN THE USA",
    
    gp = grid::gpar(
      fontsize = 15,
      fontface = "bold",
      fontfamily = "title_font",
      col = "#263746"
    )
  ),
  
  padding = unit(0.6, "line")
)

# ------ DISPLAY CHART ------

grid::grid.newpage()
grid::grid.draw(combined_plot)

# ------ SAVE PNG ONLY ------

png_path <- file.path(
  output_dir,
  "asian_artist_analysis.png"
)

ggsave(
  filename = png_path,
  plot = combined_plot,
  width = 16,
  height = 10,
  units = "in",
  dpi = 300,
  bg = "#FAFBFC",
  limitsize = FALSE
)

# ------ OUTPUT SUMMARY ------

cat(
  "\nSaved PNG:",
  normalizePath(
    png_path,
    mustWork = FALSE
  ),
  "\n"
)

cat("\nCategory totals:\n")

print(category_totals)
