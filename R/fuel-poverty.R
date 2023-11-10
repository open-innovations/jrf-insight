# full collection is here: https://www.gov.uk/government/collections/fuel-poverty-statistics


# download file -----------------------------------------------------------

collection_url <- "https://www.gov.uk/government/collections/fuel-poverty-statistics"

links <- rvest::read_html(collection_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

sub_regional_links <- links[grepl("sub-regional-fuel-poverty-data", links)]

sub_regional_links_years <- stringr::str_extract_all(sub_regional_links, "[0-9]{4}") |>
  lapply(function(x) max(x)) |>
  unlist()
latest_link <- which(sub_regional_links_years == max(sub_regional_links_years))

link_to_follow <- paste0("https://www.gov.uk", sub_regional_links[latest_link])

target_page <- rvest::read_html(link_to_follow) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

target_excel <- target_page[grepl(".xlsx$", target_page)] |>
  unique() # because text and img are both <a>

# extract lowest year from file path to use in data
data_year <- stringr::str_extract_all(target_excel, "[0-9]{4}") |>
  unlist()
data_year <- data_year[data_year > "2000"] |> min()

local_path <- file.path("data-raw", "fuel-poverty", basename(target_excel))

download.file(target_excel, local_path, mode = "wb")

# process file ------------------------------------------------------------

fuel_poverty_file <- local_path

geography_code_name_only <- readr::read_csv("data/geo/geography_code_name_only.csv")

source("R/utils-build-higher-geographies.R")

fuel_poverty <- readxl::read_excel(fuel_poverty_file, sheet = "Table 2", skip = 2) |>
  dplyr::filter(!is.na(`Number of households`)) |>
  dplyr::mutate(date = data_year) |>
  dplyr::mutate(`Area names` = dplyr::coalesce(`Area names`, `...3`, `...4`)) |>
  dplyr::mutate(`Proportion of households fuel poor (%)` =
                  as.numeric(`Proportion of households fuel poor (%)`)) |>
  dplyr::select(date,
                geography_code = `Area Codes [Note 4]`,
                geography_name = `Area names`,
                `Number of households`,
                `Number of households in fuel poverty`,
                `Proportion of households fuel poor (%)`) |>
  tidyr::pivot_longer(4:6, names_to = "variable_name") |>
  dplyr::filter(geography_code %in% geography_code_name_only$code) |>
  build_higher_geogs() |>
  # rewrite the ratios column because it's been summed by build_higher_geogs()
  tidyr::pivot_wider(names_from = "variable_name") |>
  dplyr::mutate(`Proportion of households fuel poor (%)` =
                  `Number of households in fuel poverty` /
                  `Number of households` * 100) |>
  tidyr::pivot_longer(cols = dplyr::where(is.numeric),
                      names_to = "variable_name")


fuel_poverty_lsoa <- readxl::read_excel(fuel_poverty_file, sheet = "Table 3", skip = 2, guess_max = Inf) |>
  dplyr::filter(!is.na(`Number of households`)) |>
  dplyr::mutate(date = data_year) |>
  dplyr::mutate(`Proportion of households fuel poor (%)` =
                  as.numeric(`Proportion of households fuel poor (%)`)) |>
  dplyr::select(date,
                lsoa_code = `LSOA Code`,
                `Number of households`,
                `Number of households in fuel poverty`,
                `Proportion of households fuel poor (%)`)

LSOA11_WD21_LAD21_EW_LU_V2 <- readxl::read_excel("data/geo/LSOA11_WD21_LAD21_EW_LU_V2.xlsx") |>
  dplyr::select(LSOA11CD, WD21CD, WD21NM) |>
  dplyr::distinct()

fuel_poverty_ward <- dplyr::left_join(fuel_poverty_lsoa,
                                      LSOA11_WD21_LAD21_EW_LU_V2,
                                      by = c("lsoa_code" = "LSOA11CD")) |>
  dplyr::group_by(date, WD21CD, WD21NM) |>
  dplyr::summarise(`Number of households` = sum(`Number of households`),
                   `Number of households in fuel poverty` = sum(`Number of households in fuel poverty`)) |>
  dplyr::mutate(`Proportion of households fuel poor (%)` =
                  `Number of households in fuel poverty` /
                  `Number of households` * 100) |>
  dplyr::rename(geography_code = WD21CD,
                geography_name = WD21NM) |>
  tidyr::pivot_longer(4:6, names_to = "variable_name") |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)

fuel_poverty_final <- dplyr::bind_rows(fuel_poverty, fuel_poverty_ward)

readr::write_csv(fuel_poverty_final, "data/fuel-poverty/fuel-poverty.csv")
arrow::write_parquet(fuel_poverty_final, "data-mart/fuel-poverty/fuel-poverty.parquet")
