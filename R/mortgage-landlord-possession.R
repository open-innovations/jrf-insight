# https://www.gov.uk/government/collections/mortgage-and-landlord-possession-statistics

folder <- 'data-raw/mortgage-landlord-possession'
zips <- list.files(folder, pattern = '*.zip', full.names = TRUE)

lapply(zips, function(file) {
  all_files <- unzip(file, list = TRUE, junkpaths = TRUE)
  files_to_unzip <- all_files$Name[grepl('LA', all_files$Name)]
  unzip(zips, files = files_to_unzip, exdir = folder)
})

file <- list.files(folder, pattern = ".csv",
                   full.names = TRUE, recursive = TRUE)

possession <- readr::read_csv(file) |>
  tidyr::unite('date', year:quarter, sep = " ") |>
  dplyr::select(date,
                geography_code = la_code,
                geography_name = local_authority,
                possession_type,
                possession_action,
                value)
