
/*
If all the modules are in the same file, you need
to take care of the correct order for these 
dependencies yourself
*/


(function() {

  define('test', ['testfun', 'teststring'], function(testfun, teststring) {
    return testfun(teststring);
  });

  define('teststring', function() {
    return 'test';
  });

  define('testfun', function() {
    return function(param) {
      return alert(param);
    };
  });

  require('test');

}).call(this);
