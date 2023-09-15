import { connection, run } from "../../../data/interim/duck.ts";

export const get_claimants_proportion_for_place = (placeCode: string) =>
  run(
    () =>
      connection.query(`
        SELECT value
        FROM claimants
        WHERE geography_code=='${placeCode}'
        AND variable_name=='Claimants as a proportion of residents aged 16-64';
      `)
  );
