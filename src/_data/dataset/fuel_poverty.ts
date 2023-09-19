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
          value,
          variable_name
        FROM fuel_poverty
        WHERE geography_code in ${arrayToDuckSet(placeCodes)}
      )
      ON "variable_name" USING AVG(value)
      ORDER BY date ASC
      ;`)
  );
}