




// RequireJS config
if(window.requirejs) {
  requirejs.config({
  "baseUrl": "/assets",
  "paths": {
    "jquery": "/assets/jquery-a3ffbba12a2fa86381d893e260a24a2f",
    "rsvp": "/assets/rsvp/rsvp-8e1e15491b50ca06649cc8104678d662",
    "eventsWithPromises": "/assets/eventsWithPromises/src/eventsWithPromises-885671659e8a30ef52e2205775d29732",
    "Header": "/assets/components/Header-fe3f56de4db43cc94352735d1169f541",
    "componentLoader": "/assets/dough/assets/js/lib/componentLoader-79dd1420efdd3c69a96ffd8770cd593c",
    "DoughBaseComponent": "/assets/dough/assets/js/components/DoughBaseComponent-cf9d43e9108be02ddede5d129ee12888",
    "Collapsable": "/assets/dough/assets/js/components/Collapsable-f97b37729e766525edd7e0987af19b98"
  },
  "shim": {
  }
});
}
;
// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



if (MAS.fonts.loadWithJS && MAS.fonts.url && !MAS.fonts.localstorage) {
  require(['jquery'], function($) {
    $.ajax({
      url: MAS.fonts.url,
      success: function(res) {
        $('html').addClass(MAS.fonts.loadClass);
        $('head').append('<style>' + res + '</style>');
        if (MAS.supports.localstorage) {
          localStorage.setItem(MAS.fonts.cacheName, res);
        }
      },
      dataType: 'text'
    });
  });
}

require(['componentLoader', 'eventsWithPromises'], function(componentLoader, eventsWithPromises) {
  componentLoader.init($('body'));
  eventsWithPromises.subscribe('component:contentChange', function(data) {
    componentLoader.init(data.$container);
  });
});
