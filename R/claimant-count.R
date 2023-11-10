# claimant count

# 2021 wards, LAs (upper and lower tier, so need deduping), CAUTHs, RGNs,
# geogs are all of above in NW, NE, YH

cc_url <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=2013265921...2013265923,1648365555...1648365574,1648364517...1648364579,1648368019...1648368030,1648365100...1648365119,1648364580...1648364641,1648368251,1648368252,1648368479,1648368480,1648367418...1648367441,1648362523...1648362548,1648362230...1648362250,1648364657,1648366455...1648366480,1648362251...1648362313,1648366527...1648366543,1648362549...1648362569,1648364245...1648364296,1648367190...1648367234,1648368150...1648368167,1648366052...1648366073,1648366716...1648366738,1648362853...1648362865,1648367921...1648367933,1648367529...1648367545,1648362866...1648362895,1648366509...1648366526,1648361956...1648361992,1648366377...1648366408,1648361993...1648362032,1648367999...1648368018,1648362033...1648362118,1648363404...1648363418,1648368045...1648368058,1648363419...1648363455,1648364899...1648364925,1648368181...1648368192,1648367174...1648367189,1648366994...1648367019,1648363456...1648363469,1648365415...1648365437,1648363470...1648363494,1648365179...1648365202,1648365977...1648365991,1648362119...1648362148,1648362165...1648362186,1648362149...1648362164,1648362187...1648362208,1648362570...1648362595,1648366544...1648366564,1648362596...1648362627,1648365500...1648365520,1648363669...1648363672,1648364963...1648364970,1648365820...1648365826,1648364971...1648364987,1648366335...1648366374,1648367337...1648367352,1648363673...1648363692,1648367353...1648367372,1648365255...1648365273,1648362209...1648362229,1648365793...1648365813,1648367974...1648367998,1648365903...1648365930,1648362437...1648362501,1648364240...1648364244,1648366409...1648366433,1648366565,1648366566,1648367628,1648367629,1648367822,1648367823,1648368447,1648368448,1648362502...1648362522,1807745025...1807745028,1807745030...1807745032,1807745034...1807745076,1811939329...1811939332,1811939334...1811939336,1811939338...1811939402,1853882374,1853882378,1853882379,1853882369,1853882372,1853882370,1853882371&date=latest&gender=0&age=0&measure=1,2&measures=20100"

cc <- readr::read_csv(cc_url, name_repair = tolower)

cc_data <- cc |>
  dplyr::select(date,
                geography_code,
                geography_name,
                variable_name = measure_name,
                value = obs_value) |>
  dplyr::distinct() # we have both upper and lower tier, so unitaries will appear in both - BUT ... looks like as I've called them on the same API call, the API has deduped

# this pivots the variables so we can calculate the population numbers, allowing us to create data for THE NORTH
cc_data1 <- cc_data |>
  tidyr::pivot_wider(names_from = "variable_name") |>
  dplyr::filter(substr(geography_code, 1, 3) == "E12") |>
  dplyr::mutate(
    `Residents aged 16-64` =
      `Claimant count` / (`Claimants as a proportion of residents aged 16-64` / 100)) |>
  dplyr::group_by(date) |>
  dplyr::summarise(
    `Claimant count` = sum(`Claimant count`),
    `Residents aged 16-64` = sum(`Residents aged 16-64`)
  ) |>
  dplyr::mutate(
    geography_code = "E12999901",
    geography_name = "The North",
    `Claimants as a proportion of residents aged 16-64` =
      (`Claimant count` / `Residents aged 16-64` * 100) |> round(1)) |>
  dplyr::select(date, geography_code, geography_name, `Claimant count`,
                `Claimants as a proportion of residents aged 16-64`) |>
  tidyr::pivot_longer(cols = dplyr::starts_with("Claimant"),
                      names_to = "variable_name")

cc_out <- dplyr::bind_rows(cc_data, cc_data1)

readr::write_csv(cc_out, "data/claimant-count/claimant-count.csv")
arrow::write_parquet(cc_out, "data-mart/claimant-count/claimant-count.parquet")
