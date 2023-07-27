# GVA
# ITL1, 2, 3 only
# RGVA <- readRDS("~/Projects/edd/data/datasets/RGVA.rds")

# geog types
# RGVA$dimensions$geography$type |> unique()

rgva_lad <- readr::read_csv("~/Data/rgva_lad.csv") |>
  # all industries only
  dplyr::filter(SIC07 == 'Total') |>
  # latest data only
  dplyr::filter(date == max(date)) |>
  # current price only
  dplyr::filter(variable == 'Current Price') |>
  # rename variables
  dplyr::select(date,
                geography_code = `LAD code`,
                variable_name = variable,
                value) |>
  dplyr::mutate(variable_name = 'GVA',
                variable_unit = '£m')

# load geography_lookup to build the higher level geographies GVA data

geography_lookup <- readr::read_csv("data/geo/geography_lookup.csv")

# TODO generalise this process below
# generalise <- function(df, geog1, geog2) {
#   if (!exists('geography_lookup')) {
#     geography_lookup <- readr::read_csv("data/geo/geography_lookup.csv")
#   }
#
#   geography_lookup |>
#     dplyr::select(geog1, geog2) |>
#     dplyr::distinct() |>
#     dplyr::filter(!is.na(geog2)) |>
#     dplyr::inner_join(df, by = c('geography_code' = geog1)) |>
#     dplyr::group_by(date, geog2, variable_name) |>
#     dplyr::summarise(value = sum(value)) |>
#     dplyr::rename(geography_code = geog2)
# }

# lad to cauth

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

lad <- rgva_lad |>
  dplyr::filter(geography_code %in% geography_lookup$LAD22CD)

cauth <- rgva_lad |>
  dplyr::inner_join(lad_cauth, by = c('geography_code' = 'LAD22CD')) |>
  dplyr::group_by(date, CAUTH22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = CAUTH22CD)

cty <- rgva_lad |>
  dplyr::inner_join(lad_cty, by = c('geography_code' = 'LAD22CD')) |>
  dplyr::group_by(date, CTY22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = CTY22CD)

rgn <- rgva_lad |>
  dplyr::inner_join(lad_rgn, by = c('geography_code' = 'LAD22CD')) |>
  dplyr::group_by(date, RGN22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = RGN22CD)

panrgn <- rgva_lad |>
  dplyr::inner_join(lad_panrgn, by = c('geography_code' = 'LAD22CD')) |>
  dplyr::group_by(date, PANRGN22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = PANRGN22CD)

gva <- dplyr::bind_rows(lad,
                        cauth,
                        cty,
                        rgn,
                        panrgn)




# small geography ---------------------------------------------------------

gva_lsoa <- readxl::read_excel('~/Data/ONS/Regional Accounts/GVA/uksmallareagvaestimates1998to202023012023150255.xlsx', sheet = 'Table 1', skip = 1) |>
  tidyr::pivot_longer(cols = tidyselect:::where(is.numeric), names_to = 'date') |>
  dplyr::mutate(variable_name = 'GVA',
                variable_unit = '£m',
                date = as.Date(paste0(date, '-01-01'))) |>
  dplyr::select(date,
                geography_code = `LSOA code`,
                variable_name, variable_unit,
                value)
# |>
#   dplyr::filter(date == max(date))

lsoa_wd <- readxl::read_excel("~/Data/Geodata/Lookups/LSOA11_WD21_LAD21_EW_LU_V2.xlsx") |>
  dplyr::select(LSOA11CD, WD21CD)

joined <- dplyr::inner_join(gva_lsoa, lsoa_wd,
                           by = c('geography_code' = 'LSOA11CD'))

gva_wd <- joined |>
  dplyr::group_by(date, geography_code = WD21CD, variable_name, variable_unit) |>
  dplyr::summarise(value = sum(value))

gva <- dplyr::bind_rows(gva_wd,
                        gva)
readr::write_csv(gva, 'data/gva/gva.csv')
