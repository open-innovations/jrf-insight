export const layout = 'templates/spotlight/base.njk';

export default function* ({ spotlights, places }) {
  for (const spotlight of spotlights) {
    yield {
      url: `/spotlight/${spotlight}/`,
      layout: 'templates/redirect.njk',
      target: `/spotlight/${spotlight}/the_north/`,
    };

    for (const place of Object.keys(places)) {
      yield {
        url: `/spotlight/${spotlight}/${place}/`,
        title: `Spotlight page for ${spotlight} at ${places[place].name} scale`,
        spotlight: spotlight,
        geography: place,
      };
    }
  }
}