(function() {
  var __hasProp = {}.hasOwnProperty;

  Object.keys || (Object.keys = function(o) {
    var name, _results;
    _results = [];
    for (name in o) {
      if (!__hasProp.call(o, name)) continue;
      _results.push(name);
    }
    return _results;
  });

  (function(root) {
    var cache, moloConfig, moloFunc, queue;
    cache = {};
    queue = {};
    moloFunc = function(name, defines) {
      var cacheDeps, context, define, deps, i, key, value, _i, _len;
      if (!(name && defines)) {
        return void 0;
      }
      if (typeof defines === 'function') {
        define = defines;
      } else {
        define = defines.define, deps = defines.require, context = defines.context;
      }
      if (deps == null) {
        deps = [];
      }
      if (context == null) {
        context = this;
      }
      if (typeof deps === 'string') {
        deps = [deps];
      }
      cacheDeps = [];
      for (_i = 0, _len = deps.length; _i < _len; _i++) {
        i = deps[_i];
        if (cache[i]) {
          cacheDeps.push(cache[i]);
        } else {
          queue[name] = defines;
          return void 0;
        }
      }
      cache[name] = define.apply(context, cacheDeps);
      if (Object.keys(queue).length > 0) {
        for (key in queue) {
          if (!__hasProp.call(queue, key)) continue;
          value = queue[key];
          module(key, value);
        }
        delete queue[key];
      }
      return null;
    };
    moloConfig = {};
    root.molo = moloFunc;
    root.molo.config = moloConfig;
    root.module = moloFunc;
    return root.define = function(name, deps, defines) {
      return moloFunc(name, {
        require: deps,
        define: defines
      });
    };
  })(typeof exports !== "undefined" && exports !== null ? exports : this);

}).call(this);
