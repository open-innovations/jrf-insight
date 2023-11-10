# ctsop

# Council Tax Stock of Properties
# Published as a collection at https://www.gov.uk/government/collections/valuation-office-agency-council-tax-statistics

# Download file -----------------------------------------------------------

collection_url <- "https://www.gov.uk/government/collections/valuation-office-agency-council-tax-statistics"

a_tags <- rvest::read_html(collection_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

ctsop_a_tags <- a_tags[grepl("council-tax-stock-of-properties", a_tags)]

latest_ctsop_a_tag <- ctsop_a_tags[1]

# pull html from this latest tag
latest_page <- rvest::read_html(paste0("https://www.gov.uk", latest_ctsop_a_tag)) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

latest_page_4_1 <- latest_page[grepl("CTSOP4_1.*", latest_page)] |>
  unique() # unique as both text and image are <a>

# identify which file is the most recent
dates <- stringr::str_extract_all(latest_page_4_1, "[0-9]{4}") |>
  lapply(function(x) max(x)) |>
  unlist()
latest_index <- which(dates == max(dates))

target_file <- latest_page_4_1[latest_index]

local_zip_path <- file.path("data-raw", "households", basename(target_file))

download.file(target_file, local_zip_path, mode = "wb")

files_in_zip <- unzip(local_zip_path, list = TRUE)

# extract years from filenames
max_year <- stringr::str_extract(files_in_zip$Name, "[0-9]{4}") |> max()
file_to_unzip <- files_in_zip$Name[grepl(max_year, files_in_zip$Name)]
unzip(local_zip_path, files = file_to_unzip, exdir = file.path("data-raw", "households"))

ctsop_file <- list.files(file.path("data-raw", "households"), pattern = ".csv$", full.names = TRUE)

# Process file ------------------------------------------------------------

ctsop_data <- readr::read_csv(ctsop_file)

ctsop_data$geography |> unique()
# [1] "ENGWAL" "NATL"   "REGL"   "LAUA"   "MSOA"   "LSOA"   "CTYMET" "UNMD"

households_lad <- ctsop_data |>
  # filter for LAUA only
  dplyr::filter(geography == 'LAUA') |>
  # filter for all bands
  dplyr::filter(band == 'All') |>
  # add date and variable
  dplyr::mutate(date = max_year,
                variable_name = "Number of households",
                all_properties = as.integer(all_properties)) |>
  # reduce cols
  dplyr::select(date,
                geography_code = ecode,
                variable_name,
                value = all_properties)

households_wd <- ctsop_data |>
  # filter for LAUA only
  dplyr::filter(geography == 'LSOA') |>
  # filter for all bands
  dplyr::filter(band == 'All') |>
  # add date and variable
  dplyr::mutate(date = max_year,
                variable_name = "Number of households",
                all_properties = as.integer(all_properties)) |>
  # reduce cols
  dplyr::select(date,
                geography_code = ecode,
                variable_name,
                value = all_properties)

lsoa_wd <- readxl::read_excel("data/geo/LSOA11_WD21_LAD21_EW_LU_V2.xlsx") |>
  dplyr::select(LSOA11CD, WD21CD)

joined <- dplyr::inner_join(households_wd, lsoa_wd,
                            by = c('geography_code' = 'LSOA11CD')) |>
  dplyr::select(-geography_code) |>
  dplyr::rename(geography_code = WD21CD) |>
  dplyr::group_by(date, geography_code, variable_name) |>
  dplyr::summarise(value = sum(value))


geography_lookup <- readr::read_csv("data/geo/geography_lookup.csv")

lad_cauth <- geography_lookup |>
  dplyr::select(LAD22CD, CAUTH22CD) |>
  unique() |>
  dplyr::filter(!is.na(CAUTH22CD))

lad_cty <- geography_lookup |>
  dplyr::select(LAD22CD, CTY22CD) |>
  unique() |>
  dplyr::filter(!is.na(CTY22CD))

lad_rgn <- geography_lookup |>
  dplyr::select(LAD22CD, RGN22CD) |>
  unique() |>
  dplyr::filter(!is.na(RGN22CD))

lad_panrgn <- geography_lookup |>
  dplyr::select(LAD22CD, PANRGN22CD) |>
  unique() |>
  dplyr::filter(!is.na(PANRGN22CD))

lad <- households_lad |>
  dplyr::filter(geography_code %in% geography_lookup$LAD22CD)

cauth <- households_lad |>
  dplyr::inner_join(lad_cauth, by = c('geography_code' = 'LAD22CD')) |>
  dplyr::group_by(date, CAUTH22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = CAUTH22CD)

cty <- households_lad |>
  dplyr::inner_join(lad_cty, by = c('geography_code' = 'LAD22CD')) |>
  dplyr::group_by(date, CTY22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = CTY22CD)

rgn <- households_lad |>
  dplyr::inner_join(lad_rgn, by = c('geography_code' = 'LAD22CD')) |>
  dplyr::group_by(date, RGN22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = RGN22CD)

panrgn <- households_lad |>
  dplyr::inner_join(lad_panrgn, by = c('geography_code' = 'LAD22CD')) |>
  dplyr::group_by(date, PANRGN22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = PANRGN22CD)

households <- dplyr::bind_rows(joined,
                               lad,
                               cauth,
                               cty,
                               rgn,
                               panrgn)

readr::write_csv(households, 'data/households/households.csv')
arrow::write_parquet(households, 'data-mart/households/households.parquet')


