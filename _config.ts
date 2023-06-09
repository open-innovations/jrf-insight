import lume from "lume/mod.ts";
import jsonLoader from "lume/core/loaders/json.ts";
import base_path from "lume/plugins/base_path.ts";
import esbuild from "lume/plugins/esbuild.ts";
import metas from "lume/plugins/metas.ts";
import postcss from "lume/plugins/postcss.ts";
import autoDependency from "https://deno.land/x/oi_lume_utils@v0.3.0/processors/auto-dependency.ts";
import csvLoader from "https://deno.land/x/oi_lume_utils@v0.3.0/loaders/csv-loader.ts";
import oiCharts from "oi-lume-charts/mod.ts";
import svgo from "lume/plugins/svgo.ts";
import inline from "lume/plugins/inline.ts";

const site = lume({
  src: "./src",
  location: new URL("https://open-innovations.github.io/jrf-insight/"),
  components: {
    cssFile: "/assets/css/components.css",
    jsFile: "/assets/js/components.js",
  },
}, {
  search: {
    returnPageData: true,
  }
});

site.process([".html"], autoDependency);
site.loadData([".csv"], csvLoader);
site.loadData([".geojson"], jsonLoader);

site.use(oiCharts({
  font: {
    family: "chaparral-pro,sans-serif",
  },
}));
site.use(inline());
site.use(base_path());
site.use(metas());
site.use(postcss());
site.use(svgo());
site.use(esbuild());

site.remoteFile(
  "/assets/images/jrf_logo.svg",
  "https://www.jrf.org.uk/sites/all/themes/jrf/images/jrf_logo.svg",
);
site.remoteFile(
  "/assets/images/oi_logo.svg",
  "https://open-innovations.org/resources/images/logos/oi-square-11.svg",
);

// filters
site.filter('keys', o => Object.keys(o));
site.filter("values", (o: Record<string, unknown>) => {
  if (typeof o === 'undefined') return undefined;
  return Object.values(o)
});
site.filter("flatten", (arr: Array<unknown>) => {
  if (!Array.isArray(arr)) return undefined;
  return arr.flat()
})

site.filter("getattr", (a: Record<string, unknown>[], attr: string) => a.map(x => x[attr]))
site.filter("max", (arr: number[]) => (Math.max(...arr)));
site.filter("min", (arr: number[]) => (Math.min(...arr)));

export default site;
