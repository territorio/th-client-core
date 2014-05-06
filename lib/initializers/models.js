import Category from "../models/category";
import Event from "../models/event";
import Place from "../models/place";

export default {
    name: "models",

    initialize: function(container, application) {

      container.register('model:category', Category);
      container.register('model:event', Event);
      container.register('model:place', Place);

    }
};
