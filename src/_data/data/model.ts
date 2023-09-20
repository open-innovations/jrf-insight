import { connection, run, makeFakeCSV, arrayToDuckSet } from "../../../data/interim/duck.ts";


export const econonmic_insecurity = (children: string[]) => {
  if (!(children.length > 0)) {
    return [];
  }
  return run(
    () => connection.query(`
    SELECT * FROM esm WHERE geography_code IN ${arrayToDuckSet(children)};
    `)
  );
};