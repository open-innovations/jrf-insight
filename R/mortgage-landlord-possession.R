# https://www.gov.uk/government/collections/mortgage-and-landlord-possession-statistics

collection_url <- "https://www.gov.uk/government/collections/mortgage-and-landlord-possession-statistics"

links <- rvest::read_html(collection_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

links_to_follow <- links[grepl("mortgage-and-landlord-possession-statistics", links)]

# grab the first one
page <- rvest::read_html(paste0("https://www.gov.uk", links_to_follow[1])) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

file_to_grab <- page[grepl(".zip", page)] |>
  unique()

folder <- 'data-raw/mortgage-landlord-possession'
local_zip_path <- file.path(folder, basename(file_to_grab))

download.file(file_to_grab, local_zip_path, mode = "wb")

zips <- list.files(folder, pattern = '*.zip', full.names = TRUE)

lapply(zips, function(file) {
  all_files <- unzip(file, list = TRUE, junkpaths = TRUE)
  files_to_unzip <- all_files$Name[grepl('LA', all_files$Name)]
  unzip(zips, files = files_to_unzip, exdir = folder)
})

file <- list.files(folder, pattern = ".csv",
                   full.names = TRUE)

possession <- readr::read_csv(file) |>
  tidyr::unite('date', year:quarter, sep = " ") |>
  dplyr::select(date,
                geography_code = la_code,
                geography_name = local_authority,
                possession_type,
                possession_action,
                value)

readr::write_csv(possession, 'data/mortgage-landlord-possession/mortgage-landlord-possession.csv')
arrow::write_parquet(possession, 'data-mart/mortgage-landlord-possession/mortgage-landlord-possession.parquet')
