# ctsop

CTSOP4_1_2022_03_31 <- readr::read_csv("~/Data/VOA/CTSOP/CTSOP4-1-1993-2022/CTSOP4_1_2022_03_31.csv")

CTSOP4_1_2022_03_31$geography |> unique()
# [1] "ENGWAL" "NATL"   "REGL"   "LAUA"   "MSOA"   "LSOA"   "CTYMET" "UNMD"

households_lad <- CTSOP4_1_2022_03_31 |>
  # filter for LAUA only
  dplyr::filter(geography == 'LAUA') |>
  # filter for all bands
  dplyr::filter(band == 'All') |>
  # add date and variable
  dplyr::mutate(date = '2022',
                variable_name = "Number of households",
                all_properties = as.integer(all_properties)) |>
  # reduce cols
  dplyr::select(date,
                geography_code = ecode,
                variable_name,
                value = all_properties)

geography_lookup <- read_csv("data/geo/geography_lookup.csv")

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

households <- dplyr::bind_rows(lad,
                        cauth,
                        cty,
                        rgn,
                        panrgn)

readr::write_csv(households, 'data/households/households.csv')


