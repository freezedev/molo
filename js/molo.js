(function() {
  'use strict';
  var hasExtension, hasModule, isJavaScriptFile, _ref;

  Array.isArray || (Array.isArray = function(a) {
    return a.push === Array.prototype.push && (a.length != null);
  });

  hasModule = (typeof module !== "undefined" && module !== null ? module.exports : void 0) != null;

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
    var cache, loadScriptFile, mainHasBeenCalled, queue;
    loadScriptFile = function(filename, callback) {
      var firstScriptElem, locHref, prePath, scriptElem;
      if (!hasModule) {
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
      } else {
        if (require) {
          require(filename);
          return callback();
        }
      }
    };
    cache = {};
    queue = {};
    root.molo = {};
    root.molo.basePath = '';
    root.molo.paths = {};
    root.molo.defaultContext = root;
    root.molo.define = root.define = function(name, dependencies, factory) {
      var _ref1;
      if (cache[name]) {
        throw new TypeError("A module called " + name + " has already been evaluated. Please choose a different name.");
      }
      if (cache[name]) {
        throw new TypeError("A module called " + name + " has already been defined. Please choose a different name.");
      }
      if (!Array.isArray(dependencies)) {
        if (typeof dependencies === 'object' || typeof dependencies === 'function') {
          _ref1 = [factory, dependencies], dependencies = _ref1[0], factory = _ref1[1];
        }
      }
      if (!dependencies) {
        dependencies = [];
      }
      if (dependencies.length === 0) {
        if (typeof factory === 'function') {
          cache[name] = factory.call(root.molo.defaultContext);
        } else {
          cache[name] = factory;
        }
        return;
      }
      return queue[name] = {
        dependencies: dependencies,
        factory: factory
      };
    };
    root.molo.require = root.require = function(name, callback, context) {
      var i, _i, _len, _results;
      if (context == null) {
        context = root.molo.defaultContext;
      }
      if (typeof name === 'string') {
        name = [name];
      }
      if (!Array.isArray(name)) {
        return;
      }
      _results = [];
      for (_i = 0, _len = name.length; _i < _len; _i++) {
        i = name[_i];
        _results.push((function(i) {
          var cacheDeps, dep, depIndex, depLength, depsLoaded, p, pathArray, prePath, scriptPath, updateDeps, _j, _k, _len1, _len2, _ref1, _results1;
          cacheDeps = [];
          if (queue[i]) {
            depIndex = 0;
            depLength = queue[i].dependencies.length;
            depsLoaded = function() {
              if (depIndex === depLength) {
                return cache[i] = queue[i].factory.apply(context, cacheDeps);
              }
            };
            updateDeps = function() {
              depIndex++;
              return depsLoaded();
            };
            _ref1 = queue[i].dependencies;
            _results1 = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              dep = _ref1[_j];
              if (Object.hasOwnProperty.call(cache, dep)) {
                cacheDeps.push(cache[dep]);
                depIndex++;
                _results1.push(depsLoaded());
              } else {
                _results1.push(root.molo.require(i, updateDeps, context));
              }
            }
            return _results1;
          } else {
            if (isJavaScriptFile(root.molo.paths[name])) {
              scriptPath = root.molo.paths[name];
            } else {
              prePath = root.molo.basePath ? "" + basePath : '';
              pathArray = Object.keys(root.molo.paths);
              for (_k = 0, _len2 = pathArray.length; _k < _len2; _k++) {
                p = pathArray[_k];
                if (root.molo.paths[p] && name.indexOf("" + root.molo.paths[p] + pathSep) === 0) {
                  prePath = root.molo.paths[p];
                }
              }
              scriptPath = prePath ? "" + prePath + pathSep + i + ".js" : "" + i + ".js";
            }
            return loadScriptFile(scriptPath, function() {});
          }
        })(i));
      }
      return _results;
    };
    root.molo["delete"] = function(name) {
      if (cache[name]) {
        delete cache[name];
      }
      if (queue[name]) {
        return delete queue[name];
      }
    };
    root.molo.clear = function() {
      cache = {};
      return queue = {};
    };
    mainHasBeenCalled = false;
    root.molo.main = function(name, callback) {
      var moloHasBeenCalled;
      if (mainHasBeenCalled) {
        throw new TypeError('molo.main can only be called once.');
      }
      root.molo.require(name, callback);
      return moloHasBeenCalled = true;
    };
    return root.unit = function(name, body) {
      var defines, requires;
      requires = body.requires, defines = body.defines;
      return root.molo.define(name, requires, defines);
    };
  })((_ref = typeof module !== "undefined" && module !== null ? module.exports : void 0) != null ? _ref : this);

}).call(this);
