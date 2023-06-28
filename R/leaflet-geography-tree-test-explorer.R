#geo-tree

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
    sf::st_transform(x, crs = 4326) |>
      dplyr::select(dplyr::ends_with(c("CD", "NM")),
                    geometry)
  })

# TODO create a new boundary file for each "layer"
# should be driven by geography_lookup
# panrgn > rgn
# rgn > cty | cauth | lad THIS IS THE BESPOKE LAYER
# cty > lad
# cauth > lad
# lad > wd

geog_tree <- names(geography_lookup)[grepl("CD", names(geography_lookup))]

# hard coded variables below should be dynamically picked from geog_tree

bespoke_layer <- dplyr::bind_rows(
  boundaries$cty22,
  boundaries$cauth22 |>
    dplyr::filter(CAUTH22CD %in% geography_lookup$CAUTH22CD[is.na(geography_lookup$CTY22CD) | geography_lookup$CAUTH22NM == geography_lookup$CTY22NM]),
  boundaries$lad22 |>
    dplyr::filter(LAD22CD %in% geography_lookup$LAD22CD[is.na(geography_lookup$CTY22CD) & is.na(geography_lookup$CAUTH22CD)])
)

boundaries$bespoke_layer <- bespoke_layer

leaflet::leaflet() |>
  leaflet::addTiles() |>
  leaflet::addPolygons(data = boundaries$panrgn22, group = 'panrgn22') |>
  leaflet::addPolygons(data = boundaries$rgn22, group = 'rgn22') |>
  leaflet::addPolygons(data = boundaries$bespoke_layer, group = 'bespoke_layer') |>
  leaflet::addPolygons(data = boundaries$cty22, group = 'cty22') |>
  leaflet::addPolygons(data = boundaries$cauth22, group = 'cauth22') |>
  leaflet::addPolygons(data = boundaries$cty22_ua22, group = 'cty22_ua22') |>
  leaflet::addPolygons(data = boundaries$lad22, group = 'lad22') |>
  leaflet::addPolygons(data = boundaries$wd22, group = 'wd22') |>
  leaflet::addLayersControl(
    overlayGroups = c('panrgn22', 'rgn22', 'bespoke_layer', 'cty22', 'cauth22',
                      'cty22_ua22', 'lad22', 'wd22'),
    options = leaflet::layersControlOptions(collapsed = FALSE)
  )


# write out boundary files for each geography_type

for (i in seq_along(boundaries)) {
  sf::st_write(boundaries[[i]], paste0('data/geo/',
                                       names(boundaries)[i],
                                       '.geojson'))
}


for (i in seq_along(boundaries)) {
  x <- geojsonsf::sf_geojson(boundaries[[i]], digits = 5)
  write(x, paste0('data/geo/', names(boundaries)[i], '.geojson'))
}
