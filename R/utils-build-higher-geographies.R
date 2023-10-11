# build all higher geogs data from LAD data

build_higher_geogs <- function(df) {

  # load geography_lookup
  geography_lookup <- readr::read_csv("data/geo/geography_lookup.csv")

  # lad to cauth

  lad_cauth <- geography_lookup |>
    dplyr::select(LAD22CD, CAUTH22CD, CAUTH22NM) |>
    unique() |>
    dplyr::filter(!is.na(CAUTH22CD))

  lad_cty <- geography_lookup |>
    dplyr::select(LAD22CD, CTY22CD, CTY22NM) |>
    unique() |>
    dplyr::filter(!is.na(CTY22CD))

  lad_rgn <- geography_lookup |>
    dplyr::select(LAD22CD, RGN22CD, RGN22NM) |>
    unique() |>
    dplyr::filter(!is.na(RGN22CD))

  lad_panrgn <- geography_lookup |>
    dplyr::select(LAD22CD, PANRGN22CD, PANRGN22NM) |>
    unique() |>
    dplyr::filter(!is.na(PANRGN22CD))

  lad <- df |>
    dplyr::filter(geography_code %in% geography_lookup$LAD22CD)

  cauth <- lad |>
    dplyr::inner_join(lad_cauth, by = c('geography_code' = 'LAD22CD')) |>
    dplyr::group_by(dplyr::across(-dplyr::all_of(c("geography_code",
                                                 "geography_name",
                                                 "value")))) |>
    dplyr::summarise(value = sum(value)) |>
    dplyr::rename(geography_code = CAUTH22CD,
                  geography_name = CAUTH22NM)

  cty <- lad |>
    dplyr::inner_join(lad_cty, by = c('geography_code' = 'LAD22CD')) |>
    dplyr::group_by(dplyr::across(-dplyr::all_of(c("geography_code",
                                                   "geography_name",
                                                   "value")))) |>
    dplyr::summarise(value = sum(value)) |>
    dplyr::rename(geography_code = CTY22CD,
                  geography_name = CTY22NM)

  rgn <- lad |>
    dplyr::inner_join(lad_rgn, by = c('geography_code' = 'LAD22CD')) |>
    dplyr::group_by(dplyr::across(-dplyr::all_of(c("geography_code",
                                                   "geography_name",
                                                   "value")))) |>
    dplyr::summarise(value = sum(value)) |>
    dplyr::rename(geography_code = RGN22CD,
                  geography_name = RGN22NM)

  panrgn <- lad |>
    dplyr::inner_join(lad_panrgn, by = c('geography_code' = 'LAD22CD')) |>
    dplyr::group_by(dplyr::across(-dplyr::all_of(c("geography_code",
                                                   "geography_name",
                                                   "value")))) |>
    dplyr::summarise(value = sum(value)) |>
    dplyr::rename(geography_code = PANRGN22CD,
                  geography_name = PANRGN22NM)

  all_geogs <- dplyr::bind_rows(lad,
                                cauth,
                                cty,
                                rgn,
                                panrgn)

  return(all_geogs)

}

build_the_north <- function(df) {
  # filter for only regional data
  df |>
    dplyr::filter(geography_code %in% paste0("E1200000", 1:3)) |>
    dplyr::group_by(dplyr::across(-dplyr::all_of(c("geography_code",
                                                   "geography_name",
                                                   "value")))) |>
    dplyr::summarise(value = sum(value)) |>
    dplyr::mutate(geography_code = "E12999901",
                  geography_name = "The North")
}
