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
      var cacheDeps, context, curDeps, d, define, deps, i, maxDeps, modDefinition, modName, q, queueList, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
      if (typeof name !== 'string') {
        _ref = [void 0, name], name = _ref[0], defines = _ref[1];
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
      queueList = Object.keys(queue);
      for (_j = 0, _len1 = queueList.length; _j < _len1; _j++) {
        q = queueList[_j];
        maxDeps = queue[q].require.length;
        curDeps = 0;
        _ref1 = queue[q].require;
        for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
          d = _ref1[_k];
          if (cache[d]) {
            curDeps++;
          }
        }
        console.log("c: " + curDeps + " max: " + maxDeps);
        if (curDeps === maxDeps) {
          modName = q;
          modDefinition = queue[q];
          delete queue[q];
          moloFunc(modName, modDefinition);
        }
      }
      return null;
    };
    moloConfig = {};
    root.molo = moloFunc;
    root.molo.config = moloConfig;
    root.molo.clear = function() {
      cache = {};
      return queue = {};
    };
    root.molo["delete"] = function(name) {
      if (cache[name]) {
        delete cache[name];
      }
      if (queue[name]) {
        return delete queue[name];
      }
    };
    root.module || (root.module = moloFunc);
    root.define = function(name, deps, defines) {
      return moloFunc(name, {
        require: deps,
        define: defines
      });
    };
    return root.define.amd = {
      jQuery: true
    };
  })(typeof exports !== "undefined" && exports !== null ? exports : this);

}).call(this);
