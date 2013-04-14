chai = require 'chai'
chai.should()
molo = require './js/molo'

describe 'molo', ->
  it 'All definitions in one (in order)', ->
    
    molo.define 'a', -> 1
    molo.define 'b', -> 2
    molo.define 'c', ['a', 'b'], (a, b) -> a + b
    
    molo.require 'c', (c) ->
      c.should.equal(3)
      done()

