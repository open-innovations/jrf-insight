# collection at https://www.gov.uk/government/statistical-data-sets/live-tables-on-local-government-finance#local-council-tax-support

collection_url <- "https://www.gov.uk/government/statistical-data-sets/live-tables-on-local-government-finance"

links <- rvest::read_html(collection_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

target_file <- links[grepl("Local_Council_Tax_Support", links)] |>
  unique()

file_path <- file.path("data-raw", "council-tax-support", basename(target_file))
download.file(target_file,
              file_path,
              mode = "wb")

local_ct_support_file <- file_path
sheets <- readODS::list_ods_sheets(local_ct_support_file)
sheets <- sheets[grepl('Table_[23]', sheets)] |>
  setNames(c('pensioners', 'working_age'))

local_ct_support <- lapply(sheets, function(sht) {
  x <- readODS::read_ods(local_ct_support_file, sheet = sht,
                    skip = 3, na = c('-', '[x]', '[z]', '....')
  )

  names(x) <- stringr::str_replace_all(names(x), "\\.", " ")
  x <- x |>
    dplyr::select(-dplyr::contains('Percentage'), -Notes) |>
    tidyr::pivot_longer(-(1:5), names_to = 'date') |>
    dplyr::mutate(date = substr(date, 7, nchar(date) - 5) |>
                    as.Date(format = "%d %B %Y")) |>
    dplyr::rename(geography_code.ba = `E code`,
                  geography_code = `ONS Code`,
                  geography_name = `Local Authority`,
                  geography_type = Class)
}) |>
  dplyr::bind_rows(.id = 'variable_code') |>
  dplyr::mutate(variable_name = variable_code) |>
  dplyr::select(date, dplyr::starts_with('geography'),
                variable_code, variable_name,
                value)

readr::write_csv(local_ct_support, 'data/council-tax-support/council-tax-support.csv')
arrow::write_parquet(local_ct_support, 'data-mart/council-tax-support/council-tax-support.parquet')
