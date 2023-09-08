export const tags = ['metadata'];
export const layout = 'templates/metadata.njk';

export default function*({ metadata }) {
  for (const dataset of metadata.catalogue) {
    const { id, group } = dataset;
    yield {
      url: `/metadata/${group}/${id}/`,
      title: id,
      ...dataset,
    }
  }
}