import { connection, runQuery } from "../../../data/interim/duck.ts";

export const freeSchoolMeals = (place: string) =>
  runQuery(
    () => connection.query(`
      PIVOT (
        SELECT
          date,
          "phase_type_grouping",
          value
        FROM fsm
        WHERE geography_code=='${place}'
      )
      ON "phase_type_grouping"
      USING AVG(value)
      ORDER BY date ASC;
    `)
  );

