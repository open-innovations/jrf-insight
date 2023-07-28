# https://www.gov.uk/government/statistical-data-sets/live-tables-on-homelessness

# full collection: https://www.gov.uk/government/collections/homelessness-statistics

homelessness_path <- "data-raw/statutory-homelessness/Detailed_LA_202303.ods"

source("https://raw.githubusercontent.com/ChristianSpence/Fixing-column-headers/main/merge_column_names.R")

homelessness_data <- readODS::read_ods(homelessness_path, sheet = "A1")

h2 <- merge_column_names(homelessness_data, 1:6)

h3 <- h2 |>
  dplyr::select(1, 2, 5) |>
  dplyr::filter(grepl("[A-Z][0-9]{8}", geography_code))

readr::write_csv(h3, "data/statutory-homelessness/statutory-homelessness.csv")
