export default function ({ search, comp }) {
  const places = search.pages('place navOrder>=0', 'navOrder').map(({ title, url }) => ({ title, url }));
  const spotlights = search.pages('spotlight main', 'title').map(({ title, target }) => ({ title, url: target }));

  const items = [
    { title: 'Places', children: places },
    { title: 'Spotlights', children: spotlights },
  ];

  return comp.menu({ items, classes: 'page-flow' })
}