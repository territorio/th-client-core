import DS from "ember-data/lib/main";

var Event = DS.Model.extend({
  title: DS.attr('string'),
  content: DS.attr('string'),
  place: DS.attr('string'),
  categories: DS.hasMany('category'),
  places: DS.hasMany('place')
});


export default Event;

