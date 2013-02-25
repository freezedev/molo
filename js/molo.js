(function() {
  'use strict';

  var hasExtension, isCommonJS, isJavaScriptFile,
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

  Array.isArray || (Array.isArray = function(a) {
    return a.push === Array.prototype.push && (a.length != null);
  });

  isCommonJS = typeof exports !== "undefined" && exports !== null;

  hasExtension = function(filename, extension) {
    if (filename == null) {
      return void 0;
    }
    return filename.lastIndexOf(extension) === filename.length - extension;
  };

  isJavaScriptFile = function(filename) {
    return hasExtension(filename, '.js');
  };

  (function(root) {
    var cache, loadScriptFile, moloFunc, moloStdLib, pathSep, queue;
    cache = {};
    queue = {};
    pathSep = '/';
    loadScriptFile = function(filename, callback) {
      var firstScriptElem, locHref, prePath, scriptElem;
      if (!isCommonJS) {
        scriptElem = root.document.createElement('script');
        scriptElem.async = true;
        scriptElem.type = 'text/javascript';
        if (filename.indexOf('http://') === 0 || filename.indexOf('https://') === 0 || filename.indexOf('//') === 0) {
          scriptElem.src = filename;
        } else {
          locHref = root.location.href;
          prePath = locHref.slice(0, locHref.lastIndexOf('/') + 1);
          scriptElem.src = prePath + filename;
        }
        if (callback) {
          scriptElem.onload = scriptElem.onreadystatechange = function() {
            var rs;
            rs = this.readyState;
            if (rs && rs !== 'complete' && rs !== 'loaded') {
              return void 0;
            }
            return callback();
          };
        }
        firstScriptElem = root.document.getElementsByTagName('script')[0];
        return firstScriptElem.parentNode.insertBefore(scriptElem, firstScriptElem);
      }
    };
    moloFunc = function(name, defines) {
      var cacheDeps, context, curDeps, d, define, depBasename, deps, i, maxDeps, modDefinition, modName, p, pathArray, pluginName, prePath, q, queueList, scriptLoader, scriptPath, skipFunc, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1;
      skipFunc = false;
      if (typeof name !== 'string') {
        if (Array.isArray(name)) {
          defines = {
            require: name
          };
          skipFunc = true;
        } else {
          _ref = [void 0, name], name = _ref[0], defines = _ref[1];
        }
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
        if (cache.hasOwnProperty(i)) {
          cacheDeps.push(cache[i]);
        } else {
          pluginName = i.split('!')[1];
          scriptLoader = root.molo.scriptLoader;
          if (pluginName === '') {
            scriptLoader = false;
          }
          if (scriptLoader) {
            if (isJavaScriptFile(root.molo.paths[name])) {
              scriptPath = root.molo.paths[name];
            } else {
              prePath = root.molo.basePath ? "" + basePath : '';
              pathArray = Object.keys(root.molo.paths);
              for (_j = 0, _len1 = pathArray.length; _j < _len1; _j++) {
                p = pathArray[_j];
                if (root.molo.paths[p] && name.indexOf("" + root.molo.paths[p] + pathSep) === 0) {
                  prePath = root.molo.paths[p];
                }
              }
              scriptPath = prePath ? "" + prePath + pathSep + i + ".js" : "" + i + ".js";
            }
            loadScriptFile(scriptPath);
          }
          queue[name] = defines;
          skipFunc = true;
        }
      }
      if (skipFunc) {
        return void 0;
      }
      if (typeof define === 'object' && deps.length === 0) {
        cache[name] = define;
      } else {
        cache[name] = define.apply(context, cacheDeps);
      }
      queueList = Object.keys(queue);
      for (_k = 0, _len2 = queueList.length; _k < _len2; _k++) {
        q = queueList[_k];
        maxDeps = queue[q].require.length;
        curDeps = 0;
        _ref1 = queue[q].require;
        for (_l = 0, _len3 = _ref1.length; _l < _len3; _l++) {
          d = _ref1[_l];
          depBasename = d.split('!')[0];
          if (cache[depBasename]) {
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
    root.molo.scriptLoader = true;
    root.molo.basePath = '';
    root.molo.paths = {};
    root.molo.clear = function() {
      cache = {};
      queue = {};
      return moloStdLib.call(this);
    };
    root.molo["delete"] = function(name) {
      if (cache[name]) {
        delete cache[name];
      }
      if (queue[name]) {
        return delete queue[name];
      }
    };
    root.molo.plugins = {};
    root.molo.main = function(dependencies) {
      if (typeof dependencies === 'string') {
        dependencies = [dependencies];
      }
      if (Array.isArray(dependencies)) {
        return moloFunc(dependencies);
      }
    };
    root.module || (root.module = moloFunc);
    root.define = function(name, deps, defines) {
      if (!Array.isArray(deps)) {
        defines = deps;
        deps = [];
      }
      return moloFunc(name, {
        require: deps,
        define: defines
      });
    };
    root.define.amd = {
      jQuery: true
    };
    moloStdLib = function() {
      moloFunc('require', {
        define: function() {
          return function(moduleID) {
            return cache[moduleID];
          };
        }
      });
      return moloFunc('exports', {
        define: function() {}
      });
    };
    return moloStdLib();
  })(typeof exports !== "undefined" && exports !== null ? exports : this);

}).call(this);
