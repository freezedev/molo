# ES 5 compability function
Object.keys or= (o) -> name for own name of o

do (root = exports ? this) ->
  cache = {}
  queue = {}

  moloFunc = (name, defines) ->
    return undefined unless name and defines

    if typeof defines is 'function' then define = defines else {define, require: deps, context} = defines

    deps = [] unless deps?
    context = @ unless context?

    if typeof deps is 'string' then deps = [deps]
    cacheDeps = []
    for i in deps
      if cache[i]
        cacheDeps.push cache[i]
      else
        queue[name] = defines
        return undefined

    cache[name] = define.apply context, cacheDeps

    # Check queue
    if Object.keys(queue).length > 0
      for own key, value of queue
        module key, value

      delete queue[key]

    null

  moloConfig = {}

  root.molo = moloFunc
  root.molo.config = moloConfig

  root.module = moloFunc

  # Compability to official definition
  root.define = (name, deps, defines) -> 
    moloFunc name, 
      require: deps, 
      define: defines