'use strict';

# ES 5 compability functions
Object.keys or= (o) -> name for own name of o
Array.isArray or= (a) -> a.push is Array.prototype.push and a.length?

# CommonJS flag
isCommonJS = exports?

# Function to check for JavaScript file ending
hasExtension = (filename, extension) -> 
  return undefined unless filename?
  
  filename.lastIndexOf(extension) is filename.length - extension

isJavaScriptFile = (filename) -> hasExtension filename, '.js'

# Wrapper function
do (root = module?.exports ? this) ->
  cache = {}
  queue = {}
  pathSep = '/'
  
  loadScriptFile = (filename, callback) ->
    unless isCommonJS
      scriptElem = root.document.createElement 'script'
      
      scriptElem.async = true
      scriptElem.type = 'text/javascript'
      
      # Check if it's a complete url, else prepend protocol/path
      if filename.indexOf('http://') is 0 or filename.indexOf('https://') is 0 or filename.indexOf('//') is 0
        scriptElem.src = filename
      else
        locHref = root.location.href
      
        prePath = locHref.slice 0, locHref.lastIndexOf('/') + 1
        scriptElem.src = prePath + filename
        
      if callback
        scriptElem.onload = scriptElem.onreadystatechange = ->
          rs = @readyState;
          return undefined if rs and rs isnt 'complete' and rs isnt 'loaded'
          callback()
        
      firstScriptElem = root.document.getElementsByTagName('script')[0]
      firstScriptElem.parentNode.insertBefore scriptElem, firstScriptElem
      
  moloDefine = (name, body) ->
    # Abort if no name or no body
    return unless name or body
    
    # If name is a function, then just call the function
    if typeof name is 'function' then return name.apply @
    
    # If body is a function, add it to the cache directly, else queue it
    if typeof body is 'function' then return cache[name] = body
    
  moloRequire = (name, callback) ->
    if Object.hasOwnProperty.call cache, name then return callback cache[name]
    
    if Object.hasOwnProperty.call queue, name
      name
    

  moloFunc = (name, defines) ->
    # TODO: Add module name always to queue and remove it if all dependencies have been met
    # Currently, the module will only be added if it has any depedencies and cannot be
    # resolved directly
    
    # Skip flag to skip the rest of the function
    skipFunc = false
    
    defObject = {}

    # If name is not a string, it's an anonymous module (Put defines parameter in the correct order)
    if typeof name isnt 'string'
      # If name is an array, just load dependencies
      if Array.isArray(name) 
        if Object.keys(defines).length > 0
          defines.require = name
        else
          defines =
            require: name

        skipFunc = true
      else 
        [name, defines] = [undefined, name]

    # Skip if no factory has been defined
    return undefined unless defines

    # Get properties from defines if it's an object, else they are no dependencies and take the function as the factory
    if typeof defines is 'function' then define = defines else {define, require: deps, context} = defines

    # Default parameters, if they have not been defined yet
    deps = [] unless deps?
    context = @ unless context?

    # If a single dependency has been declared as a string, make it into an array
    if typeof deps is 'string' then deps = [deps]

    # Get the result of cached dependencies
    cacheDeps = []

    for i in deps
      # Need to check for hasOwnProperty
      # Checking for cache[i] is not strict enough
      # because a module could have undefined, null, 0 or an empty string
      # as its export value
      if Object.hasOwnProperty.call cache, i
        cacheDeps.push cache[i]
      else
        # Plugin functionality
        pluginName = i.split('!')[1]
        
        scriptLoader = root.molo.scriptLoader
        
        # If a script is defined as 'my/script!' it will try to resolve the 
        # dependency on the same page
        scriptLoader = false if pluginName is ''
        
        if scriptLoader
          if isJavaScriptFile(root.molo.paths[name])
            # If the path is complete (e.g. 'js/lib/mymodule.js') take that as a path
            scriptPath = root.molo.paths[name]
          else
            # Prepend the base path if any
            prePath = if root.molo.basePath then "#{basePath}" else ''
            pathArray = Object.keys(root.molo.paths)

            # Walk through all paths and check if the module name starts with the path name
            for p in pathArray
              if root.molo.paths[p] and name.indexOf("#{root.molo.paths[p]}#{pathSep}") is 0
                prePath = root.molo.paths[p]

            scriptPath = if prePath then "#{prePath}#{pathSep}#{i}.js" else "#{i}.js"

          loadScriptFile scriptPath

        # Add script definition to queue
        queue[name] = defines

        # Set skip flag
        # We need to go through the rest of the dependencies,
        # but not the rest of the function
        skipFunc = true

    # Skip function now
    return undefined if skipFunc

    # Execute factory function and store it in cache

    # Special case: Factory is an object and has no dependencies ()
    if typeof define is 'object' and deps.length is 0
      cache[name] = define
    else
      cache[name] = define.apply context, cacheDeps

    # Check queue
    queueList = Object.keys(queue)

    for q in queueList
      # Have all required dependencies been loaded?
      maxDeps = queue[q].require.length
      curDeps = 0

      for d in queue[q].require
        depBasename = d.split('!')[0]
        curDeps++ if cache[depBasename]
      
      # Reload module and delete item from queue
      if curDeps is maxDeps
        modName = q
        modDefinition = queue[q]
        delete queue[q]
        moloFunc modName, modDefinition

    null

  # Map molo function
  root.molo = moloFunc
  
  # Molo basic configuration
  root.molo.scriptLoader = true

  # Set path configuration
  root.molo.basePath = ''
  root.molo.paths = {}

  # Completely clear all caches
  root.molo.clear = ->
    cache = {}
    queue = {}
    
    moloStdLib.call @

  # Delete a single module from cache, which forces it to
  # reload this module if it comes up as a dependency the
  # next time
  root.molo.delete = (name) ->
    delete cache[name] if cache[name]
    delete queue[name] if queue[name]
    
  # Provide plugin functionality
  root.molo.plugins = {}
    
  # Shorthand function to load script files
  root.molo.main = root.require = (dependencies, callback) ->
    dependencies = [dependencies] if typeof dependencies is 'string'
    
    moloFunc(dependencies, callback) if Array.isArray dependencies

  # Overwrite module only if it hasn't been defined
  # TODO: Reflect if this is necessary or even a good idea (ES 6 problems?)
  root.module or= moloFunc

  # Compability to official definition (https://github.com/amdjs/amdjs-api/wiki/AMD)
  root.define = (name, deps, defines) ->   
    unless Array.isArray deps
      defines = deps
      deps = []
  
    moloFunc name, 
      require: deps, 
      define: defines

  # Some general definitions
  root.define.amd =
    jQuery: true
  
  # Standard module definitions
  moloStdLib = ->
    moloFunc 'require',
      define: -> (moduleID) -> cache[moduleID]
      
    moloFunc 'exports',
      define: ->
        
  moloStdLib() 
