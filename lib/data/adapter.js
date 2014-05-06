import DS from "ember-data/lib/main";

var Adapter = DS.RESTAdapter.extend({
  defaultSerializer: '-app',
  host: 'http://www.territoriohuelva.com',

  findQuery: function(store, type, query) {
    query.api = true;
    return this._super(store,type,query);
  },

  buildURL: function(type, id) {
    // the resource must not be appended because
    // it does only find event objects
    return this.get('host');
  },

  ajaxOptions: function(url, type, hash) {

    hash = hash || {};
    hash.url = url;
    hash.type = type;
    hash.context = this;

    hash.dataType = 'jsonp';
    hash.crossDomain = true;
    hash.contentType = 'application/json; charset=utf-8';

    return hash;
  }

});

export default Adapter;
