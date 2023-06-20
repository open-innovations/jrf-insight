# https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019

imd_file <- list.files('data-raw/imd', full.names = TRUE)

imd <- readr::read_csv(imd_file) |>
  tidyr::pivot_longer(-(1:4), 'variable') |>
  dplyr::mutate(domain = substr(variable, 1, regexpr('Score|Rank|Decile', variable) - 2)) |>
  dplyr::mutate(domain = ifelse(domain == "", "Population data", domain)) |>
  dplyr::mutate(variable = substr(variable, regexpr('Score|Rank|Decile', variable), nchar(variable))) |>
  dplyr::mutate(date = "2019",
                geography_type = 'lsoa11') |>
  dplyr::select(date,
                geography_code = `LSOA code (2011)`,
                geography_name = `LSOA name (2011)`,
                geography_type,
                domain,
                variable,
                value)

