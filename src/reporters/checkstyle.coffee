JsLintReporter = require './jslint'

module.exports = class CheckstyleReporter

    constructor: (@errorReport, options = {}) ->
        { @quiet } = options

    print: (message) ->
        # coffeelint: disable=no_debugger
        console.log message
        # coffeelint: enable=no_debugger

    escape: JsLintReporter::escape

    publish: () ->
        @print '<?xml version="1.0" encoding="utf-8"?>'
        @print '<checkstyle version="4.3">'

        for path, errors of @errorReport.paths
            if errors.length
                @print "<file name=\"#{path}\">"

                for e in errors when not @quiet or e.level is 'error'
                    level = e.level
                    level = 'warning' if level is 'warn'

                    # context is optional, this avoids generating the string
                    # "context: undefined"
                    context =
                      if e.context then "; context: #{e.context}"
                      else ''
                    @print """
                    <error line="#{e.lineNumber}"
                        severity="#{@escape(level)}"
                        message="#{@escape(e.message+context)}"
                        source="coffeelint"/>
                    """
                @print '</file>'

        @print '</checkstyle>'
