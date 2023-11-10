# gender pay gap

collection_url <- "https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/placeofresidencebylocalauthorityashetable8"

# NB the gender pay gap data only exists in the 2022 provisional, not the 2022 revised or the 2023 provisional, so we have to rely on this dataset being hard coded for now

a_tags <- rvest::read_html(collection_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

a_tags_with_zip <- a_tags[grepl(".zip$", a_tags)]

# force use of 2022 provisional data
download_target <- paste0("http://ons.gov.uk", a_tags_with_zip[grepl("2022provisional", a_tags_with_zip)])

local_zip_file <- file.path("data-raw/ashe", basename(download_target))

download.file(url = download_target,
              destfile = local_zip_file,
              mode = "wb"
)

# identify file paths to unzip (not doing all of them to save space)
files_to_unzip <- unzip(local_zip_file, list = TRUE)
files_to_unzip <- files_to_unzip$Name[grepl("8.12", files_to_unzip$Name)]

unzip(local_zip_file, files = files_to_unzip, exdir = "data-raw/ashe")

# discover the year of the data from the filename
data_year <- stringr::str_extract(files_to_unzip, "[0-9]{4}") |>
  unique()

geography_code_name_only <- readr::read_csv("data/geo/geography_code_name_only.csv")


gender_pay_gap_file <- file.path("data-raw", "ashe", files_to_unzip)
gender_pay_gap_sheets <- readxl::excel_sheets(gender_pay_gap_file)[2:4]
gender_pay_gap <- lapply(gender_pay_gap_sheets, function(sht) {
  readxl::read_excel(gender_pay_gap_file, sheet = sht, skip = 4, na = "x") |>
  dplyr::select(-(5:6)) |>
  setNames(c("geography_name", "geography_code", "median_gender_pay_gap",
             "mean_gender_pay_gap")) |>
  tidyr::pivot_longer(dplyr::where(is.numeric), names_to = "variable_name") |>
  dplyr::mutate(date = data_year) |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)
}) |>
  setNames(gender_pay_gap_sheets) |>
  dplyr::bind_rows(.id = "hours")


readr::write_csv(gender_pay_gap, "data/gender-pay-gap/gender-pay-gap.csv")
arrow::write_parquet(gender_pay_gap, "data-mart/gender-pay-gap/gender-pay-gap.parquet")
