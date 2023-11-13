import { connection, runQuery } from "../../../data/interim/duck.ts";

export const council_tax = (place: string) =>
  runQuery(
    () => connection.query(`
      PIVOT (
        SELECT
          strftime(date, '%x') as date,
          CAST(value as FLOAT) AS value,
          variable_name
        FROM './data-mart/council-tax-support/council-tax-support.parquet'
        WHERE geography_code=='${place}'
      )
      ON variable_name
      USING AVG(value)
      ORDER BY date DESC LIMIT 30;
    `)
);
