function localeifyNumbers() {
  document.querySelectorAll('[data-number]').forEach((numberEl: HTMLElement) => {
    const value = new Number(numberEl.dataset.number);
    numberEl.innerHTML = value.toLocaleString();
  })
}

addEventListener('DOMContentLoaded', () => {
  localeifyNumbers();
})