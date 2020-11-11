regexes =
    lineCommentPattern: /^\s*\#+.+$/
    blockCommentPattern: /^\s*(###)+.*$/
    isEmptyLine: /^[\n\s+]*$/
    classDeclaration: /^.*(class\ )+[A-Z]+.*$/

module.exports = class NoNewLinesAfterClass
  rule:
    name:         "no_newlines_after_class"
    description:  "Forbids newlines after class declaration"
    level:        "error"
    message:      "Remove newlines after class declaration"

  afterClassDeclaration = false
  insideBlockComment = false

  lintLine: (line, lineApi) ->
    # Perform block comment check
    if regexes.blockCommentPattern.test line
      insideBlockComment = !insideBlockComment

    # Ignore if code is inside either single line or block comment
    if insideBlockComment or regexes.lineCommentPattern.test line
      return false

    # Test whether the line is empty if afterClassDeclaration is true
    if afterClassDeclaration
      afterClassDeclaration = false
      return regexes.isEmptyLine.test line

    # Set afterClassDeclaration flag to true if the current line contains class declaration
    afterClassDeclaration = regexes.classDeclaration.test line
    return false
