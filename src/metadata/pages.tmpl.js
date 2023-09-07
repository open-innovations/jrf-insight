export const tags = ['metadata'];
export const layout = 'templates/metadata.njk';

export default function*({ metadata }) {
  let i = 0;
  for (const page of metadata.catalogue) {
    yield {
      url: `/metadata/${page.group}/${i}/`,
      title: page.id,
      id: page.id,
      group: page.group,
      facts: page.facts,
      dimensions: page.dimensions,
    }
    i++;
  }
}