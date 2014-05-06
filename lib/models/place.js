import DS from "ember-data/lib/main";

var Place = DS.Model.extend({
  name: DS.attr('string'),
  slug: DS.attr('string')
});

export default Place;
