# https://www.gov.uk/government/statistical-data-sets/live-tables-on-homelessness

# full collection: https://www.gov.uk/government/collections/homelessness-statistics

collection_url <- "https://www.gov.uk/government/statistical-data-sets/live-tables-on-homelessness"

links <- rvest::read_html(collection_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

file_urls <- links[grepl("Detailed_LA_[0-9]{6}.*.ods$", links)]

most_recent_period <- stringr::str_extract(file_urls, "_[0-9]{6}") |> max() |> substr(2, 10)

most_recent_urls <- file_urls[grepl(most_recent_period, file_urls)] |>
  unique()

if (length(most_recent_urls) > 1) {
  url_to_use <- most_recent_urls[grepl("revised", most_recent_urls)]
} else {
  url_to_use <- most_recent_urls
}

if (length(url_to_use) > 1) {
  url_to_use <- url_to_use[grepl("updated", url_to_use, ignore.case = TRUE)]
}



homelessness_path <- file.path("data-raw", "statutory-homelessness", basename(url_to_use))

download.file(url_to_use,
              homelessness_path,
              mode = "wb")

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
  dplyr::mutate(date = paste(substr(most_recent_period, 1, 4),
                             substr(most_recent_period, 5, 6),
                             sep = "-")
                , .before = 1)

readr::write_csv(homelessness_data, "data/statutory-homelessness/statutory-homelessness.csv")
arrow::write_parquet(homelessness_data, "data-mart/statutory-homelessness/statutory-homelessness.parquet")

