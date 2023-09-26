import { connection, run } from "../../../data/interim/duck.ts";


export const low_income_type_of_individual = (place: string) => {
  return run(
    () => connection.query(`
    PIVOT(SELECT date, "Type of Individual by Age Category", percent FROM hbai_by_age_category WHERE geography_code=='${place}' and income_status=='In low income (below threshold)') ON "Type of Individual by Age Category" USING AVG(percent);
    `)
  );
};

export const get_savings_and_investments_for_place = (place: string) => {
  return run(
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
}

export const low_income_ethnicity = (place: string) => {
  return run(
    () => connection.query(`
      PIVOT (
        SELECT
          date,
          "Ethnic Group of the Head of the Household",
          percent
        FROM hbai_ethnicity
        WHERE geography_code=='${place}'
        AND income_status=='In low income (below threshold)'
      )
      ON "Ethnic Group of the Head of the Household"
      USING AVG(percent);
    `)
  );
};

export const low_income_marital_status = (place: string) => {
  return run(
    () => connection.query(`
      PIVOT (
        SELECT
          date,
          "Marital Status of Adults and Type of Couple in the Family of the Individual",
          percent
        FROM hbai_marital_status
        WHERE geography_code=='${place}'
        AND income_status=='In low income (below threshold)'
      )
      ON "Marital Status of Adults and Type of Couple in the Family of the Individual"
      USING AVG(percent);
    `)
  );
};