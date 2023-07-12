# GVA
# ITL1, 2, 3 only
# RGVA <- readRDS("~/Projects/edd/data/datasets/RGVA.rds")

# geog types
RGVA$dimensions$geography$type |> unique()

rgva_lad <- read_csv("~/Data/rgva_lad.csv") |>
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
  dplyr::mutate(variable_name = 'GVA (£m)')

# load geography_lookup to build the higher level geographies GVA data

geography_lookup <- read_csv("data/geo/geography_lookup.csv")

# TODO generalise this process below
generalise <- function(df, geog1, geog2) {
  if (!exists('geography_lookup')) {
    geography_lookup <- readr::read_csv("data/geo/geography_lookup.csv")
  }

  geography_lookup |>
    dplyr::select(geog1, geog2) |>
    dplyr::distinct() |>
    dplyr::filter(!is.na(geog2)) |>
    dplyr::inner_join(df, by = c('geography_code' = geog1)) |>
    dplyr::group_by(date, geog2, variable_name) |>
    dplyr::summarise(value = sum(value)) |>
    dplyr::rename(geography_code = geog2)
}

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

gva <- dplyr::bind_rows(rgva_lad,
                        cauth,
                        cty,
                        rgn,
                        panrgn)

readr::write_csv(gva, 'data/gva/gva.csv')

