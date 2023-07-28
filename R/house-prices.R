# house-prices

geography_code_name_only <- readr::read_csv("data/geo/geography_code_name_only.csv")

hpssa_ward <- readxl::read_excel("data-raw/house-prices/hpssadataset37medianpricepaidbyward/HPSSA Dataset 37 - Median price paid by ward.xls", sheet = "1a", skip = 5, na = ":") |>
  dplyr::select(-(1:2)) |>
  dplyr::rename(geography_code = `Ward code`,
                geography_name = `Ward name`) |>
  tidyr::pivot_longer(-c(geography_code, geography_name), names_to = "date") |>
  dplyr::mutate(variable_name = "Median house price") |>
  dplyr::mutate(date = as.Date(sub("Year ending ", "01 ", date), format = "%d %b %Y")) |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)

sheets <- c("1a", "2a", "3a")

hpssa_admin <- lapply(sheets, function(sht) {
  x <- readxl::read_excel("data-raw/house-prices/hpssadataset9medianpricepaidforadministrativegeographies.xls", sheet = sht, skip = 5, na = ":")

  if (sht != "1a") {
    x <- x |>
      dplyr::select(-(1:2))
  }

  x |>
    dplyr::rename(geography_code = 1,
                  geography_name = 2) |>
    tidyr::pivot_longer(-c(geography_code, geography_name), names_to = "date") |>
    dplyr::mutate(variable_name = "Median house price") |>
    dplyr::mutate(date = as.Date(sub("Year ending ", "01 ", date), format = "%d %b %Y"))
}) |>
  dplyr::bind_rows() |>
  dplyr::distinct() |> # dupes from UTLA and LTLA
  dplyr::filter(geography_code %in% geography_code_name_only$code)

hpssa <- dplyr::bind_rows(hpssa_ward,
                          hpssa_admin)

readr::write_csv(hpssa, "data/house-prices/house-prices.csv")
