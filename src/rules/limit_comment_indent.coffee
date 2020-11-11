regexes =
    lineCommentPattern: /^\s*\#+.+$/
    blockCommentPattern: /^\s*\#+\#+\#+.*$/
    nonCommentPattern: /\S/

module.exports = class LimitCommentIndent

  rule:
    name:         "limit_comment_indent"
    description:  "Comments must have the same indent as the previous line"
    level:        "error"
    message:      "[Comments] Comments must have the same indent as the previous line"

  lineComment = false
  blockComment = "none"
  commentIndentLevel = 0
  endCommentIndentLevel = 0 # For storing indent level of the 2nd "###" only
  codeIndentLevel = 0

  # Detects if there's a block comment first, since it also fits the ordinary single-line comment pattern
  # Lints if the indent level of the beginning "###" and ending "###" is misaligned
  # Also lints if the code line after the ending "###" does not align with the ending ###
  lintLine: (line, lineApi) ->
    # Starting with block comments since it also matches the line comment pattern
    # but we want to check if the two "###" symbols are aligned in addition
    if (blockComment == "start" or blockComment == "end" or regexes.blockCommentPattern.test line)
      # Matches "###"
      if regexes.blockCommentPattern.test line
        if blockComment == "none"
          blockComment = "start"
          commentIndentLevel = line.indexOf "#"
        # Checks if the second "###" has the same level of indent as the first one
        else if blockComment == "start"
          blockComment = "end"
          endCommentIndentLevel = line.indexOf "#"
          if commentIndentLevel != endCommentIndentLevel
            return {message: "[Comments] Block comment symbols(###) are not aligned"}
      # Ignore the line if still inside the comment block
      else if blockComment == "start"
        return false
      # Checks if the following line has the same indent level of the previous "###"
      else if blockComment == "end"
        blockComment = "none"
        codeIndentLevel = line.search regexes.nonCommentPattern
        if endCommentIndentLevel != codeIndentLevel
          return true
    # Perform single line comment check if it's not block comment
    else if regexes.lineCommentPattern.test line
      lineComment = true
      commentIndentLevel = line.indexOf "#"
    else if lineComment
      lineComment = false
      codeIndentLevel = line.search regexes.nonCommentPattern
      if commentIndentLevel != codeIndentLevel
        return true
      else return false
