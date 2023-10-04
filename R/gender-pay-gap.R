# gender pay gap

geography_code_name_only <- readr::read_csv("data/geo/geography_code_name_only.csv")


gender_pay_gap_file <- "data-raw/ashe/ashetable82022provisional/PROV - Home Geography Table 8.12  Gender pay gap 2022.xls"
gender_pay_gap_sheets <- readxl::excel_sheets(gender_pay_gap_file)[2:4]
gender_pay_gap <- lapply(gender_pay_gap_sheets, function(sht) {
  readxl::read_excel("data-raw/ashe/ashetable82022provisional/PROV - Home Geography Table 8.12  Gender pay gap 2022.xls", sheet = sht, skip = 4, na = "x") |>
  dplyr::select(-(5:6)) |>
  setNames(c("geography_name", "geography_code", "median_gender_pay_gap",
             "mean_gender_pay_gap")) |>
  tidyr::pivot_longer(dplyr::where(is.numeric), names_to = "variable_name") |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)
}) |>
  setNames(gender_pay_gap_sheets) |>
  dplyr::bind_rows(.id = "hours")


readr::write_csv(gender_pay_gap, "data/gender-pay-gap/gender-pay-gap.csv")

