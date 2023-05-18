import lume from "lume/mod.ts";
import base_path from "lume/plugins/base_path.ts";
import metas from "lume/plugins/metas.ts";
import postcss from "lume/plugins/postcss.ts";
import autoDependency from "https://deno.land/x/oi_lume_utils@v0.3.0/processors/auto-dependency.ts";
import csvLoader from "https://deno.land/x/oi_lume_utils@v0.3.0/loaders/csv-loader.ts";
import oiCharts from "https://deno.land/x/oi_lume_charts@v0.7.2/mod.ts";

const site = lume({
  src: './src',
  location: new URL('https://open-innovations.github.io/jrf-insight/')
});

site.process(['.html'], autoDependency);
site.loadData(['.csv'], csvLoader);
site.use(oiCharts());
site.use(base_path());
site.use(metas());
site.use(postcss());

export default site;
