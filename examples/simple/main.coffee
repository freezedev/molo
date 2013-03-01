###
If all the modules are in the same file, you need
to take care of the correct order for these 
dependencies yourself
###

module 'teststring', -> 'test'

module 'testfun', -> (param) -> alert param

module 'test',
  require: ['testfun', 'teststring']
  define: (testfun, teststring) -> testfun teststring