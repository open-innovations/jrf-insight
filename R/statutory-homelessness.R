# https://www.gov.uk/government/statistical-data-sets/live-tables-on-homelessness

# full collection: https://www.gov.uk/government/collections/homelessness-statistics

homelessness_path <- "data-raw/statutory-homelessness/Detailed_LA_202303.ods"

homelessness_cols <- c("geography_code",
                       "geography_name",
                       "X3",
                       "X4",
                       "Total number of households assessed",
                       "X6",
                       "Total households assessed as owed a duty",
                       "Threatened with homelessness",
                       "Threatened with homelessness (Section 21)",
                       "Homeless - relief duty owed",
                       "X11",
                       "No duty owed",
                       "X13",
                       "Number of households in area (000s)",
                       "Households assessed as threatened with homelessness per (000s)",
                       "Households assessed as homeless per (000s)"
                       )

homelessness_data <- readODS::read_ods(homelessness_path, sheet = "A1", skip = 7, col_names = FALSE, na = "..") |>
  setNames(homelessness_cols) |>
  dplyr::select(-(dplyr::starts_with("X"))) |>
  dplyr::filter(grepl("[A-Z][0-9]{8}", geography_code)) |>
  tidyr::pivot_longer(-c(geography_code, geography_name), names_to = "variable_name") |>
  dplyr::filter(variable_name == "Total households assessed as owed a duty") |>
  dplyr::mutate(date = "2023 Q1", .before = 1)

readr::write_csv(homelessness_data, "data/statutory-homelessness/statutory-homelessness.csv")
