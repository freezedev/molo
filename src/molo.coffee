'use strict'

# ES 5 compability functions
do ->
  Object.keys ?= (o) -> name for own name of o
  Array.isArray ?= (a) -> a.push is Array.prototype.push and a.length?

# Check for potential server-side javascript
hasModule = module?.exports?

# Function to check for JavaScript file ending
hasExtension = (filename, extension) ->
  return undefined unless filename?
  
  filename.lastIndexOf(extension) is filename.length - extension

# Check if it's a JavaScript file
isJavaScriptFile = (filename) -> hasExtension filename, '.js'

# Path seperator
pathSep = '/'

# Wrapper function
do (root = module?.exports ? this) ->

  # Loading script
  loadScriptFile = (filename, callback) ->
    unless hasModule
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
          rs = @readyState
          return undefined if rs and rs isnt 'complete' and rs isnt 'loaded'
          callback()
        
      firstScriptElem = root.document.getElementsByTagName('script')[0]
      firstScriptElem.parentNode.insertBefore scriptElem, firstScriptElem
    else
      # Make sure require is available
      if require?
        require filename
        callback()

  appendScriptPath = (name) ->
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

      scriptPath = if prePath then "#{prePath}#{pathSep}#{name}.js" else "#{name}.js"

  # Cache and queue definition
  cache = {}
  queue = {}
  waitQueue = {}
  
  # Plugin object
  plugins = {}

  # Molo base object
  root.molo = {}
  
  # Debug functions
  #root.molo.getCache = -> cache
  #root.molo.getQueue = -> queue

  # Molo configuration
  root.molo.basePath = ''
  root.molo.paths = {}
  root.molo.defaultContext = root

  
  # Define function
  root.molo.define = root.define = (name, dependencies, factory) ->
    if cache[name]
      throw new TypeError "A module called #{name} has already been evaluated. Please choose a different name."
      
    if cache[name]
      throw new TypeError "A module called #{name} has already been defined. Please choose a different name."
      
    unless Array.isArray dependencies
      if typeof dependencies is 'object' or typeof dependencies is 'function'
        [dependencies, factory] = [factory, dependencies]
      
    unless dependencies then dependencies = []
    
    # Add to cache directly if no dependencies
    if dependencies.length is 0
      if typeof factory is 'function'
        cache[name] = factory.call root.molo.defaultContext
      else
        cache[name] = factory
      return
      
    queue[name] = {dependencies, factory}
  
  # Compability flag
  root.molo.define.amd = root.define.amd = true  
  #root.molo.define.umd = root.define.umd = false  
    
  # Require function
  root.molo.require = root.require = (name, callback, context = root.molo.defaultContext) ->
    # If a single dependency has been declared as a string, make it into an array
    if typeof name is 'string' then name = [name]
    
    # Abort condition
    return unless Array.isArray name
    
    # If no callback defined, single module and module in cache, return it directly
    return cache[name] if name.length is 1 and not callback? and Object.hasOwnProperty.call(cache, name[0])
    
    reqArgs = []
    reqArgIndex = 0
    
    executeCallback = ->
      if callback 
        callback.apply @, reqArgs if reqArgIndex is name.length
    
    # Walk through all requires
    for i, num in name
      if cache[i]
        reqArgs[num] = cache[i]
        reqArgIndex++
        executeCallback()
        return
      
      # Get the result of cached dependencies
      cacheDeps = []
              
      if queue[i]
        depIndex = 0
        depLength = queue[i].dependencies.length
        
        depsLoaded = ->
          if depIndex is depLength
            cache[i] = queue[i].factory.apply context, cacheDeps
            delete queue[i]
            
        updateDeps = (item) ->
          if item
            cacheDeps.push item
            depIndex++
            depsLoaded()
        
        for dep in queue[i].dependencies
          # Need to check for hasOwnProperty
          # Checking for cache[i] is not strict enough
          # because a module could have undefined, null, 0 or an empty string
          # as its export value
          if Object.hasOwnProperty.call cache, dep
            updateDeps cache[dep]
          else
            root.molo.require dep, updateDeps, context
      else
        loadScriptFile appendScriptPath(i), -> root.molo.require i
    
    
    

    walkThroughQueue = (queueObj) ->
      # Resolve queue if possible
      #resolveDeps = []
      
      for key, value of queueObj
        root.molo.require key
      
      #if Object.keys(queueObj).length > 0
      #  for key, value of queueObj
      #    return unless key and value
          
          
          
          #console.log 'walkThroughQueue'
          #console.log key
          #console.log value
          
          #depLength = value.dependencies.length
          #for dep in value.dependencies
          #  if cache[dep]
          #    resolveDeps.push cache[dep]
          #    if depLength is resolveDeps.length
          #      cache[key] = value.factory.apply context, resolveDeps
          #      delete queueObj[key] if queueObj[key]
          #      #delete waitQueue[key] if waitQueue[key]
          #    #else
          #    #  waitQueue[key] = queueObj[key]
      
    walkThroughQueue queue
    #walkThroughQueue waitQueue

    
    console.log 'Queue & Cache & waitQueue'
    console.log queue
    console.log cache
    console.log waitQueue
        
  # Additional export functions
  
  # Delete a single module from cache, which forces it to
  # reload this module if it comes up as a dependency the
  # next time
  root.molo.delete = root.molo.invalidate = (name) ->
    delete cache[name] if cache[name]
    delete queue[name] if queue[name]

  # Plugin connector
  root.molo.plugins =
    add: (pluginName, pluginFunc) -> plugins[pluginName] = pluginFunc
    delete: (p) -> delete plugins[p] if plugins[p]

  # Completely clear all caches
  root.molo.clear = ->
    cache = {}
    queue = {}
    
  
  # Molo main shorthand
  mainHasBeenCalled = false
  
  root.molo.main = (name, callback) ->
    [name, callback] = ['main', name] if typeof name is 'function' or not name?
    
    if mainHasBeenCalled then throw new TypeError 'molo.main can only be called once.'

    root.molo.require name, callback
    
    moloHasBeenCalled = true
    

  # Alternative module decleration
  root.unit = (name, body) ->
    {requires, defines} = body
    
    root.molo.define name, requires, defines

  #root.molo.define 'root', -> root
