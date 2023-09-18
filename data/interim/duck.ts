// To get this to work, libduckdb.so needs to be downloaded from
import { open } from "https://cdn.jsdelivr.net/gh/dringtech/duckdb@b9cb4d0/mod.ts";

const db = open(":memory:");
export const connection = db.connect();

/**
 * SETUP DATA
 */
connection.query(`
  CREATE TABLE current_rental_prices AS SELECT * FROM read_csv_auto('./data/interim/current_rental_prices.csv');
  CREATE TABLE claimants AS SELECT * FROM read_csv_auto('./data/claimant-count/claimant-count.csv');
  CREATE TABLE house_prices AS SELECT * FROM read_csv_auto('./data/interim/house_prices.csv');
  CREATE TABLE fsm AS SELECT * FROM read_csv_auto('./data/interim/free_school_meals.csv');
  CREATE TABLE personal_wellbeing AS SELECT * FROM read_csv_auto('./data-raw/personal-wellbeing/wellbeing-local-authority.csv');
  CREATE TABLE lm AS SELECT * FROM read_csv_auto('./data/labour-market/labour-market.csv');
  CREATE TABLE fuel_poverty AS SELECT * FROM read_csv_auto('./data/fuel-poverty/fuel-poverty.csv');

  CREATE TABLE hbai_by_age_category AS SELECT * FROM read_csv_auto('./data/interim/hbai_age_category.csv');
  CREATE TABLE hbai_savings_investments AS SELECT * FROM read_csv_auto('./data/interim/savings_investments.csv');
`);

/*
 * ACCESS FUNCTIONS
 */
export const getRentalPrices = () =>
  runQuery(
    () => connection.query("SELECT * FROM current_rental_prices;"),
  );

export const getCurrentRentalPricesForPlace = (place: string) =>
  runQuery(
    () =>
      connection.query(
        `SELECT property_code, ${place} FROM current_rental_prices;`,
      ),
  );

export const getHousePrices = () =>
  runQuery(
    () => connection.query("SELECT * FROM house_prices;").map(formatDate),
  );

export const getHousePricesForPlace = (place: string) =>
  runQuery(
    () =>
      connection.query(`SELECT date, ${place} FROM house_prices;`).map(
        formatDate,
      ),
  );

export const freeSchoolMeals = (place: string) =>
  runQuery(
    () => connection.query(`PIVOT (SELECT "date", "phase", fsm_eligible_percent FROM fsm WHERE geography_code=='${place}') ON "phase" USING AVG(fsm_eligible_percent);`)
  );

export const happiness = (place: string) =>
  runQuery(
    () => connection.query(`PIVOT (SELECT Time, Estimate, v4_3 FROM personal_wellbeing WHERE "administrative-geography"=='${place}' AND "MeasureOfWellbeing"=='Happiness') ON Estimate USING AVG(v4_3) ORDER BY Time;`)
);
export const anxiety = (place: string) =>
  runQuery(
    () => connection.query(`PIVOT (SELECT Time, Estimate, v4_3 FROM personal_wellbeing WHERE "administrative-geography"=='${place}' AND "MeasureOfWellbeing"=='Anxiety') ON Estimate USING AVG(v4_3) ORDER BY Time;`)
);
export const worthwhile = (place: string) =>
  runQuery(
    () => connection.query(`PIVOT (SELECT Time, Estimate, v4_3 FROM personal_wellbeing WHERE "administrative-geography"=='${place}' AND "MeasureOfWellbeing"=='Worthwhile') ON Estimate USING AVG(v4_3) ORDER BY Time;`)
);
export const life_satisfaction = (place: string) =>
  runQuery(
    () => connection.query(`PIVOT (SELECT Time, Estimate, v4_3 FROM personal_wellbeing WHERE "administrative-geography"=='${place}' AND "MeasureOfWellbeing"=='Life satisfaction') ON Estimate USING AVG(v4_3) ORDER BY Time;`)
);

/**
 * Utility functions below
 */
function cleanup() {
  console.log("Closing duckDB!");
  connection.close();
  db.close();
}

addEventListener("unload", cleanup);

type QueryResult = Record<string, unknown>[];

export function run(query: () => QueryResult) {
  let data;
  try {
    data = query();
  } catch (e) {
    console.error(e);
    return [];
  }
  return data;
}

export function runQuery(query: () => QueryResult) {
  return makeFakeCSV(run(query));
}

export function makeFakeCSV(rows: QueryResult) {
  if (rows.length === 0) {
    return {
      names: [],
      rows,
    };
  }
  const names = Object.keys(rows[0]);
  return {
    names,
    rows,
  };
}

const formatDate = (
  { date, ...rest }: { date: string | number; [k: string]: unknown },
) => ({
  date: new Date(date).toISOString().split("T").shift(),
  ...rest,
});
