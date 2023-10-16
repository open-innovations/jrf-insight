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
                jblw 
            WHERE 
                geography_code=='${place}' 
            AND 
                variable_name=='percent' 
            AND 
                date=(SELECT MAX(date) FROM jblw)) 
            ON 
                sex 
            USING 
                AVG(value);
        ;`)
    )
  