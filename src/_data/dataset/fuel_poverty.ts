import {
  arrayToDuckSet,
  connection,
  run,
} from '../../../data/interim/duck.ts';

export const get_fuel_poverty_for_place = (placeCode: string) => get_fuel_poverty([placeCode])

export function get_fuel_poverty(placeCodes: string[]) {
  if (!(placeCodes.length > 0)) {
    return [];
  }
  return run(
    () => connection.query(`
      PIVOT (
        SELECT
          date,
          geography_code,
          geography_name,
          value,
          variable_name
        FROM './data-mart/fuel-poverty/fuel-poverty.parquet'
        WHERE geography_code in ${arrayToDuckSet(placeCodes)}
      )
      ON "variable_name" USING AVG(value)
      ORDER BY date ASC
      ;`)
  );
}

export const range = () => run(
  () => connection.query(`SELECT
      FLOOR(MIN(value)) as min,
      CEIL(MAX(value)) as max
    FROM './data-mart/fuel-poverty/fuel-poverty.parquet'
    WHERE variable_name=='Proportion of households fuel poor \(\%\)';
  `).shift()
)
