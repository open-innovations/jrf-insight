# https://www.gov.uk/government/collections/individual-insolvency-statistics-releases

# https://www.gov.uk/government/statistics/individual-insolvencies-by-location-age-and-gender-england-and-wales-2022


collection_url <- "https://www.gov.uk/government/collections/individual-insolvency-statistics-releases"

links <- rvest::read_html(collection_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

target_link <- links[grepl("individual-insolvencies-by-location", links)]

most_recent <- stringr::str_extract(target_link, "[0-9]{4}")
latest_date <- which(most_recent == max(most_recent))

most_recent_link <- target_link[latest_date]

next_url <- paste0("https://www.gov.uk", most_recent_link)

target_page <- rvest::read_html(next_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href") |>
  unique()

files_to_download <- target_page[grepl("by_Location__England.*.xlsx$|Ward.*.csv$", target_page)]
files_to_download <- files_to_download[!grepl("Metadata", files_to_download)]

lapply(files_to_download, function(x) {
  download.file(x,
                file.path("data-raw", "individual-insolvencies", basename(x)),
                mode = "wb")
})




insolvencies_la_file <- list.files('data-raw/individual-insolvencies',
                                   pattern = "Location",
                                   full.names = TRUE)

sheets <- readxl::excel_sheets(insolvencies_la_file)
sheets <- sheets[grepl('Table', sheets)] |>
  setNames(paste(
    c(
      rep('Total insolvencies', 2),
      rep('Bankruptcies', 2),
      rep('Debt relief orders', 2),
      rep('Individual voluntary arrangements', 2),
      rep('Breathing spaces', 2)
    ),
    c('',
      'rate per 10,000 adults')
  ) |>
    trimws()
  )

insolvencies_la <- lapply(sheets, function(sht) {
  x <- readxl::read_excel(insolvencies_la_file, sheet = sht, skip = 4)

  if ('Revisions from 2021 publication' %in% names(x)) {
    x <- x |>
      dplyr::select(-`Revisions from 2021 publication`)
  }

  names(x) <- names(x) |>
    stringr::str_remove(stringr::fixed(' [note 3]')) |>
    stringr::str_remove(stringr::fixed(' [p]'))

  return(x)
}) |>
  dplyr::bind_rows(.id = 'variable') |>
  tidyr::pivot_longer(-(1:4), names_to = 'date') |>
  dplyr::select(date,
                geography_code = Code,
                geography_name = Name,
                geography_type = Geography,
                variable,
                value)

insolvencies_ward_file <- list.files('data-raw/individual-insolvencies',
                                     pattern = "Ward",
                                     full.names = TRUE)

insolvencies_ward <- readr::read_csv(insolvencies_ward_file)

dtypes <- sapply(insolvencies_ward, \(x) class(x))
numeric_cols <- names(dtypes[dtypes == "numeric"])

insolvencies_ward <- insolvencies_ward |>
  tidyr::pivot_longer(dplyr::all_of(numeric_cols), names_to = 'date') |>
  dplyr::mutate(geography_type = 'ward') |>
  dplyr::select(date,
                geography_code = ward_code,
                geography_name = ward_name,
                geography_type,
                variable = insolvency_type,
                value)

insolvencies <- dplyr::bind_rows(insolvencies_la,
                                 insolvencies_ward)

readr::write_csv(insolvencies, "data/insolvencies/insolvencies.csv")
arrow::write_parquet(insolvencies, "data-mart/insolvencies/insolvencies.parquet")
