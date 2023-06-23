# rgn22_lad22 <- readr::read_csv("data-raw/geo/Local_Authority_District_to_Region_(December_2022)_Lookup_in_England.csv")

lad22_cauth22 <- readr::read_csv("data-raw/geo/lad22_cauth22.csv")

wd22_lad22_cty22_rgn22_ctry22 <- readr::read_csv("data-raw/geo/Ward_to_Local_Authority_District_to_County_to_Region_to_Country_(December_2022)_Lookup_in_United_Kingdom.csv") |>
  dplyr::mutate(PANRGN22CD = ifelse(RGN22CD %in% paste0('E1200000', 1:3),
                                    "E12999901",
                                    NA),
                PANRGN22NM = ifelse(RGN22CD %in% paste0('E1200000', 1:3),
                                    "The North",
                                    NA)
  ) |>
  dplyr::left_join(lad22_cauth22, by = c("LAD22CD")) |>
  dplyr::select(PANRGN22CD, PANRGN22NM,
                RGN22CD, RGN22NM,
                CTY22CD, CTY22NM,
                CAUTH22CD, CAUTH22NM,
                LAD22CD, LAD22NM = LAD22NM.x,
                WD22CD, WD22NM) |>
  dplyr::filter(PANRGN22CD == "E12999901") |>
  dplyr::arrange(PANRGN22CD, RGN22CD, CTY22CD, CAUTH22CD, LAD22CD, WD22CD) |>
  readr::write_csv('data/geo/geography_lookup.csv')



