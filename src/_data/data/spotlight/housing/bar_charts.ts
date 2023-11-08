import { connection, runQuery } from '../../../../../data/interim/duck.ts';

export const current_rental_prices_for_place = (place: string) => {
  try {

    return runQuery(
      () => connection.query(`
        PIVOT (
          SELECT 
            geography_code,
            property_code,
            value
          FROM './data-mart/rental-prices/most_recent_rental_prices.parquet'
          WHERE geography_code == '${place}'
        )
        ON geography_code
        USING FSUM(value);
      `)
    );
  } catch (e) {
    console.error(`Could not get rental prices for ${place}`);
    console.error(e.message);
    return []
  }
}
