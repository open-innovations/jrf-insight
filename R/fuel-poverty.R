# full collection is here: https://www.gov.uk/government/collections/fuel-poverty-statistics

fuel_poverty_file <- "data-raw/fuel-poverty/sub-regional-fuel-poverty-2022-tables.xlsx"

geography_code_name_only <- readr::read_csv("data/geo/geography_code_name_only.csv")

fuel_poverty <- readxl::read_excel(fuel_poverty_file, sheet = "Table 2", skip = 2) |>
  dplyr::filter(!is.na(`Number of households`)) |>
  dplyr::mutate(date = "2022") |>
  dplyr::mutate(`Area names` = dplyr::coalesce(`Area names`, `...3`, `...4`)) |>
  dplyr::mutate(`Proportion of households fuel poor (%)` =
                  as.numeric(`Proportion of households fuel poor (%)`)) |>
  dplyr::select(date,
                geography_code = `Area Codes`,
                geography_name = `Area names`,
                `Number of households`,
                `Number of households in fuel poverty`,
                `Proportion of households fuel poor (%)`) |>
  tidyr::pivot_longer(4:6, names_to = "variable_name") |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)

fuel_poverty_lsoa <- readxl::read_excel(fuel_poverty_file, sheet = "Table 3", skip = 2, guess_max = Inf) |>
  dplyr::filter(!is.na(`Number of households`)) |>
  dplyr::mutate(date = "2022") |>
  dplyr::mutate(`Proportion of households fuel poor (%)` =
                  as.numeric(`Proportion of households fuel poor (%)`)) |>
  dplyr::select(date,
                lsoa_code = `LSOA Code`,
                `Number of households`,
                `Number of households in fuel poverty`,
                `Proportion of households fuel poor (%)`)

LSOA11_WD21_LAD21_EW_LU_V2 <- readxl::read_excel("~/Data/Geodata/Lookups/LSOA11_WD21_LAD21_EW_LU_V2.xlsx") |>
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
