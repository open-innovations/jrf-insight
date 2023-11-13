import {
    connection,
    run,
  } from '../../../data/interim/duck.ts';
  
  export const by_hours_by_sex = (place: string) =>
    run(
      () => connection.query(`
        PIVOT(
            SELECT 
                date, 
                CAST(value as DOUBLE) as value, 
                geography_code, 
                geography_name, 
                sex, 
                hours 
            FROM 
                './data-mart/jobs-below-living-wage/jobs-below-living-wage.parquet'
            WHERE 
                geography_code=='${place}' 
            AND 
                variable_name=='percent' 
            AND 
                date=(SELECT MAX(date) FROM './data-mart/jobs-below-living-wage/jobs-below-living-wage.parquet')
        ) 
        ON 
            sex 
        USING 
            AVG(value);
        ;`)
    )
  