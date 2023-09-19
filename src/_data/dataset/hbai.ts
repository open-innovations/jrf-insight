import { connection, run, makeFakeCSV } from "../../../data/interim/duck.ts";


export const low_income_type_of_individual = (place: string) => {
  const data = run(
    () => connection.query(`
      PIVOT (
        SELECT
          "date",
          "Type of Individual by Age Category",
          percent
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

export const get_savings_and_investments_for_place = (place: string) => {
  const data = run(
    () => connection.query(`
      PIVOT (
        SELECT
          date,
          "Savings and Investments of Adults in the Family of the Individual",
          percent
        FROM hbai_savings_investments
        WHERE geography_code=='${place}'
        AND income_status=='In low income (below threshold)'
      )
      ON "Savings and Investments of Adults in the Family of the Individual"
      USING AVG(percent)
      ORDER BY date asc;
    `)
  );
  return makeFakeCSV(data);
}