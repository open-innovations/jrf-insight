import {
    connection
  } from "../../../data/interim/duck.ts";

export const dwelling_stock = (place: string) => {
    const result = connection.query(`
          PIVOT(
            SELECT date, type_of_tenure, value
            FROM './data-mart/dwelling-stock/dwelling-stock.parquet'
            WHERE geography_code=='${place}'
          )
          ON type_of_tenure
          USING MAX(value);
        `);
  return result.map(x => ({
    ...x,
    'Owner occupied': x['Owned Outright'] + x['Owned with Mortgage or Loan']
  }));
};