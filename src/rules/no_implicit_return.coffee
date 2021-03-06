CoffeeNodes = require("coffeescript/lib/coffeescript/nodes")

module.exports = class NoImplicitReturns

  rule:
    name: "no_implicit_returns"
    level: "error"
    message: "Explicit return required for multi-line function"
    description: "Checks for explicit returns in multi-line functions"

  type: (node) -> node.constructor.name

  ###*
   * Determines if a code block ends with a pure statement. If it does not,
   * register an error, as this code block will have an implicit return
   * generated.
  ###
  _lastNonComment: (list) ->
    i = list.length
    while i >= 0
      i -= 1
      if not (list[i] instanceof CoffeeNodes.LineComment or list[i] instanceof CoffeeNodes.HereComment)
        return list[i]

    return null

  visitCode: (code, astApi) ->
    # Ignore constructors, as they do not introduce implicit returns.
    if code in @constructors
      return

    # Ignore empty functions.
    expressions = code.body.expressions
    lastExpr = @_lastNonComment expressions
    if not lastExpr?
      return

    # An expression is a pure statement if it jumps(), i.e. contains:
    # return, continue (not in loop), or break (not in a loop or block)
    isPureStatement = lastExpr.jumps()

    firstLine = code.locationData.first_line + 1
    lastLine = code.locationData.last_line + 1
    lastExprLine = lastExpr.locationData.first_line + 1

    # Multi-line but doesn't end with a pure statement
    if expressions.length > 1 and not isPureStatement
      @errors.push astApi.createError
        context: code.variable
        lineNumber: firstLine
        lineNumberEnd: lastLine

    else if expressions.length == 1
      # Single line that ends with a return
      if firstLine == lastLine and @type(lastExpr) == "Return"
        @errors.push astApi.createError
          context: code.variable
          message: "Explicit return not required for single-line function"
          level: "error"
          lineNumber: firstLine
          lineNumberEnd: lastLine

      # Single-expression function that spans multiple lines with a leading newline.
      if firstLine != lastLine and not isPureStatement and firstLine != lastExprLine
        @errors.push astApi.createError
          message: "Remove leading newline or add explicit return"
          level: "error"
          context: code.variable
          lineNumber: firstLine
          lineNumberEnd: lastLine
    return

  ###*
   * Performs a recursive search for the constructor of `classNode`, heavily
   * inspired by `Class.walkBody`. If a constructor is found, it is registered
   * in `this.constructors`.
  ###
  visitClass: (classNode) ->
    classNode.traverseChildren false, (child) =>
      if @type(child) != "Block"
        return
      for value in child.expressions when @type(value) == "Value"
        if not value.isObject(true)
          continue
        for assign in value.base.properties when @type(assign) == "Assign"
          if assign.variable.base.value == "constructor"
            @constructors.push assign.value
      return
    return

  lintAST: (root, astApi) ->
    # Visit AST once, registering all constructors.
    @constructors = []
    root.traverseChildren true, (child) =>
      if @type(child) == "Class"
        @visitClass(child)
      return

    # Visit AST again, processing all non-constructor functions.
    root.traverseChildren true, (child) =>
      if @type(child) == "Code"
        @visitCode child, astApi
      return
    return
