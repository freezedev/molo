(function() {
  var isCommonJS,
    __hasProp = {}.hasOwnProperty;

  Object.keys || (Object.keys = function(o) {
    var name, _results;
    _results = [];
    for (name in o) {
      if (!__hasProp.call(o, name)) continue;
      _results.push(name);
    }
    return _results;
  });

  isCommonJS = typeof exports !== "undefined" && exports !== null;

  (function(root) {
    var cache, moloFunc, queue;
    cache = {};
    queue = {};
    moloFunc = function(name, defines) {
      var cacheDeps, context, curDeps, d, define, deps, i, maxDeps, modDefinition, modName, p, pathArray, prePath, q, queueList, scriptElem, scriptPath, skipFunc, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1;
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
      skipFunc = false;
      for (_i = 0, _len = deps.length; _i < _len; _i++) {
        i = deps[_i];
        if (cache[i]) {
          cacheDeps.push(cache[i]);
        } else {
          if (!isCommonJS) {
            scriptElem = root.document.createElement('script');
            scriptElem.async = true;
            prePath = '';
            pathArray = Object.keys(root.molo.paths);
            for (_j = 0, _len1 = pathArray.length; _j < _len1; _j++) {
              p = pathArray[_j];
              if (root.molo.paths[p] && name.indexOf(root.molo.paths[p]) === 0) {
                prePath = root.molo.paths[p];
              }
            }
            scriptPath = prePath ? "" + prePath + "/" + i + ".js" : "" + i + ".js";
            scriptElem.src = scriptPath;
            root.document.head.appendChild(scriptElem);
          }
          queue[name] = defines;
          skipFunc = true;
        }
      }
      if (skipFunc) {
        return void 0;
      }
      cache[name] = define.apply(context, cacheDeps);
      queueList = Object.keys(queue);
      for (_k = 0, _len2 = queueList.length; _k < _len2; _k++) {
        q = queueList[_k];
        maxDeps = queue[q].require.length;
        curDeps = 0;
        _ref1 = queue[q].require;
        for (_l = 0, _len3 = _ref1.length; _l < _len3; _l++) {
          d = _ref1[_l];
          if (cache[d]) {
            curDeps++;
          }
        }
        if (curDeps === maxDeps) {
          modName = q;
          modDefinition = queue[q];
          delete queue[q];
          moloFunc(modName, modDefinition);
        }
      }
      return null;
    };
    root.molo = moloFunc;
    root.molo.paths = {};
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
