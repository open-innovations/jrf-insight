# shape areas

geography_lookup <- readr::read_csv("data/geo/geography_lookup.csv")

boundaries <- list(
  panrgn22 = sf::read_sf('data/geo/the_north.geojson'),
  rgn22 = sf::read_sf('data-raw/geo/rgn22_buc.geojson') |>
    dplyr::filter(RGN22CD %in% geography_lookup$RGN22CD),
  cty22 = sf::read_sf('data-raw/geo/cty22_buc.geojson') |>
    dplyr::filter(CTY22CD %in% geography_lookup$CTY22CD),
  cauth22 = sf::read_sf('data-raw/geo/cauth22_buc.geojson') |>
    dplyr::filter(CAUTH22CD %in% geography_lookup$CAUTH22CD),
  cty22_ua22 = sf::read_sf('data-raw/geo/cty22-ua22_buc.geojson') |>
    dplyr::filter(CTYUA22CD %in% geography_lookup$CTY22CD |
                    CTYUA22CD %in% geography_lookup$LAD22CD),
  lad22 = sf::read_sf('data-raw/geo/lad22_buc.geojson') |>
    dplyr::filter(LAD22CD %in% geography_lookup$LAD22CD),
  wd22 = sf::read_sf('data-raw/geo/wd22_bsc.geojson') |>
    dplyr::filter(WD22CD %in% geography_lookup$WD22CD)
) |>
  lapply(function(x) {
    sf::st_transform(x, crs = 4326)
  })



# place_areas <- data.frame(geography_code = boundaries$lad22$LAD22CD,
#                           variable_name = 'Area in sq km',
#                           value = (sf::st_area(boundaries$lad22$geometry) / 1e6) |>
#                             stringr::str_remove(stringr::fixed(' [m^2]')) |>
#                             as.numeric())


place_areas <- data.frame(geography_code = boundaries$wd22$WD22CD,
                          variable_name = 'Area in sq km',
                          value = (sf::st_area(boundaries$wd22$geometry) / 1e6) |>
                            stringr::str_remove(stringr::fixed(' [m^2]')) |>
                            as.numeric())


wd_lad <- geography_lookup |>
  dplyr::select(WD22CD, LAD22CD) |>
  unique() |>
  dplyr::filter(!is.na(LAD22CD))

wd_cauth <- geography_lookup |>
  dplyr::select(WD22CD, CAUTH22CD) |>
  unique() |>
  dplyr::filter(!is.na(CAUTH22CD))

wd_cty <- geography_lookup |>
  dplyr::select(WD22CD, CTY22CD) |>
  unique() |>
  dplyr::filter(!is.na(CTY22CD))

wd_rgn <- geography_lookup |>
  dplyr::select(WD22CD, RGN22CD) |>
  unique() |>
  dplyr::filter(!is.na(RGN22CD))

wd_panrgn <- geography_lookup |>
  dplyr::select(WD22CD, PANRGN22CD) |>
  unique() |>
  dplyr::filter(!is.na(PANRGN22CD))

wd <- place_areas |>
  dplyr::filter(geography_code %in% geography_lookup$WD22CD)

lad <- place_areas |>
  dplyr::inner_join(wd_lad, by = c('geography_code' = 'WD22CD')) |>
  dplyr::group_by(LAD22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = LAD22CD)


cauth <- place_areas |>
  dplyr::inner_join(wd_cauth, by = c('geography_code' = 'WD22CD')) |>
  dplyr::group_by(CAUTH22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = CAUTH22CD)

cty <- place_areas |>
  dplyr::inner_join(wd_cty, by = c('geography_code' = 'WD22CD')) |>
  dplyr::group_by(CTY22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = CTY22CD)

rgn <- place_areas |>
  dplyr::inner_join(wd_rgn, by = c('geography_code' = 'WD22CD')) |>
  dplyr::group_by(RGN22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = RGN22CD)

panrgn <- place_areas |>
  dplyr::inner_join(wd_panrgn, by = c('geography_code' = 'WD22CD')) |>
  dplyr::group_by(PANRGN22CD, variable_name) |>
  dplyr::summarise(value = sum(value)) |>
  dplyr::rename(geography_code = PANRGN22CD)

area_of_places <- dplyr::bind_rows(wd,
                                   lad,
                                   cauth,
                                   cty,
                                   rgn,
                                   panrgn)

readr::write_csv(area_of_places, 'data/geo/area_of_places.csv')

