import { connection, run } from "../../../data/interim/duck.ts";

export const get_claimants_proportion_for_place = (placeCode: string) => {
  const data = run(
    () =>
      connection.query(`
        SELECT CAST(value as DOUBLE) as value
        FROM claimants
        WHERE geography_code=='${placeCode}'
        AND variable_name=='Claimants as a proportion of residents aged 16-64';
      `)
  );
  console.log(data);
  return data;
}