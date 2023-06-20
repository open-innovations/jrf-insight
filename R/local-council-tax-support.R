# collection at https://www.gov.uk/government/statistical-data-sets/live-tables-on-local-government-finance#local-council-tax-support

local_ct_support_file <- list.files('data-raw/council-tax-support',
                                    full.names = TRUE)
sheets <- readODS::list_ods_sheets(local_ct_support_file)
sheets <- sheets[grepl('Table_[23]', sheets)] |>
  setNames(c('pensioners', 'working_age'))

local_ct_support <- lapply(sheets, function(sht) {
  readODS::read_ods(local_ct_support_file, sheet = sht,
                    skip = 3, na = c('-', '[x]', '[z]', '....')
  ) |>
    dplyr::select(-dplyr::contains('Percentage'),
                  -Notes) |>
    tidyr::pivot_longer(-(1:5), names_to = 'date') |>
    dplyr::mutate(date = substr(date, 7, nchar(date) - 5) |>
                    as.Date(format = "%d %B %Y")) |>
    dplyr::rename(geography_code.ba = `E-code`,
                  geography_code = `ONS Code`,
                  geography_name = `Local Authority`,
                  geography_type = Class)
}) |>
  dplyr::bind_rows(.id = 'variable_code') |>
  dplyr::mutate(variable_name = variable_code) |>
  dplyr::select(date, dplyr::starts_with('geography'),
                variable_code, variable_name,
                value)

source(url('https://raw.githubusercontent.com/economic-analytics/edd/main/R/build-nomis-datasets.R'))
source(url('https://raw.githubusercontent.com/economic-analytics/edd/main/R/utils-date-formats.R'))

out <- local_ct_support |>
  df_to_edd_df() |>
  edd_df_to_edd_obj()

readr::write_csv(local_ct_support, 'data/council-tax-support/council-tax-support.csv')
saveRDS(out, 'data/council-tax-support/council-tax-support.rds')
