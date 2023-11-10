# labour-market

nomis_url <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_17_5.data.csv?geography=2013265921...2013265923,1811939329...1811939332,1811939334...1811939336,1811939338...1811939402,1807745025...1807745028,1807745030...1807745032,1807745034...1807745076,1853882374,1853882378,1853882379,1853882369,1853882372,1853882370,1853882371&variable=18,84,111&measures=20599,21001,21002,21003&signature=NPK-80b58859b490b5cdc78ea9:0xbe7e4762c50a58ff245bb0d58111b1ddcaff5fea"

labour_market <- readr::read_csv(nomis_url)

source("R/utils-build-higher-geographies.R")

lm <- labour_market |>
  setNames(tolower(names(labour_market))) |>
  dplyr::select(date,
                geography_code, geography_name,
                variable_name,
                measures_name,
                value = obs_value) |>
  dplyr::distinct() |> # lower tier will have duplicated
  dplyr::mutate(date = as.Date(paste0(date, '-01')))

lm_north <- lm |>
  build_the_north() |>
  tidyr::pivot_wider(names_from = measures_name) |>
  dplyr::mutate(Variable = round(Numerator / Denominator * 100, 1)) |>
  dplyr::select(-Confidence) |>
  tidyr::pivot_longer(dplyr::where(is.numeric), names_to = "measures_name")

lm_out <- dplyr::bind_rows(lm, lm_north) |>
  dplyr::filter(measures_name == 'Variable') |>
  dplyr::select(-measures_name)

readr::write_csv(lm_out, 'data/labour-market/labour-market.csv')
arrow::write_parquet(lm_out, 'data-mart/labour-market/labour-market.parquet')
