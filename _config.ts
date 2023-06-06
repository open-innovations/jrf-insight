import lume from "lume/mod.ts";
import base_path from "lume/plugins/base_path.ts";
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
});

site.process([".html"], autoDependency);
site.loadData([".csv"], csvLoader);
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

site.remoteFile(
  "/assets/images/jrf_logo.svg",
  "https://www.jrf.org.uk/sites/all/themes/jrf/images/jrf_logo.svg",
);
site.remoteFile(
  "/assets/images/oi_logo.svg",
  "https://open-innovations.org/resources/images/logos/oi-square-11.svg",
);

export default site;
