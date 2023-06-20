# full collection

url <- 'https://www.ons.gov.uk/peoplepopulationandcommunity/housing/datasets/privaterentalmarketsummarystatisticsinengland'

rental_prices_file <- 'data-raw/rental-prices/privaterentalmarketstatistics221214.xlsx'

sheets <- readxl::excel_sheets(rental_prices_file)
sheets <- sheets[grepl("2.", sheets)]
names(sheets) <- c('room', 'studio', 'bed1', 'bed2', 'bed3', 'bed4plus', 'total')

rental_prices <- lapply(sheets, function(sht) {
  readxl::read_excel(rental_prices_file, sheet = sht,
                     skip = 6, na = c("NA", '-', '.', '..')
  ) |>
    dplyr::filter(!is.na(`Area Code1`),
                  # if count == 0, there is no data in any other columns
                  `Count of rents` != 0)
}) |>
  dplyr::bind_rows(.id = "property_code") |>
  dplyr::rename(geography_code.ba = `LA Code1`,
                geography_code = `Area Code1`,
                geography_name = Area) |>
  tidyr::pivot_longer(-(property_code:geography_name),
                      names_to = "variable_code",
                      values_drop_na = TRUE) |>
  dplyr::mutate(date = "2022 Q3",
                property_name = property_code,
                variable_name = variable_code)

# if you want the whole time series ...
# links <- rvest::read_html(url) |>
#   rvest::html_elements("a") |>
#   rvest::html_attr("href")
# links <- links[grepl(".xls", links)]
# links <- paste0('https://www.ons.gov.uk', links)


source(url('https://raw.githubusercontent.com/economic-analytics/edd/main/R/build-nomis-datasets.R'))
source(url('https://raw.githubusercontent.com/economic-analytics/edd/main/R/utils-date-formats.R'))

out <- rental_prices |>
  df_to_edd_df() |>
  edd_df_to_edd_obj()

readr::write_csv(rental_prices, 'data/rental-prices/rental-prices.csv')
saveRDS(out, 'data/rental-prices/rental-prices.rds')
