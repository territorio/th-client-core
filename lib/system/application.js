import Resolver from "./resolver";
import EmberApp from "ember-application/system/application";

var App = EmberApp.extend({

  LOG_ACTIVE_GENERATION: false,
  // LOG_TRANSITIONS: true,
  // LOG_TRANSITIONS_INTERNAL: true,
  //LOG_VIEW_LOOKUPS: true,
  
  // ember-jj-abrams-resolver
  modulePrefix: 'app',
  Resolver: Resolver
});

App.reopenClass({

  initializeAll: function() {
    
    var self = this;
    // TODO: set 'th-core/initializers'
    var initializersRegExp = new RegExp('app/initializers/application/');
    Ember.keys(requirejs._eak_seen).filter(function(key) {
      return initializersRegExp.test(key);
    }).forEach(function(moduleName) {
      self.initializeModule(moduleName);
    });

  },

  initializeModule: function(moduleName) {

    var module = require(moduleName, null, null, true);
    if (!module) { throw new Error(moduleName + ' must export an initializer.'); }
    this.initializer(module['default']);

  }

});

export default App;
