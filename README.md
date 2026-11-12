# Asian Artists in the USA — TidyTuesday Analysis

An R-based data analysis and visualization project exploring the geographic distribution and occupational composition of Asian artists across the United States.

This project is a **replication and extension** of the TidyTuesday Week 39 (2022) Artists in the Workforce analysis. It uses the publicly available TidyTuesday dataset and creates additional comparative visualizations.

## Project Overview

The analysis filters the dataset for workers identified as Asian and groups selected occupations into six broad art-expression categories:

- **Visual** — Designers, Photographers, Fine Artists, Art Directors and Animators
- **Architecture** — Architects and Landscape Architects
- **Literature** — Writers and Authors
- **Music** — Musicians, Music Directors and Composers
- **Dance** — Dancers and Choreographers
- **Performance** — Actors, Announcers, Entertainers, Producers and Directors

The project focuses on:
1. The ten U.S. jurisdictions with the highest estimated Asian artist counts.
2. The art-expression composition across the eight highest-count jurisdictions.
3. Estimated Asian artist totals across the six art-expression categories.
4. A polar visualization of the distribution of Asian artists by art-expression category and jurisdiction.

> **Data interpretation:** The values in this project are estimates from the source dataset. They should not be interpreted as exact headcounts or as a complete census of all Asian artists in the United States.

## Repository Structure

```text
tidytuesday-asian-artists-analysis/
│
├── Code/
│   ├── Other_charts.R
│   └── Polar_Chart.R
│
├── Output/
│   ├── asian_artist_analysis.png
│   └── polar_stacked_chart.png
│
├── README.md
└── requirements.txt
```

## Visualizations

### 1. Comparative Analysis

The script `Code/Other_charts.R` generates a combined visualization containing:
- Top 10 jurisdictions by estimated Asian artist count.
- Art-expression composition in the eight highest-count jurisdictions.
- Summed estimated Asian artist totals by category.

Output: `Output/asian_artist_analysis.png`

### 2. Polar Stacked Chart

The script `Code/Polar_Chart.R` generates a polar chart showing the distribution of Asian artists across U.S. jurisdictions and art-expression categories.

Output: `Output/polar_stacked_chart.png`

## Dataset

**Source:** TidyTuesday — Artists in the Workforce, Week 39 (2022)

**CSV file:**  
https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-09-27/artists.csv

The R scripts read the CSV directly from this public URL. A separate local dataset download is not required to run the analysis, provided an internet connection is available.

## Requirements

The project uses R and the packages listed in `requirements.txt`.

Main packages include:
- `tidyverse`
- `MetBrewer`
- `showtext`
- `sysfonts`
- `gridExtra`
- `scales`
- `ggtext`
- `geomtextpath`
- `showtextdb`

### Install dependencies

Run the following in R from the repository's root directory:

```r
packages <- readLines("requirements.txt")
packages <- trimws(packages)
packages <- packages[nzchar(packages) & !startsWith(packages, "#")]
install.packages(packages)
```

The scripts also contain package checks and install missing packages when they are run.

## How to Run

1. Clone or download this repository.
2. Open the project folder in RStudio or set it as the working directory in R.
3. Ensure that R and the required packages are installed.
4. Run `Code/Other_charts.R` to generate the comparative visualization.
5. Run `Code/Polar_Chart.R` to generate the polar visualization.
6. Find the generated PNG files in the `Output/` folder.

The scripts create the `Output/` directory if it does not already exist (for the combined chart script; the polar script should also be configured to create it before saving).

## Acknowledgements and Attribution

This project is a replication and extension of the TidyTuesday Week 39 (2022) Artists in the USA analysis.

**Original visualization:** Isaac Arroyo  
https://github.com/isaacarroyov/tidy_tuesday_R/blob/main/gallery_2022/images/2022_week-39_artists-in-usa.png

The original work is acknowledged as the inspiration/source implementation. This repository adapts and extends the analysis with additional occupational grouping, jurisdiction-level aggregation, comparative charts and a supplementary polar visualization.

**Dataset:** TidyTuesday / R for Data Science  
https://github.com/rfordatascience/tidytuesday

## Limitations

- The analysis is based on the occupations and estimates available in the source dataset. The charts describe the selected dataset and should not be treated as a complete representation of every Asian artist in the United States.
- The six art-expression categories are mere groupings created for this project; they are not necessarily official classifications used by the dataset publisher.

## Reproducibility

The source R scripts, package list and generated visualizations are included in this repository. The dataset is loaded from the public TidyTuesday CSV URL at runtime.

---

*Created as an R data analysis and visualization project*
