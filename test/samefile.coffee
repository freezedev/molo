chai = require 'chai'
chai.should()
{molo} = require '../js/molo'

describe 'molo', ->
  # Clear cache after each test
  afterEach -> molo.clear()
  
  it 'All definitions in one (in order)', ->
    molo.define 'a', -> 1
    molo.define 'b', -> 2
    molo.define 'c', ['a', 'b'], (a, b) -> a + b
    
    molo.require 'c', (c) ->
      c.should.equal(3)
      done()
  
  it 'All definitions in one (reverse order)', ->
    molo.define 'c', ['a', 'b'], (a, b) -> a + b
    molo.define 'b', -> 2
    molo.define 'a', -> 1
    
    molo.require 'c', (c) ->
      c.should.equal(3)
      done()

  it 'All definitions in one (mixed order)', ->
    molo.define 'b', -> 2
    molo.define 'c', ['a', 'b'], (a, b) -> a + b
    molo.define 'a', -> 1
    
    molo.require 'c', (c) ->
      c.should.equal(3)
      done()