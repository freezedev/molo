###
If all the modules are in the same file, you need
to take care of the correct order for these 
dependencies yourself
###

module 'test'
  require: ['testfun', 'teststring']
  define: (testfun, teststring) -> testfun teststring

module 'teststring', -> 'test'

module 'testfun', -> (param) -> alert param