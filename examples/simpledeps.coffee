module 'test'
  require: ['testfun', 'teststring']
  define: (testfun, teststring) -> testfun teststring

module 'teststring', -> 'test'

module 'testfun', -> (param) -> alert param