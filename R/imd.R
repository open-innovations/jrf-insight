# https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019

imd_file <- list.files('data-raw/imd', pattern = 'File_7', full.names = TRUE)

imd_all_lsoa <- readr::read_csv(imd_file) |>
  tidyr::pivot_longer(-(1:4), 'variable') |>
  dplyr::mutate(domain = substr(variable, 1, regexpr('Score|Rank|Decile', variable) - 2)) |>
  dplyr::mutate(domain = ifelse(domain == "", "Population data", domain)) |>
  dplyr::mutate(variable = substr(variable, regexpr('Score|Rank|Decile', variable), nchar(variable))) |>
  dplyr::mutate(date = "2019",
                geography_type = 'lsoa11') |>
  dplyr::select(date,
                geography_code = `LSOA code (2011)`,
                geography_name = `LSOA name (2011)`,
                geography_type,
                domain,
                variable,
                value)

imd_lad_lower_file <- list.files('data-raw/imd', pattern = 'File_10', full.names = TRUE)

# readxl::excel_sheets(imd_lad_lower_file)
imd_lower_lad <- readxl::read_excel(imd_lad_lower_file, sheet = 'IMD')

imd_lad_upper_file <- list.files('data-raw/imd', 'File_11', full.names = TRUE)

# readxl::excel_sheets(imd_lad_upper_file)
imd_upper_lad <- readxl::read_excel(imd_lad_upper_file, sheet = 'IMD')

imd_lad <- dplyr::bind_rows(imd_lower_lad, imd_upper_lad)


process_imd_lad <- function(files = NULL) {
  if (is.null(files)) {
    files <- list.files('data-raw/imd', 'Local_Authority', full.names = T)
  }
    data <- lapply(files, function(file) {
      x <- readxl::read_excel(file, sheet = 'IMD')
      if (any(grepl('Upper Tier', names(x)))) {
        x <- x |>
          dplyr::filter(substr(`Upper Tier Local Authority District code (2019)`, 1, 3) == "E10")
      }
      names(x)[1:2] <- c('geography_code', 'geography_name')

      return(x)
    }) |>
      dplyr::bind_rows() |>
      dplyr::distinct() |>
      tidyr::pivot_longer(-c(geography_code, geography_name), names_to = 'variable') |>
      dplyr::filter(variable == 'IMD - Average score')
    return(data)
}

imd <- process_imd_lad()

readr::write_csv(imd, 'data/imd/imd.csv')
