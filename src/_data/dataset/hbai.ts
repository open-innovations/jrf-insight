import { connection, run, makeFakeCSV } from "../../../data/interim/duck.ts";


export const low_income_type_of_individual = (place: string) => {
  const data = run(
    () => connection.query(`
      PIVOT (
        SELECT "date", "Type of Individual by Age Category", percent
        FROM hbai_by_age_category
        WHERE geography_code=='${place}'
        AND income_status=='In low income (below threshold)'
      )
      ON "Type of Individual by Age Category"
      USING AVG(percent);
    `)
  );
  return makeFakeCSV(data);
};
