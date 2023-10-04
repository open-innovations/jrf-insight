CREATE OR REPLACE TABLE current_rental_prices AS SELECT * FROM read_csv_auto('./data/rental-prices/most_recent_rental_prices.csv');
CREATE OR REPLACE TABLE claimants AS SELECT * FROM read_csv_auto('./data/claimant-count/claimant-count.csv');
CREATE OR REPLACE TABLE house_prices AS SELECT * FROM read_csv_auto('./data/house-prices/house-prices.csv');
CREATE OR REPLACE TABLE fsm AS SELECT * FROM read_csv_auto('./data/school-pupils-characteristics/free_school_meals.csv');

CREATE OR REPLACE TABLE personal_wellbeing AS SELECT * FROM read_csv_auto('./data/personal-wellbeing/wellbeing-local-authority.csv');
CREATE OR REPLACE TABLE lm AS SELECT * FROM read_csv_auto('./data/labour-market/labour-market.csv', nullstr='NA');
CREATE OR REPLACE TABLE fuel_poverty AS SELECT * FROM read_csv_auto('./data/fuel-poverty/fuel-poverty.csv');

CREATE OR REPLACE TABLE ashe_weekly_earning AS SELECT * from read_csv_auto('./data/ashe/weekly-earnings.csv', nullstr='NA');

CREATE OR REPLACE TABLE hbai_by_age_category AS SELECT * FROM read_csv_auto('./data/hbai/by_age_category.csv');
CREATE OR REPLACE TABLE hbai_savings_investments AS SELECT * FROM read_csv_auto('./data/hbai/by_savings_and_investments.csv');
CREATE OR REPLACE TABLE hbai_ethnicity AS SELECT * FROM read_csv_auto('./data/hbai/by_ethnic_group.csv');
CREATE OR REPLACE TABLE hbai_marital_status AS SELECT * FROM read_csv_auto('./data/hbai/by_marital_status.csv');
CREATE OR REPLACE TABLE hbai_tenure_type AS SELECT * FROM read_csv_auto('./data/hbai/by_tenure_type.csv');
CREATE OR REPLACE TABLE rent_to_earnings AS SELECT * FROM read_csv_auto('./data/ashe/rent-earning-ratio.csv');
CREATE OR REPLACE TABLE gender_pay_gap AS SELECT * FROM read_csv_auto('./data/gender-pay-gap/gender-pay-gap.csv', header=True);
CREATE OR REPLACE TABLE esm AS SELECT * FROM read_csv_auto('./playground/modelling/economic_insecurity.csv');

CREATE OR REPLACE TABLE cts AS SELECT * FROM read_csv_auto("./data/council-tax-support/council-tax-support.csv", nullstr='NA');