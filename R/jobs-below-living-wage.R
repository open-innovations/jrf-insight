# https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/numberandproportionofemployeejobswithhourlypaybelowthelivingwage

folder <- 'data-raw/jobs-below-living-wage'

# Unzipping ---------------------------------------------------------------

# zips <- list.files(folder, pattern = '*.zip', full.names = TRUE)

# lapply(zips, function(file) {
#   all_files <- unzip(file, list = TRUE)
#   files_to_unzip <- all_files$Name[!grepl('CV|PC', all_files$Name)]
#   unzip(zips, files = files_to_unzip, exdir = folder)
# })


# Process -----------------------------------------------------------------

file <- list.files(folder, pattern = ".xls", full.names = TRUE)

sheets <- readxl::excel_sheets(file)
sheets <- sheets[!grepl("Notes", sheets)] |>
  setNames(sheets[!grepl("Notes", sheets)])


geography_code_name_only <- readr::read_csv("data/geo/geography_code_name_only.csv")

jobs_below_lw <- lapply(sheets, function(sht) {
  readxl::read_excel(file, sheet = sht, skip = 4, na = c("x", "-", ":", "..")) |>
    dplyr::select(1:4) |>
    setNames(c("geography_name", "geography_code",
             "number_of_jobs_000s", "percent"))
}) |>
  dplyr::bind_rows(.id = 'dataset') |>
  dplyr::mutate(
    sex = dplyr::case_when(
      dataset %in% c('All', 'Full-Time', 'Part-Time') ~ "All",
      grepl("Male", dataset) ~ "Male",
      grepl("Female", dataset) ~ "Female"),
    hours = dplyr::case_when(
      dataset %in% c('All', 'Male', 'Female') ~ "All",
      grepl("Full-Time", dataset) ~ "Full-Time",
      grepl("Part-Time", dataset) ~ "Part-Time"
    )
  ) |>
  dplyr::select(-dataset) |>
  dplyr::mutate(date = substr(file, regexpr("[0-9]{4}", file), regexpr("[0-9]{4}", file) + 3), .before = 1) |>
  tidyr::pivot_longer(dplyr::where(is.numeric), names_to = "variable_name") |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)

source("R/utils-build-higher-geographies.R")
jblw_north <- jobs_below_lw |>
  tidyr::pivot_wider(names_from = variable_name) |>
  dplyr::mutate(total_jobs = number_of_jobs_000s / (percent / 100)) |>
  tidyr::pivot_longer(dplyr::where(is.numeric), names_to = "variable_name") |>
  build_the_north() |>
  tidyr::pivot_wider(names_from = "variable_name") |>
  dplyr::mutate(percent = number_of_jobs_000s / total_jobs * 100) |>
  dplyr::select(-total_jobs) |>
  tidyr::pivot_longer(dplyr::where(is.numeric), names_to = "variable_name")

jblw <- dplyr::bind_rows(jobs_below_lw, jblw_north)

readr::write_csv(jblw, "data/jobs-below-living-wage/jobs-below-living-wage.csv")
