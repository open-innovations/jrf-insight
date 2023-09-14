import {
  connection,
  runQuery
} from '../../../data/interim/duck.ts';

export const get_economic_activity_for_place = (placeCode: string) =>
  runQuery(
    () => connection.query(`
      PIVOT (
        SELECT
          strftime(date, '%x') as date,
          CAST(value AS decimal(5,2)) as value,
          variable_name,
          geography_code
        FROM lm
        WHERE "geography_code"=='${placeCode}'
        AND "variable_name" IN (
          'Unemployment rate - aged 16-64',
          '% who are economically inactive - aged 16-64'
        )
      )
      ON "variable_name" USING AVG(value)
      ORDER BY date ASC
      ;`)
  )
