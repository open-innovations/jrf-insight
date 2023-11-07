import { connection, run} from "../../../data/interim/duck.ts";


export const low_income_by_age_category = (place: string) => {
  return run(
    () => connection.query(`
    PIVOT (
      SELECT 
        date, 
        "Type of Individual by Age Category", 
        percent 
      FROM './data-mart/hbai/by_age_category.parquet'
      WHERE geography_code=='${place}' 
      AND ahc_income_status='In low income (below threshold)' 
      AND bhc_income_status='Not in low income (at or above threshold)'
    ) 
    ON "Type of Individual by Age Category" USING AVG(percent);
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
        FROM './data-mart/hbai/by_savings_and_investments.parquet'
        WHERE geography_code=='${place}'
        AND ahc_income_status='In low income (below threshold)' 
        AND bhc_income_status='Not in low income (at or above threshold)'
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
        FROM './data-mart/hbai/by_ethnic_group.parquet'
        WHERE geography_code=='${place}'
        AND ahc_income_status='In low income (below threshold)' 
        AND bhc_income_status='Not in low income (at or above threshold)'
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
        FROM './data-mart/hbai/by_marital_status.parquet'
        WHERE geography_code=='${place}'
        AND ahc_income_status='In low income (below threshold)' 
        AND bhc_income_status='Not in low income (at or above threshold)'
      )
      ON "Marital Status of Adults and Type of Couple in the Family of the Individual"
      USING AVG(percent);
    `)
  );
};

export const low_income_tenure_type = (place: string) => {
  return run(
    () => connection.query(`
      PIVOT (
        SELECT
          date,
          "Tenure Type of the Household of the Individual",
          percent
        FROM './data-mart/hbai/by_tenure_type.parquet'
        WHERE geography_code=='${place}'
        AND ahc_income_status='In low income (below threshold)' 
        AND bhc_income_status='Not in low income (at or above threshold)'
      )
      ON "Tenure Type of the Household of the Individual"
      USING AVG(percent);
    `)
  );
};

export const effect_of_house_prices_tenure = (place: string) => {
  return run(
    () => connection.query(`
    SELECT 
      "Tenure Type of the Household of the Individual", 
      AVG(
        CASE 
          WHEN ahc_income_status='In low income (below threshold)' 
          AND bhc_income_status='In low income (below threshold)' 
          THEN percent 
        END
        )
      AS percent_ahc_and_bhc, 
      AVG(
        CASE 
          WHEN ahc_income_status='In low income (below threshold)' 
          AND bhc_income_status='Not in low income (at or above threshold)' 
          THEN percent 
        END
        ) 
      AS percent_ahc_only 
    FROM './data-mart/hbai/by_tenure_type.parquet'
    WHERE geography_code=='${place}'
    AND date==(SELECT MAX(date) FROM './data-mart/hbai/by_tenure_type.parquet') 
    GROUP BY 
      "Tenure Type of the Household of the Individual"
    `)
  );
};