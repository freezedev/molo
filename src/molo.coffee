# ES 5 compability function
Object.keys or= (o) -> name for own name of o

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
    for i in deps
      if cache[i]
        cacheDeps.push cache[i]
      else
        queue[name] = defines
        return undefined

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

  moloConfig = {}

  root.molo = moloFunc
  root.molo.config = moloConfig
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