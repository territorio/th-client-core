import DS from "ember-data/lib/main";

var Store = DS.Store.extend({
  adapter: '-app'

});

export default Store;
