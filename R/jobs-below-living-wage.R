# https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/numberandproportionofemployeejobswithhourlypaybelowthelivingwage



# download ----------------------------------------------------------------

collection_url <- "https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/numberandproportionofemployeejobswithhourlypaybelowthelivingwage"

links <- rvest::read_html(collection_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

zips <- links[grepl(".zip$", links)]

zip_to_download <- zips[1]
zip_path <- file.path("data-raw", "jobs-below-living-wage", basename(zip_to_download))
#download first one
download.file(paste0("http://ons.gov.uk", zip_to_download),
              zip_path,
              mode = "wb")

files_in_zip <- unzip(zip_path, list = TRUE)
file_to_unzip <- files_in_zip$Name[grepl("Table 7 LWF.1a", files_in_zip$Name)]

folder <- 'data-raw/jobs-below-living-wage'

unzip(zip_path, files = file_to_unzip, exdir = file.path("data-raw", "jobs-below-living-wage"))


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
arrow::write_parquet(jblw, "data-mart/jobs-below-living-wage/jobs-below-living-wage.parquet")
