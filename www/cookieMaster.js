(function() {
  'use strict';

  var cookieMaster = {
    getCookieValue: getCookieValue,
    setCookieValue: setCookieValue
  };

  if (typeof module != 'undefined' && module.exports) {
    module.exports = cookieMaster;
  }

  if (typeof window != 'undefined') {
    window.cookieMaster = cookieMaster;
  }

  return cookieMaster;

  function getCookieValue(url, cookieName, onSuccess, onError) {
    cordova.exec(
      onSuccess,
      onError,
      'CookieMaster',
      'getCookieValue',
      [url, cookieName]
    );
  }

  function setCookieValue(url, cookieName, cookieValue, cookieOptions, onSuccess, onError) {
    cookieOptions = cookieOptions || {};
    onError       = onError       || noop;
    onSuccess     = onSuccess     || noop;

    if (typeof onError !== 'function') {
      console.log("CookieMaster.setCookieValue failure: onError parameter not a function");
      return;
    }

    if (typeof onSuccess !== 'function') {
      return onError("CookieMaster.setCookieValue failure: onSuccess parameter not a function");
    }

    if (!isObject(cookieOptions)) {
      return onError("CookieMaster.setCookieValue failure: cookieOptions parameter not an object");
    }

    cordova.exec(
      onSuccess,
      onError,
      'CookieMaster',
      'setCookieValue',
      [url, cookieName, cookieValue, cookieOptions]
    );
  }

  function isObject(value) {
    return value != null && typeof value === 'object';
  }

  function noop() { }
})();
