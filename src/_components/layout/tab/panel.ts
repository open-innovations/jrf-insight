interface TabPabelOptions {
  label: string;
  id: string;
  content: string;
}

export default function ({
  label,
  id,
  content,
}: TabPabelOptions) {
  return `<section id="${id || crypto.randomUUID()}" data-tab-label="${label}">${content}</section>`
}