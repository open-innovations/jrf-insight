# local-housing-allowance

# LA https://www.gov.uk/government/publications/local-housing-allowance-lha-rates-applicable-from-april-2023-to-march-2024

# UC https://www.gov.uk/government/publications/universal-credit-local-housing-allowance-rates-2023-to-2024

lha_la <- readxl::read_excel("data-raw/local-housing-allowance/2023-24_LHA_TABLES.xlsx", sheet = "Table 4", skip = 1) |>
  dplyr::rename(
    room = `CAT A`,
    bed1 = `CAT B`,
    bed2 = `CAT C`,
    bed3 = `CAT D`,
    bed4 = `CAT E`
  )

# is non UTF-8 (!) and not sure of the difference
# lha_uc <- readr::read_csv("data-raw/local-housing-allowance/england-rates-2023-to-2024.csv", skip = 1)

OA21_BRMA20_LU <- readr::read_csv("~/Data/Geodata/Lookups/OA21_BRMA20_LU.csv")

joined <- dplyr::left_join(lha_la, OA21_BRMA20_LU, by = c("BRMA" = "BRMA20NM"))

OA11_OA21_LAD22_EW_LU <- readr::read_csv("~/Data/Geodata/Lookups/OA11_OA21_LAD22_EW_LU.csv") |>
  dplyr::distinct(OA21CD, LAD22CD)


joined2 <- dplyr::left_join(joined, OA11_OA21_LAD22_EW_LU, by = c("OA21CD")) |>
  tidyr::pivot_longer(cols = room:bed4, names_to = "property_type", values_to = "lha_value") |>
  dplyr::select(BRMA, LAD22CD, property_type, lha_value) |>
  dplyr::distinct() |>
  # some LAs map to multiple BRMA, so we simply take a mean average
  # ideally this would be property type weighted via CTSOP data at LSOA level
  dplyr::group_by(LAD22CD, property_type) |>
  dplyr::summarise(lha_value = mean(lha_value)) |>
  dplyr::mutate(lha_value = lha_value * 52 / 12)

# bring in rental prices

rental_prices <- readr::read_csv("data/rental-prices/rental-prices.csv") |>
  dplyr::filter(variable_name != "Count of rents") |>
  dplyr::select(-variable_code, -geography_code.ba, -property_code) |>
  tidyr::pivot_wider(names_from = variable_name)

all_data <- dplyr::inner_join(rental_prices, joined2,
                             by = c("geography_code" = "LAD22CD",
                                    "property_name" = "property_type"))


# would prefer to fit a log-norm but the data just isn't good enough to allow for it
# for (i in seq_along(rental_prices$geography_code)) {
#   model <- rriskDistributions::get.lnorm.par(
#   p = c(0.25, 0.5, 0.75),
#   q = c(rental_prices$`Lower quartile`[i],
#         rental_prices$Median[i],
#         rental_prices$`Upper quartile`[i]),
#   tol = 0.09)
#   df[i, "meanlog"] <- model[1]
#   df[i, "sdlog"] <- model[2]
# }

# so instead, we're going to fit a simpler model based on a set of uniform distributions between known data points to identify 30th percentile for each area (that has enough data to allow for it)
for (i in 1:nrow(all_data)) {
  # try to calculate the value of the 30th percentile in each area
  all_data[i, "p30"] <- all_data$`Lower quartile`[i] + (5/25) * (all_data$Median[i] - all_data$`Lower quartile`[i])

  # now calculate at which percentile the current LHA for each house type is in each area
  # all_data[i, "LHA_percentile"] <- 0.25 + ((all_data$p30[i] - all_data$`Lower quartile`[i])/(all_data$Median[i] - all_data$`Lower quartile`[i])) * 0.25

  # Calculate the shortfall between lha_value and actual p30 rent
  all_data[i, "LHA_shortfall"] <- all_data$p30[i] - all_data$lha_value[i]
}

# (all_data$lha_value > all_data$Median) |> sum(na.rm = T)
#
#
#
#
#
#
# p30 <- 400 + (5/25) * (460 - 400)
#
# # P(50000)
# 0.75 + ((50000 - 44607)/(114238 - 44607)) * 0.25
#
#
# `P(412)` <- 0.25 + ((412 - 400)/(460 - 400)) * 0.25
#
# # prob(value) <- p25 + value - p25_value / p50_value - p25_value * 0.25
#

readr::write_csv(all_data, "data/local-housing-allowance/local-housing-allowance.csv")
arrow::write_parquet(all_data, "data/local-housing-allowance/local-housing-allowance.parquet")
