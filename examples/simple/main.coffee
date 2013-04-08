###
If all the modules are in the same file, you need
to take care of the correct order for these 
dependencies yourself
###

define 'teststring', -> 'test'

define 'testfun', -> (param) -> alert param

define 'test', ['testfun', 'teststring'], (testfun, teststring) -> testfun teststring

require 'test'
