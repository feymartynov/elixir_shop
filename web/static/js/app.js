// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

function ready(fn) {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

ready(() => {
  let csrfToken = document.getElementById('csrf-token').getAttribute('value');
  let links = document.querySelectorAll('a[data-method]');

  Array.prototype.forEach.call(links, (link) => {
    link.addEventListener('click', (evt) => {
      evt.preventDefault();
      var form = document.createElement('form');
      form.setAttribute('action', link.getAttribute('href'));
      form.setAttribute('method', 'post');
      form.setAttribute('accept-charset', 'UTF-8');
      form.innerHTML = `
        <input type="hidden" name="_method" value="${link.dataset['method']}" />
        <input type="hidden" name="_csrf_token" value="${csrfToken}" />
        <input type="hidden" name="_utf8" value="✓">`;
      form.submit();
    });
  });
});
