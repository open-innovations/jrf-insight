export const layout = 'templates/spotlight/base.njk';

export default function* ({ spotlights, places }) {
  for (const [spotlight, spotlightData] of Object.entries(spotlights)) {
    const { name } = spotlightData;
    yield {
      url: `/spotlight/${spotlight}/`,
      layout: 'templates/redirect.njk',
      target: `/spotlight/${spotlight}/E12999901/`,
    };

    for (const place of Object.keys(places)) {
      yield {
        url: `/spotlight/${spotlight}/${place}/`,
        title: name,
        geography_name: places[place].name,
        spotlight: spotlight,
        geography: place,
      };
    }
  }
}