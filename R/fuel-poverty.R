# full collection is here: https://www.gov.uk/government/collections/fuel-poverty-statistics

fuel_poverty_file <- "data-raw/fuel-poverty/sub-regional-fuel-poverty-2022-tables.xlsx"

sheets <- readxl::excel_sheets(fuel_poverty_file)
sheets <- sheets[grepl("Table [23]", sheets)]

fuel_poverty <- lapply(sheets, function(sht){
  x <- readxl::read_excel(fuel_poverty_file, sheet = sht, skip = 2) |>
    dplyr::filter(!is.na(`Number of households`))

  if (sht == "Table 2") {
    x <- x |>
      dplyr::mutate(`Area type` = dplyr::case_when(
        !is.na(`Area names`) ~ "rgn",
        !is.na(`...3`) ~ "cty",
        !is.na(`...4`) ~ "lad"
      ),
      .before = `Number of households`) |>
      dplyr::mutate(`Area names` = dplyr::coalesce(`Area names`, `...3`, `...4`)) |>
      dplyr::select(-c(`...3`, `...4`)) |>
      dplyr::mutate(`Proportion of households fuel poor (%)` =
                      as.numeric(`Proportion of households fuel poor (%)`)) |>
      dplyr::rename(geography_code = `Area Codes`,
                    geography_name = `Area names`,
                    geography_type = `Area type`)
  }

  if (sht == "Table 3") {
    x <- x |>
      dplyr::select(-c(`LA Code`, `LA Name`, Region)) |>
      dplyr::rename(geography_code = `LSOA Code`,
                    geography_name = `LSOA Name`) |>
      dplyr::mutate(geography_type = 'lsoa', .after = 'geography_name')
  }

  x <- x |>
    tidyr::pivot_longer(!dplyr::starts_with('geography'),
                        names_to = "variable")
  return(x)
}) |>
  setNames(c('rgn-la', 'lsoa')) |>
  dplyr::bind_rows()

# source(url('https://raw.githubusercontent.com/economic-analytics/edd/main/R/utils-df-to-edd_obj.R'))

