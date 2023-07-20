type PlaceKey = string;
type PlaceDetails = {
  name: string;
  type: string;
  key: string;
}

interface PlaceGenOptions {
  places: {
    list: Array<PlaceKey>;
    lookup: Record<PlaceKey, PlaceDetails>;
  };
}

export const layout = "templates/place.njk";

export const tags = ["place"];

export default function* ({ places }: PlaceGenOptions) {
  for (const place of places.list) {
    const { key, name, type } = places.lookup[place];
    yield {
      url: `/place/${key}/`,
      key,
      title: name,
      type: type,
    };
  }
}
