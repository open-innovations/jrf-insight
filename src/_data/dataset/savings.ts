import {
  connection,
  runQuery
} from '../../../data/interim/duck.ts';

export const get_savings_and_investments_for_place = (placeCode: string) =>
  runQuery(
    () => connection.query(`
      PIVOT (
        SELECT
          date,
          "Savings and Investments of Adults in the Family of the Individual",
          percent
        FROM hbai_savings_investments
        WHERE geography_code=='${placeCode}'
        AND variable_name=='In low income (below threshold)')
        ON "Savings and Investments of Adults in the Family of the Individual"
        USING AVG(percent)
        ORDER BY date asc;
      `)
  );
