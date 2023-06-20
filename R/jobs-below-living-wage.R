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

jobs_below_lw <- lapply(sheets, function(sht) {
  readxl::read_excel(file, sheet = sht, skip = 4)
  # ,
  #                    col_names = c("geography_name", "geography_code",
  #                                  "number_of_jobs_000s", "percent"),
  #                    col_types = c("text", "text",
  #                                  "numeric", "numeric",
  #                                  rep("skip", 3)),
  #                    na = c("x", "-", ":", "..")
  # ) |>
  #   tidyr::pivot_longer(-(geography_name:geography_code),
  #                       names_to = 'variable_name')
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
  dplyr::mutate(date = substr(file, regexpr("[0-9]{4}", file), regexpr("[0-9]{4}", file) + 3), .before = 1)
