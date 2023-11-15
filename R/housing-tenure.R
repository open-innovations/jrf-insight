# housing-tenure

data <- list()
data$`1981` <- readr::read_csv("https://www.nomisweb.co.uk/api/v01/dataset/NM_66_1.data.csv?geography=1946157057...1946157128&date=latest&cell=2814,2819,2824,2829,2834,2839,2844,2849,2854&measures=20100")

data$`1991` <- readr::read_csv("https://www.nomisweb.co.uk/api/v01/dataset/NM_35_1.data.csv?geography=1946157057...1946157128&date=latest&cell=205455617,205455873,205456129,205456385,205456641,205456897,205457153,205457409,205457665&measures=20100")

data$`2001` <- readr::read_csv("https://www.nomisweb.co.uk/api/v01/dataset/NM_1663_1.data.csv?date=latest&geography=1946157057...1946157128&c_tenhuk11=0,1,4,5,8,13&measures=20100")

data$`2011` <- readr::read_csv("https://www.nomisweb.co.uk/api/v01/dataset/NM_619_1.data.csv?date=latest&geography=1946157057...1946157128&rural_urban=0&cell=0,100,3,200,300,8&measures=20100")

data$`2021` <- readr::read_csv("https://www.nomisweb.co.uk/api/v01/dataset/NM_2072_1.data.csv?date=latest&geography=1778384897...1778384901,1778384941,1778384950,1778385143...1778385146,1778385159,1778384902...1778384905,1778384942,1778384943,1778384956,1778384957,1778385033...1778385044,1778385124...1778385138,1778384906...1778384910,1778384958,1778385139...1778385142,1778385154...1778385158&c2021_tenure_9=0,1001...1004,8&measures=20100")

out <- lapply(data, function(x) {
  if ("C_TENHUK11_NAME" %in% names(x)) {
    x <- x |>
      dplyr::rename(CELL_NAME = C_TENHUK11_NAME)
  }
  if ("C2021_TENURE_9_NAME" %in% names(x)) {
    x <- x |>
      dplyr::rename(CELL_NAME = C2021_TENURE_9_NAME)
  }

  x <- x |>
    dplyr::mutate(TENURE = dplyr::case_when(
      grepl("All", CELL_NAME) ~ "All tenures",
      grepl("Own", CELL_NAME) ~ "Owner occupied",
      grepl("private|job|business|employment|Private rented", CELL_NAME) ~ "Private rented",
      grepl("housing association|LA|Scottish Homes|Housing assoc|Council|Social rented", CELL_NAME) ~ "Social rented",
      TRUE ~ "Other"
    )) |>
    dplyr::select(DATE, GEOGRAPHY_CODE, GEOGRAPHY_NAME,
                  TENURE, OBS_VALUE) |>
    dplyr::group_by(DATE, GEOGRAPHY_CODE, GEOGRAPHY_NAME,
                    TENURE) |>
    dplyr::summarise(VALUE = sum(OBS_VALUE, na.rm = TRUE))
}) |>
  dplyr::bind_rows()

readr::write_csv(out, "data/housing-tenure/housing-tenure.csv")
arrow::write_parquet(out, "data-mart/housing-tenure/housing-tenure.parquet")



