export const layout = 'templates/spotlight/base.njk';

type SpotlightData = {
  name: string,
}

export default function* ({ spotlights, places }: {
  spotlights: Record<string, SpotlightData>,
  places: string[],
}) {
  for (const [spotlight, spotlightData] of Object.entries(spotlights)) {
    const { name } = spotlightData;
    yield {
      url: `/spotlight/${spotlight}/`,
      layout: 'templates/redirect.njk',
      target: `/spotlight/${spotlight}/E12999901/`,
    };

    for (const place of places.list) {
      yield {
        url: `/spotlight/${spotlight}/${place}/`,
        title: name,
        spotlight: spotlight,
        geography: place,
      };
    }
  }
}