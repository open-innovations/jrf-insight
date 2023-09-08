#ashe weekly pay

ashe_file <- "data-raw/ashe/ashetable82022provisional/PROV - Home Geography Table 8.1a   Weekly pay - Gross 2022.xls"

ashe_sheets <- readxl::excel_sheets(ashe_file)

geography_code_name_only <- read_csv("data/geo/geography_code_name_only.csv")

ashe <- readxl::read_excel(ashe_file, sheet = "All", skip = 4) |>
  dplyr::mutate(date = "2022") |>
  dplyr::select(date,
                geography_code = Code,
                geography_name = Description,
                median_weekly_wage = Median,
                mean_weekly_wage = Mean) |>
  tidyr::pivot_longer(c(median_weekly_wage, mean_weekly_wage), names_to = "variable_name") |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)

readr::write_csv(ashe, "data/ashe/weekly-earnings.csv")
