#ashe weekly pay

# data from ashe table 8
# https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/placeofresidencebylocalauthorityashetable8

collection_url <- "https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/placeofresidencebylocalauthorityashetable8"

a_tags <- rvest::read_html(collection_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

a_tags_with_zip <- a_tags[grepl(".zip$", a_tags)]

# take the first one and append to base URL (without HTTPS for some reason!)
download_target <- paste0("http://ons.gov.uk", a_tags_with_zip[1])

local_zip_file <- file.path("data-raw/ashe", basename(download_target))

download.file(url = download_target,
              destfile = local_zip_file,
              mode = "wb"
)

# identify file paths to unzip (not doing all of them to save space)
files_to_unzip <- unzip(local_zip_file, list = TRUE)
files_to_unzip <- files_to_unzip$Name[grepl("8.1a|8.7a", files_to_unzip$Name)]

unzip(local_zip_file, files = files_to_unzip, exdir = "data-raw/ashe")

# discover the year of the data from the filename
data_year <- stringr::str_extract(files_to_unzip, "[0-9]{4}") |>
  unique()

ashe_file_8_1a <- file.path("data-raw/ashe", files_to_unzip[grepl("8.1a", files_to_unzip)])

ashe_file_8_7a <- file.path("data-raw/ashe", files_to_unzip[grepl("8.7a", files_to_unzip)])

ashe_sheets <- readxl::excel_sheets(ashe_file_8_1a)
# We'll be using sheet "All"

geography_code_name_only <- readr::read_csv("data/geo/geography_code_name_only.csv")

ashe_8_1a <- readxl::read_excel(ashe_file_8_1a, sheet = "All", skip = 4, na = c("x", "..", ":", "-")) |>
  dplyr::mutate(date = data_year) |>
  dplyr::select(date,
                geography_code = Code,
                geography_name = Description,
                median_weekly_wage = Median,
                mean_weekly_wage = Mean,
                lq_weekly_wage = `25`) |>
  tidyr::pivot_longer(c(median_weekly_wage, mean_weekly_wage, lq_weekly_wage), names_to = "variable_name") |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)

ashe_8_7a <- readxl::read_excel(ashe_file_8_7a, sheet = "All", skip = 4, na = c("x", "..", ":", "-")) |>
  dplyr::mutate(date = data_year) |>
  dplyr::select(date,
                geography_code = Code,
                geography_name = Description,
                median_annual_wage = Median,
                mean_annual_wage = Mean,
                lq_annual_wage = `25`) |>
  dplyr::mutate(lq_monthly_wage = round(lq_annual_wage / 12)) |>
  tidyr::pivot_longer(c(median_annual_wage, mean_annual_wage,
                        lq_annual_wage, lq_monthly_wage), names_to = "variable_name") |>
  dplyr::filter(geography_code %in% geography_code_name_only$code)

ashe <- dplyr::bind_rows(ashe_8_1a, ashe_8_7a)

readr::write_csv(ashe, "data/ashe/weekly-earnings.csv")
arrow::write_parquet(ashe, "data-mart/ashe/weekly-earnings.parquet")
