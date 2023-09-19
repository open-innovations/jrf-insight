import jsonLoader from "lume/core/loaders/json.ts";
import lume from "lume/mod.ts";
import esbuild from "lume/plugins/esbuild.ts";
// import base_path from "lume/plugins/base_path.ts";
import base_path from "./patch/lume/base_path.ts";
import date from "lume/plugins/date.ts";
// import inline from "lume/plugins/inline.ts";
// import pagefind from "lume/plugins/pagefind.ts";
import pagefind from "./patch/lume/pagefind.ts";
import postcss from "lume/plugins/postcss.ts";
// import metas from "lume/plugins/metas.ts";
import csvLoader from "https://deno.land/x/oi_lume_utils@v0.3.1/loaders/csv-loader.ts";
import oiViz from "https://deno.land/x/oi_lume_viz@v0.12.3/mod.ts";
import svgo from "lume/plugins/svgo.ts";
import metas from "./patch/lume/metas.ts";
// import autoDependency from "https://deno.land/x/oi_lume_utils@v0.3.0/processors/auto-dependency.ts";
import autoDependency from "./patch/auto-dependency.ts";
import { makeFakeCSV } from "./data/interim/duck.ts";

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

site.addEventListener("beforeBuild", () => {
  console.log("The build is about to start");
  console.time("dataLoad");
});

site.addEventListener("beforeRender", () => {
  console.timeEnd("dataLoad");
  console.log("All pages and data loaded");
})

// TODO make this more efficient:
site.process([".html"], autoDependency);

// Add broken link class if running in SMALL_SITE mode
if (Deno.env.get('SMALL_SITE') !== undefined) {
  site.process(['.html'], (page) => {
    page.document?.querySelectorAll('a[href]').forEach(link => {
      const target = site.url(link.getAttribute('href'));
      if (
        !target.startsWith('/') ||
        target.startsWith('//') ||
        target.startsWith('..')
      ) return;
      if (page.data.search.page(`url=${target}`)) return;
      link.classList.add('broken');
    });
  });  
}

site.loadData([".csv"], csvLoader);
site.loadData([".geojson"], jsonLoader);

site.use(oiViz({
  font: {
    family: "chaparral-pro,sans-serif",
  },
}));
// TODO make this more efficient:
// site.use(inline());
site.use(date());
site.use(base_path());
site.use(metas());
site.use(postcss());
site.use(svgo());
site.use(esbuild());
site.use(pagefind({
  indexing: {
    glob: "{index.html,spotlight/*/E12999901/index.html,place/**/*.html,metadata/**/*.html}",
  }
}));

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
site.filter("localise", (num: number) => num.toLocaleString());
site.filter(
  "percentagize",
  (num: number, ref, points = 1) => (num * 100 / ref).toFixed(points) + "%",
);

site.filter("values", (o) => Object.values(o));
site.filter("pick", (list, keys) => keys.map(i => list[i] || null))

site.filter("fake_csv", makeFakeCSV);
site.filter("flat", (a: unknown[]) => a.flat());

export default site;
