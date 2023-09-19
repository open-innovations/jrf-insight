import {
  arrayToDuckSet,
  connection,
  run
} from "../../../data/interim/duck.ts";

export function weekly_earnings(placeList: string[]) {
  return run(
    () => connection.query(`
      SELECT *
      FROM ashe_weekly_earning
      WHERE geography_code IN ${arrayToDuckSet(placeList)};
    `)
  );
}