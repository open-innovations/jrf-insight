export const tags = ['metadata'];
export const layout = 'templates/metadata.njk';

export default function*({ metadata }) {
  for (const entry of metadata.catalogue) {
    const { dataset, view, name } = entry;
    const missingSpecs = [
      name === null, 
      entry.dimensions === null,
      entry.facts === null
    ].filter(x => x).length;
    yield {
      url: `/metadata/${dataset}/${view}/`,
      title: name || `${dataset} - ${view}`,
      missing_specs: missingSpecs,
      ...entry,
    }
  }
}