(function() {

  module('c', {
    require: ['a', 'b'],
    define: function(a, b) {
      return a + b;
    }
  });

}).call(this);
