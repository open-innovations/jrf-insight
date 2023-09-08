#ashe weekly pay

ashe_file_8_1a <- "data-raw/ashe/ashetable82022provisional/PROV - Home Geography Table 8.1a   Weekly pay - Gross 2022.xls"

ashe_file_8_7a <- "data-raw/ashe/ashetable82022provisional/PROV - Home Geography Table 8.7a   Annual pay - Gross 2022.xls"

ashe_sheets <- readxl::excel_sheets(ashe_file_8_1a)
# "All"

geography_code_name_only <- readr::read_csv("data/geo/geography_code_name_only.csv")

ashe_8_1a <- readxl::read_excel(ashe_file_8_1a, sheet = "All", skip = 4, na = c("x", "..", ":", "-")) |>
  dplyr::mutate(date = "2022") |>
  dplyr::select(date,
                geography_code = Code,
                geography_name = Description,
                median_weekly_wage = Median,
                mean_weekly_wage = Mean) |>
  tidyr::pivot_longer(c(median_weekly_wage, mean_weekly_wage), names_to = "variable_name") |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)

ashe_8_7a <- readxl::read_excel(ashe_file_8_7a, sheet = "All", skip = 4, na = c("x", "..", ":", "-")) |>
  dplyr::mutate(date = "2022") |>
  dplyr::select(date,
                geography_code = Code,
                geography_name = Description,
                median_annual_wage = Median,
                mean_annual_wage = Mean) |>
  tidyr::pivot_longer(c(median_annual_wage, mean_annual_wage), names_to = "variable_name") |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)

ashe <- dplyr::bind_rows(ashe_8_1a, ashe_8_7a)

readr::write_csv(ashe, "data/ashe/weekly-earnings.csv")
