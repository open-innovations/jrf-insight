/**
 * Inclusive Components Progressive Enhancement for the `toggle-section` tag.
 * 
 * Based on https://inclusive-components.design/collapsible-sections/
 * 
 * Create the following HTML, including an undefined custom tag `toggle-section`
 * 
 * ```
 * <toggle-section>
 *  <h2>Section Title</h2>
 *  <p>Some content</p>
 *  <p>Some more content</p>
 * </toggle-section>
 * ```
 * 
 * This will be enhanced with a button which enables expansion, and wraps everything but the first element
 * in a div which will be collapsed.
 * 
 * Base styling for this is kept in `_includes/css/inclusive.css`.
 */
function initialiseToggleSections() {
  // Find all the toggle-section elements
  const toggleSections = document.querySelectorAll('toggle-section');
  console.log(toggleSections);
  
  // Iterate through each one
  Array.prototype.forEach.call(toggleSections, toggleSection => {
    console.log(toggleSection);
    // Find the heading
    const heading = toggleSection.firstElementChild;
    // TODO Check if heading is a heading?
    
    // Update the innerHTML with a button and SVG indicator
    heading.innerHTML = `<button aria-expanded="false">
    ${heading.textContent}
    <svg aria-hidden="true" focusable="false" viewBox="0 0 10 10">
    <rect class="vert" height="8" width="2" y="1" x="4"/>
    <rect height="2" width="8" y="4" x="1"/>
    </svg>`;
    
    // Create a div to contain the hideable stuff
    const container = document.createElement('div');
    // ...and set it to hidden
    container.hidden = true;
    // ...and append it as the last child of the toggleSection
    toggleSection.appendChild(container);
    
    // Iterate endlessly...
    while(true) {
      // Get the sibling directly after the heading
      const el = heading.nextElementSibling;
      // If we've got the container, then we're done, so break out of the loop
      if (el === container) break;
      // Otherwise append that element to the container
      container.appendChild(toggleSection.firstElementChild.nextElementSibling);
    }
    
    // Grab the button
    const btn = heading.querySelector('button');
    
    // Attach an onclick handler
    btn.onclick = () => {
      // Get the state of the aria-expanded property
      const expanded = btn.getAttribute('aria-expanded') === 'true' || false;
      // Flip the polarity of the aria-expanded property
      btn.setAttribute('aria-expanded', !expanded);
      // And set the hidden status of the container
      container.hidden = expanded;
    }
  })
}

addEventListener('DOMContentLoaded', () => {
  initialiseToggleSections();
})