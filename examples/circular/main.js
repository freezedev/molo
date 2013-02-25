
/*
If all the modules are in the same file, you need
to take care of the correct order for these 
dependencies yourself
*/


(function() {

  define('a', ['b'], function(b) {
    return 'a';
  });

  define('b', ['a'], function(a) {
    return alert(a);
  });

}).call(this);
