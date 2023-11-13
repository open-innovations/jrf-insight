import { connection, runQuery } from "../../../data/interim/duck.ts";

export const getHousePrices = (place: string) =>
  runQuery(
    () => connection.query(`
      SELECT
        strftime(date, '%x') as date,
        CAST(value AS FLOAT) as value
      FROM './data-mart/house-prices/house-prices.parquet'
      WHERE geography_code=='${place}'
      AND variable_name=='Median house price'`)
  );
