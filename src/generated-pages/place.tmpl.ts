type PlaceKey = string;
type PlaceDetails = {
  name: string;
  type: string;
  key: string;
  ancestors: string[];
  children: string[];
  parents: string[];
}

interface PlaceGenOptions {
  places: {
    list: Array<PlaceKey>;
    placeLookup: (place: string) => PlaceDetails;
  };
  nav: {
    places: Array<PlaceKey>;
  }
}

export const layout = "templates/place.njk";

export const tags = ["place"];

export default function* ({ places, nav }: PlaceGenOptions) {
  for (const place of places.list) {
    const { key, name, type, children, parents, ancestors } = places.placeLookup(place);
    const navOrder = nav.places.findIndex(x => x === key) + 1 || undefined;
    yield {
      url: `/place/${key}/`,
      key,
      title: name,
      type: type,
      navOrder,
      relations: {
        ancestors, parents, children,
      }
    };
  }
}
