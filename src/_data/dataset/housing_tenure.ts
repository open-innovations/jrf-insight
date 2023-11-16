import { connection } from "../../../data/interim/duck.ts";

export const by_geo = (place: string) => {
  const result = connection.query(`
  PIVOT (
    SELECT
      DATE AS date,
      TENURE AS tenure,
      VALUE AS value
    FROM './data-mart/housing-tenure/housing-tenure.parquet'
    WHERE GEOGRAPHY_CODE=='${place}'
  )
  ON tenure
  USING first(value)
  GROUP BY date
  ORDER BY date;
  `);
  return result;
}