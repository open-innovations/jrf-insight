# house-prices



# download ----------------------------------------------------------------

# wards
hpssa_ward_url <- "https://www.ons.gov.uk/peoplepopulationandcommunity/housing/datasets/medianpricepaidbywardhpssadataset37"

hpssa_ward_links <- rvest::read_html(hpssa_ward_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

# use the first (i.e. most recent) .zip link
hpssa_ward_zip <- hpssa_ward_links[grepl(".zip$", hpssa_ward_links)][1]

hpssa_ward_path <- file.path("data-raw", "house-prices", basename(hpssa_ward_zip))

download.file(paste0("http://ons.gov.uk", hpssa_ward_zip),
              hpssa_ward_path, mode = "wb")

unzip(hpssa_ward_path, exdir = "data-raw/house-prices")


# admin geographies
hpssa_admin_url <- "https://www.ons.gov.uk/peoplepopulationandcommunity/housing/datasets/medianhousepricefornationalandsubnationalgeographiesquarterlyrollingyearhpssadataset09"

hpssa_admin_links <- rvest::read_html(hpssa_admin_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

# use the .xls link
hpssa_admin_xls <- hpssa_admin_links[grepl(".xls[x]*$", hpssa_admin_links)]

hpssa_admin_path <- file.path("data-raw", "house-prices", basename(hpssa_admin_xls))

download.file(paste0("http://ons.gov.uk", hpssa_admin_xls),
              hpssa_admin_path, mode = "wb")

# process -----------------------------------------------------------------

geography_code_name_only <- readr::read_csv("data/geo/geography_code_name_only.csv")

hpssa_ward <- readxl::read_excel("data-raw/house-prices/HPSSA Dataset 37 - Median price paid by ward.xls", sheet = "1a", skip = 5, na = ":") |>
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
arrow::write_parquet(hpssa, "data-mart/house-prices/house-prices.parquet")
