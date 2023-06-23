#geo-tree

geography_lookup <- readr::read_csv("data/geo/geography_lookup.csv")

boundaries <- list(
  panrgn22 = sf::read_sf('data/geo/the_north.geojson') |>
    sf::st_transform(crs = 4326),
  rgn22 = sf::read_sf('data-raw/geo/rgn22_buc.geojson') |>
    sf::st_transform(crs = 4326),
  cty22 = sf::read_sf('data-raw/geo/cty22_buc.geojson') |>
    sf::st_transform(crs = 4326),
  cauth22 = sf::read_sf('data-raw/geo/cauth22_buc.geojson') |>
    sf::st_transform(crs = 4326),
  cty22_ua22 = sf::read_sf('data-raw/geo/cty22-ua22_buc.geojson') |>
    sf::st_transform(crs = 4326),
  lad22 = sf::read_sf('data-raw/geo/lad22_buc.geojson') |>
    sf::st_transform(crs = 4326)
)



leaflet::leaflet() |>
  leaflet::addTiles() |>
  leaflet::addPolygons(data = boundaries$panrgn22, group = 'panrgn22') |>
  leaflet::addPolygons(data = boundaries$rgn22, group = 'rgn22') |>
  leaflet::addPolygons(data = boundaries$cty22, group = 'cty22') |>
  leaflet::addPolygons(data = boundaries$cauth22, group = 'cauth22') |>
  leaflet::addPolygons(data = boundaries$cty22_ua22, group = 'cty22_ua22') |>
  leaflet::addPolygons(data = boundaries$lad22, group = 'lad22') |>
  leaflet::addLayersControl(
    overlayGroups = c('panrgn22', 'rgn22', 'cty22', 'cauth22',
                      'cty22_ua22', 'lad22'),
    options = leaflet::layersControlOptions(collapsed = FALSE)
  )
