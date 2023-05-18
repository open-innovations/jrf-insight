import lume from "lume/mod.ts";
import base_path from "lume/plugins/base_path.ts";
import metas from "lume/plugins/metas.ts";
import postcss from "lume/plugins/postcss.ts";

const site = lume({
  src: './src',
  location: new URL('https://open-innovations.github.io/jrf-insight/')
});

site.use(base_path());
site.use(metas());
site.use(postcss());

export default site;
