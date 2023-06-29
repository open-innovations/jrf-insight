// type Place = {
//   name: string;
//   children?: Record<string, string[]>
// }

// interface PlaceGenOptions {
//   places: Record<string, Place>;
// }

// export const layout = "templates/place.njk";

// export const tags = "place";

// export default function* ({ places }: PlaceGenOptions) {
//   for (const [key, place] of Object.entries(places).slice(0, 10)) {

//     // Find geographies that refer to this one
//     const parents = Object.entries(places)
//       .filter(([_k, { children = {} }]) => Object.values(children).flat().includes(key))
//       .map(p => p[0]);

//     yield {
//       url: `/place/${key}/`,
//       key,
//       title: place.name,
//       name: place.name,
//       parents,
//       place,
//     };
//   }
// }