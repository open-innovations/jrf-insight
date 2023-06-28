
geography_lookup <- readr::read_csv("data-raw/geo/Ward_to_Local_Authority_District_to_County_to_Region_to_Country_(December_2022)_Lookup_in_United_Kingdom.csv") |>
  dplyr::mutate(PANRGN22CD = ifelse(RGN22CD %in% paste0('E1200000', 1:3),
                                    "E12999901",
                                    NA),
                PANRGN22NM = ifelse(RGN22CD %in% paste0('E1200000', 1:3),
                                    "The North",
                                    NA)
  ) |>
  dplyr::left_join(readr::read_csv("data-raw/geo/lad22_cauth22.csv"),
                   by = c("LAD22CD")) |>
  dplyr::select(PANRGN22CD, PANRGN22NM,
                RGN22CD, RGN22NM,
                CTY22CD, CTY22NM,
                CAUTH22CD, CAUTH22NM,
                LAD22CD, LAD22NM = LAD22NM.x,
                WD22CD, WD22NM) |>
  dplyr::filter(PANRGN22CD == "E12999901") |>
  dplyr::arrange(PANRGN22CD, RGN22CD, CTY22CD, CAUTH22CD, LAD22CD, WD22CD)

geography_lookup_codes_only <- geography_lookup |>
  dplyr::select(dplyr::ends_with('CD'))

# readr::write_csv(geography_lookup, 'data/geo/geography_lookup.csv')

 # append each set of two columns below the first set


return_child_from <- function(row_number, col_number) {
  # check to see if column to the right is NA, if so increment
  if (is.na(geography_lookup_codes_only[row_number, col_number + 1])) {
    return_child_from(row_number, col_number + 1)
  } else {
    return(
      paste(geography_lookup_codes_only[row_number, col_number + 1, drop = TRUE],
            names(geography_lookup_codes_only)[col_number + 1]))
  }
}

parent <- vector()
child <- vector()
parent_type <- vector()
for (col in 1:(ncol(geography_lookup_codes_only) - 1)) {
  for (row in 1:(nrow(geography_lookup_codes_only))) {
    if (!is.na(geography_lookup_codes_only[row, col])) {
      parent <- c(parent, geography_lookup_codes_only[row, col, drop = TRUE])
      child <- c(child, return_child_from(row, col))
      parent_type <- c(parent_type, names(geography_lookup_codes_only)[col])
    }
  }
}

result <- data.frame(parent = parent,
                     parent_type = parent_type,
                     child = substr(child, 1, 9),
                     child_type = substr(child, 11, nchar(child))
                     ) |>
  unique()

readr::write_csv(result, "data/geo/geography_tree.csv")



return_child_from(112, 2)
return_child_from(343, 3)
return_child_from(1146, 2)
