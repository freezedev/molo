
/*
If all the modules are in the same file, you need
to take care of the correct order for these 
dependencies yourself
*/


(function() {

  module('teststring', function() {
    return 'test';
  });

  module('testfun', function() {
    return function(param) {
      return alert(param);
    };
  });

  module('test', {
    require: ['testfun', 'teststring'],
    define: function(testfun, teststring) {
      return testfun(teststring);
    }
  });

}).call(this);
