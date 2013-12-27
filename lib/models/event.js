
Th.Event = DS.Model.extend({
  title: DS.attr('string'),
  content: DS.attr('string'),
  place: DS.attr('string'),
  categories: DS.hasMany('Th.Category')
});

