export default function ({ search, comp }) {
  const places = search.pages('place navOrder>=0', 'navOrder').map(({ title, url }) => ({ title, url }));
  const spotlights = search.pages('spotlight main', 'title').map(({ title, target }) => ({ title, url: target }));

  const items = [
    { title: 'Spotlights', children: spotlights },
    { title: 'Places', children: places },
    { title: 'Data', url: '/metadata/' },
    { title: 'About', url: '/about/' },
    // TODO make this float to the right and have a magnifying glass icon
    { title: 'Search', url: '/search/' },
  ];

  return comp.menu({ items, classes: 'page-flow' })
}