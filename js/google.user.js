// ==UserScript==
// @name             User Script for Google
// @namespace        lifesinger
// @description      Remove google redirects etc.
// @author           lifesinger@gmail.com
// @source           http://lifesinger.github.com/config/google.user.js
// @match            https://www.google.com/*
// @match            http://www.google.com/*
// @match            https://www.google.com.hk/*
// @match            http://www.google.com.hk/*
// @version          1.0.0
// ==/UserScript==

(function() {

  // Remove redirects
  var target = document.querySelector('body')

  var observer = new WebKitMutationObserver(function() {
    var links = document.querySelectorAll('a[onmousedown]')
    makeArray(links).forEach(function(link) {
      link.onmousedown = null
    })
  })

  observer.observe(target, { childList: true })


  // Helpers
  // -------

  function makeArray(nodeList) {
    return Array.prototype.slice.call(nodeList)
  }


  // Thanks to
  // - https://developer.mozilla.org/en-US/docs/DOM/MutationObserver
  // - http://userscripts.org/scripts/review/117942

})()
