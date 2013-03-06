###
If all the modules are in the same file, you need
to take care of the correct order for these 
dependencies yourself
###

module 'test',
  # The exclamation mark is generally the entry point for plugins, 
  # but without a plugin name after the exclamation mark it just means
  # that it will try to resolve the dependency in the same file
  require: ['testfun!', 'teststring!']
  define: (testfun, teststring) -> testfun teststring

module 'teststring', -> 'test'

module 'testfun', -> (param) -> alert param