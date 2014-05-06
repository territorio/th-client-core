import DS from "ember-data/lib/main";

var Category = DS.Model.extend({
  name: DS.attr('string'),
  icon: DS.attr('string'),
  slug: DS.attr('string')
});

export default Category;
