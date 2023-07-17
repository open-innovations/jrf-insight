# labour-market

nomis_url <- 'https://www.nomisweb.co.uk/api/v01/dataset/NM_17_5.data.csv?geography=1811939329...1811939332,1811939334...1811939336,1811939338...1811939402,1807745025...1807745028,1807745030...1807745032,1807745034...1807745076,2013265921...2013265923&variable=18,84,111&measures=20599,21001,21002,21003&signature=NPK-80b58859b490b5cdc78ea9:0xc58d0c604c4e93d6543f538a0c822a2568a82439'

labour_market <- readr::read_csv(nomis_url)

lm <- labour_market |>
  setNames(tolower(names(labour_market))) |>
  dplyr::select(date,
                geography_code, geography_name,
                variable_code, variable_name,
                measures_name,
                value = obs_value) |>
  dplyr::distinct() |> # lower tier will have duplicated
  dplyr::mutate(date = as.Date(paste0(date, '-01'))) |>
  dplyr::filter(measures_name == 'Variable',
                date == max(date)) |>
  dplyr::select(-measures_name)

readr::write_csv(lm, 'data/labour-market/labour-market.csv')


# tidyr::pivot_wider(names_from = measures_name, values_from = value)
