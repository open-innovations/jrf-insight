import { parseHTML } from '../../../_lib/deps.ts';

interface TabSetOptions {
  content: string;
}

export default function ({ content }: TabSetOptions) {
  const fragment = parseHTML(content).document;
  const panels = Array.from(fragment.querySelectorAll('[data-tab-label]') as NodeListOf<HTMLElement>);

  const tabList = document.createElement('ul');

  for (const [idx, panel] of panels.entries()) {
    if (!panel.id) panel.setAttribute('id', `section${idx + 1}`);
    const tab = document.createElement('li');
    tab.innerHTML = `<a href="#${ panel.id }">${ panel.dataset.tabLabel }</a>`;
    tabList.append(tab);
  }
  
  return `<tab-set data-dependencies="/assets/js/inclusive.js">${
    tabList.outerHTML
  }${
    panels.map(x => x.toString()).join('')
  }</tab-set>`;
}