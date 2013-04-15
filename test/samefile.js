(function() {
  var chai, molo;

  chai = require('chai');

  chai.should();

  molo = require('./js/molo');

  describe('molo', function() {
    it('All definitions in one (in order)', function() {
      molo.define('a', function() {
        return 1;
      });
      molo.define('b', function() {
        return 2;
      });
      molo.define('c', ['a', 'b'], function(a, b) {
        return a + b;
      });
      return molo.require('c', function(c) {
        c.should.equal(3);
        return done();
      });
    });
    it('All definitions in one (reverse order)', function() {
      molo.define('c', ['a', 'b'], function(a, b) {
        return a + b;
      });
      molo.define('b', function() {
        return 2;
      });
      molo.define('a', function() {
        return 1;
      });
      return molo.require('c', function(c) {
        c.should.equal(3);
        return done();
      });
    });
    return it('All definitions in one (mixed order)', function() {
      molo.define('b', function() {
        return 2;
      });
      molo.define('c', ['a', 'b'], function(a, b) {
        return a + b;
      });
      molo.define('a', function() {
        return 1;
      });
      return molo.require('c', function(c) {
        c.should.equal(3);
        return done();
      });
    });
  });

}).call(this);
