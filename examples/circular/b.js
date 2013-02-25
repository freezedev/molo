(function() {

  define('b', ['a'], function(a) {
    return alert(a);
  });

}).call(this);
