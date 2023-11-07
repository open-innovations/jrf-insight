import { connection, runQuery } from '../../../../../data/interim/duck.ts';

const getRentalPrices = () => runQuery(
  () => connection.query(`
      PIVOT
      './data-mart/rental-prices/most_recent_rental_prices.parquet'
      ON geography_code
      USING SUM(value)
  `),
);

export const current_rental_prices = getRentalPrices();

export const current_rental_prices_for_place = (place: string) =>
  runQuery(
    () =>
      connection.query(`
        PIVOT (
          SELECT *
          FROM 
          './data-mart/rental-prices/most_recent_rental_prices.parquet'
          WHERE geography_code == '${place}'
        )
        ON geography_code
        USING SUM(value);
      `),
  );
