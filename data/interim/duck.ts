// To get this to work, libduckdb.so needs to be downloaded from
import { open } from "https://cdn.jsdelivr.net/gh/dringtech/duckdb@b9cb4d0/mod.ts";

const db = open(":memory:");
export const connection = db.connect();

/**
 * SETUP DATA
 */
const setupSql = await Deno.readTextFile(new URL(import.meta.resolve("./load-db.sql")).pathname);
connection.query(setupSql);


/*
 * ACCESS FUNCTIONS
 */
export const getHousePrices = (place: string) =>
  runQuery(
    () => connection.query(`SELECT date, CAST(value AS FLOAT) as value FROM house_prices WHERE geography_code=='${place}' AND variable_name=='Median house price'`).map(formatDate),
  );

export const freeSchoolMeals = (place: string) =>
  runQuery(
    () => connection.query(`PIVOT (SELECT date, "phase_type_grouping", value FROM fsm WHERE geography_code=='${place}') ON "phase_type_grouping" USING AVG(value) ORDER BY date ASC;`)
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

export const council_tax = (place: string) =>
  runQuery(
    () => connection.query(`PIVOT(SELECT strftime(date, '%x') as date, CAST(value as FLOAT) AS value, variable_name FROM cts WHERE geography_code=='${place}') on variable_name using AVG(value) ORDER BY date DESC LIMIT 30;`)
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
    // return [];
    throw e;
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

export const arrayToDuckSet = (a: string[]) => `(${a.map(e => `'${e}'`).join(',')})`