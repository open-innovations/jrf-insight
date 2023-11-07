import {
  arrayToDuckSet,
  connection,
  run
} from "../../../data/interim/duck.ts";

const tableToObjectTree = <T>(result: { [x: string]: Omit<T, 'variable_name'> }, { variable_name, ...rest }: { variable_name: string, rest: Omit<T, 'variable_name'> }) =>
({ ...result, 
  [variable_name]: rest,
});


export function weekly_earnings(placeList: string[]) {
  return run(
    () => connection.query(`
      PIVOT (
        SELECT *
        FROM ashe_weekly_earning
        WHERE geography_code IN ${arrayToDuckSet(placeList)}
      )
      ON variable_name USING SUM(value)
      ;
    `)
  );
}

export const range = connection.query(`
  SELECT
    variable_name,
    FLOOR(MIN(CAST(value AS FLOAT))) AS min,
    CEIL(MAX(value)) AS max,
  FROM ashe_weekly_earning
  GROUP BY variable_name
  ;
`).reduce(tableToObjectTree, {});

export function rent_to_earnings(placeList: string[]) {
  return run(
    () => connection.query(`
        SELECT value, geography_code, geography_name
        FROM './data-mart/ashe/rent-earning-ratio.parquet'
        WHERE geography_code
        IN ${arrayToDuckSet(placeList)}
        AND variable_name=='lq_rent_to_lq_earnings';
    `)
  );
};