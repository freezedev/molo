# ES 5 compability function
Object.keys or= (o) -> name for own name of o

# CommonJS flag
isCommonJS = exports?

do (root = exports ? this) ->
  cache = {}
  queue = {}

  moloFunc = (name, defines) ->
    # If name is not a string, it's an anonymous module (Put defines parameter in the correct order)
    if typeof name isnt 'string' then [name, defines] = [undefined, name]

    # Get properties from defines if it's an object, else they are no dependencies and take the function as the factory
    if typeof defines is 'function' then define = defines else {define, require: deps, context} = defines

    # Default parameters, if they have not been defined yet
    deps = [] unless deps?
    context = @ unless context?

    # If a single dependency has been declared as a string, make it into an array
    if typeof deps is 'string' then deps = [deps]

    # Get the result of cached dependencies
    cacheDeps = []

    # Skip flag to skip the rest of the function
    skipFunc = false

    for i in deps
      if cache[i]
        cacheDeps.push cache[i]
      else
        unless isCommonJS
          scriptElem = root.document.createElement 'script'
          scriptElem.async = true

          prePath = ''
          pathArray = Object.keys(root.molo.paths)

          for p in pathArray
            # TODO: Problem: 'abc'.indexOf('a') === 'abc'.indexOf('ab')
            if root.molo.paths[p] and name.indexOf(root.molo.paths[p]) is 0
              prePath = root.molo.paths[p]

          scriptPath = if prePath then "#{prePath}/#{i}.js" else "#{i}.js"

          scriptElem.src = scriptPath

          root.document.head.appendChild scriptElem

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

  root.molo = moloFunc
  root.molo.paths = {}
  root.molo.clear = ->
    cache = {}
    queue = {}

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

  root.define.amd =
    jQuery: true