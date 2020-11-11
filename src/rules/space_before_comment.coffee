regexes =
    commentPattern: /^\s*\#+.+$/ #Starts with #
    correctPattern: /^\s*\#+\s[^\s].+$/ #Starts with # and followed by a single whitespace
    blockCommentPattern: /^\s*(###)+.*$/ #Starts with ###

module.exports = class spaceBeforeComment

  rule:
    name:         "space_before_comment"
    description:  "A space must be placed between # and actual comment"
    level:        "error"
    message:      "[Comments] One (and only one) space is required after '#'"

  containsComment = false
  lintLine: (line, lineApi) ->
    # Ignore if line contains symbol of block comment (###)
    if regexes.blockCommentPattern.test line
      return false
    if regexes.commentPattern.test line
      if not regexes.correctPattern.test line
        return true
