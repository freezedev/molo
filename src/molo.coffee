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
do (root = exports ? this) ->
  cache = {}
  queue = {}
  pathSep = '/'

  moloFunc = (name, defines) ->
    # Skip flag to skip the rest of the function
    skipFunc = false

    # If name is not a string, it's an anonymous module (Put defines parameter in the correct order)
    if typeof name isnt 'string'
      # If name is an array, just load dependencies
      if Array.isArray(name) 
        defines =
          require: name

        skipFunc = true
      else 
        [name, defines] = [undefined, name]

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
      if cache[i]
        cacheDeps.push cache[i]
      else
        unless isCommonJS
          # Create script element
          scriptElem = root.document.createElement 'script'
          scriptElem.async = true

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

          scriptElem.src = scriptPath

          # Append script element to the head of the page
          root.document.head.appendChild scriptElem

        # Add script definition to queue
        queue[name] = defines

        # Set skip flag
        # We need to go through the rest of the dependencies,
        # but not the rest of the function
        skipFunc = true

    # Skip function now
    return undefined if skipFunc

    # Execute factory function and store it in cache
    cache[name] = define.apply context, cacheDeps

    # Check queue
    queueList = Object.keys(queue)

    for q in queueList
      # Have all required dependencies been loaded?
      maxDeps = queue[q].require.length
      curDeps = 0

      (curDeps++ if cache[d]) for d in queue[q].require

      # Reload module and delete item from queue
      if curDeps is maxDeps
        modName = q
        modDefinition = queue[q]
        delete queue[q]
        moloFunc modName, modDefinition

    null

  # Map molo function
  root.molo = moloFunc

  # Set path configuration
  root.molo.basePath = ''
  root.molo.paths = {}

  # Completely clear all caches
  root.molo.clear = ->
    cache = {}
    queue = {}

  # Delete a single module from cache, which forces it to
  # reload this module if it comes up as a dependency the
  # next time
  root.molo.delete = (name) ->
    delete cache[name] if cache[name]
    delete queue[name] if queue[name]

  # Overwrite module only if it hasn't been defined
  root.module or= moloFunc

  # Compability to official definition
  root.define = (name, deps, defines) -> 
    moloFunc name, 
      require: deps, 
      define: defines

  # Some general definitions
  root.define.amd =
    jQuery: true