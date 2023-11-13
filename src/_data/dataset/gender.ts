import {
    connection,
    run
  } from "../../../data/interim/duck.ts";

export const gender_pay_gap = (place: string) => {
    return run(
        () => connection.query(`
        PIVOT (
          SELECT 
            hours, 
            variable_name, 
            CAST(value AS DOUBLE) AS value 
          FROM './data-mart/gender-pay-gap/gender-pay-gap.parquet' 
          WHERE geography_code=='${place}'
        )
        ON variable_name
        USING AVG(value);
        `)
    );
};