import {
  connection,
  runQuery
} from '../../../data/interim/duck.ts';

export const get_fuel_poverty_for_place = (placeCode: string) =>
  runQuery(
    () => connection.query(`
      PIVOT (
        SELECT
          date,
          geography_code,
          value,
          variable_name
        FROM fuel_poverty
        WHERE geography_code=='${placeCode}'
      )
      ON "variable_name" USING AVG(value)
      ORDER BY date ASC
      ;`)
  )
