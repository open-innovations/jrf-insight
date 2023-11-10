# https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019


# download files 7 and 10

collection_url <- "https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019"

links <- rvest::read_html(collection_url) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href")

imd_files <- links[grepl("File_7|File_10|File_11", links)] |> unique()
imd_files <- imd_files[grepl(".xlsx$|.csv$", imd_files)]

lapply(imd_files, function(x) {
  download.file(x, destfile = file.path("data-raw", "imd", basename(x)), mode = "wb")
})


imd_file <- list.files('data-raw/imd', pattern = 'File_7', full.names = TRUE)

imd_all_lsoa <- readr::read_csv(imd_file) |>
  tidyr::pivot_longer(-(1:4), names_to = 'variable') |>
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
imd_lower_lad_idaci <- readxl::read_excel(imd_lad_lower_file, sheet = "IDACI")
imd_lad_upper_file <- list.files('data-raw/imd', 'File_11', full.names = TRUE)

# readxl::excel_sheets(imd_lad_upper_file)
imd_upper_lad <- readxl::read_excel(imd_lad_upper_file, sheet = 'IMD')

imd_lad <- dplyr::bind_rows(imd_lower_lad, imd_upper_lad)


process_imd_lad <- function(files = NULL) {
  if (is.null(files)) {
    files <- list.files('data-raw/imd', 'Local_Authority', full.names = T)
  }
    data <- lapply(files, function(file) {
      # create sheets to iterate through
      imd_sheets_to_import <- c('IMD', 'IDACI', 'IDAOPI')

      build1 <- lapply(imd_sheets_to_import, function(sht) {
        x <- readxl::read_excel(file, sheet = sht)
        if (any(grepl('Upper Tier', names(x)))) {
          x <- x |>
            dplyr::filter(substr(`Upper Tier Local Authority District code (2019)`, 1, 3) == "E10")
        }
        names(x)[1:2] <- c('geography_code', 'geography_name')
        names(x) <- sub('[A-Za-z]* - ', '', names(x)) # remove variable prefix
        return(x)
      }) |>
        setNames(imd_sheets_to_import) |>
        dplyr::bind_rows(.id = 'dataset')
      return(build1)
    }) |>
      dplyr::bind_rows() |>
      dplyr::distinct() |>
      tidyr::pivot_longer(-c(dataset, geography_code, geography_name), names_to = 'variable_name') |>
      dplyr::filter(variable_name == 'Average score')
    return(data)
}

imd <- process_imd_lad()

readr::write_csv(imd, 'data/imd/imd.csv')
arrow::write_ipc_file(imd, 'data-mart/imd/imd.parquet')
