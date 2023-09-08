export const layout = 'templates/spotlight.njk';

export const tags = ['spotlight']

type SpotlightData = {
  name: string;
  draft: boolean;
}

export default function* ({ spotlights, places }: {
  spotlights: Record<string, SpotlightData>,
  places: string[],
}) {
  for (const [spotlight, spotlightData] of Object.entries(spotlights)) {
    if (spotlightData.draft === true) continue;
    const { name } = spotlightData;
    yield {
      url: `/spotlight/${spotlight}/`,
      tags: ['main'],
      title: name,
      spotlight: spotlight,
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