{BufferedProcess, $}  = require "atom"
_ = require 'underscore'
fuzz = require "fuzzaldrin"
{MessagePanelView, LineMessageView, PlainMessageView} = require 'atom-message-panel'

exports.fetchedCompletionData = []

module.exports =
ProviderClass: (Provider, Suggestion) ->
  class RhinoAutocompletePlusPythonProvider extends Provider
    exclusive: true
    wordRegex: /[\s\.]\b[a-zA-Z0-9_-]*\b$/ # word following a dot or space
    messages: null

    getInstance: ->
      return this

    fileIsPython: ->
      return /.py$/.test @editor.getPath()

    prefixOfSelection: (selection) ->
      selectionRange = selection.getBufferRange()
      lineRange = [[selectionRange.start.row, 0], [selectionRange.end.row, @editor.lineLengthForBufferRow(selectionRange.end.row)]]
      prefix = ""
      @editor.getBuffer().scanInRange @wordRegex, lineRange, ({match, range, stop}) ->
        stop() if range.start.isGreaterThan(selectionRange.end)

        if range.intersectsWith(selectionRange)
          prefixOffset = selectionRange.start.column - range.start.column
          prefix = match[0][0...prefixOffset] if range.start.isLessThan(selectionRange.start)

      return prefix

    getDocString: ->
      return unless @fileIsPython()
      console.log 'getDocString debug'
      bp = @editor.getCursorBufferPosition()
      lines = @editor.getTextInBufferRange([[0,0], [bp.row, bp.column]]).split "\n"
      ccreq = JSON.stringify {Lines: lines, CaretColumn: bp.column, FileName: @editor.getPath()}
      docString = null
      $.ajax
        type: "POST"
        url: "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/getdocstring"
        data: ccreq
        retryLimit: 0
        success: (data) ->
          if not /^no completion data/.test data
            docString = data
          docString = data.ds
          console.log 'docString', docString
        error: (data) ->
          if /^NetworkError/.test data.statusText
            alert("Rhino isn't listening for requests.  Run the \"StartAtomEditorListener\" command from within Rhino.")
          else
            if not /^no completion data/.test data.responseText
              console.log "error:", data
        contentType: "application/json"
        dataType: "json"
        async: false
        timeout: 3000

      if docString?
        @showDocString(docString)

    buildSuggestions: ->
      return unless @fileIsPython()
      bp = @editor.getCursorBufferPosition()
      lines = @editor.getTextInBufferRange([[0,0], [bp.row, bp.column]]).split "\n"
      prefix = ""
      if lines.length
        match = @wordRegex.exec lines[lines.length-1]
        prefix = match[0] if match and match.length == 1

      if prefix.length
        prefix = prefix.replace /^[\s\.]/, ''
        suggestionNames = exports.fetchedCompletionData.map (cd) -> cd.Name
        words = fuzz.filter suggestionNames, prefix
        suggestions = words.map (w) => new Suggestion(this, prefix: prefix, word: w)
        return suggestions

      # if line left of cursor starts with a character (not space or dot) and ends with a space or dot
      # then fetch a new list of possible words from Rhino
      return unless lines.length and /.+[\s\.]$/.test lines[lines.length-1]

      # @todo: prefix.length is always 0 no?
      last_dot_or_space_column = bp.column - prefix.length
      ccreq = JSON.stringify {Lines: lines, CaretColumn: bp.column - prefix.length, FileName: @editor.getPath()}

      $.ajax
        type: "POST"
        url: "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/getcompletiondata"
        data: ccreq
        retryLimit: 0
        success: (data) ->
          if not /^no completion data/.test data
            exports.fetchedCompletionData = data
          else
            exports.fetchedCompletionData = []
        error: (data) ->
          if /^NetworkError/.test data.statusText
            alert("Rhino isn't listening for requests.  Run the \"StartAtomEditorListener\" command from within Rhino.")
          else
            if not /^no completion data/.test data.responseText
              console.log "error:", data
        contentType: "application/json"
        dataType: "json"
        async: false
        timeout: 3000

      suggestions = (exports.fetchedCompletionData).map (cd) => new Suggestion(this, prefix:"", word: cd.Name)
      return suggestions

    showDocString: (ds) ->
      #console.log _.map [10,20,30], (i) -> i * 2
      if @messages?
        @messages.close()
        @messages = null

      [first, ...] = ds.split '\n'
      rest = ds.split('\n')[2..]

      # <div class="panel-body padded" style="overflow-y: scroll; max-height: 170px;">
      #   <div class="plain-message" is="space-pen-div">doh</div>
      # </div>

      # convert ' ' and '|' to &nbsp;
      rest = _.map rest, (s) -> (_.map s, (c) -> if c is ' ' or c is '|' then '&nbsp;' else c).join("")
      # remove empty lines
      rest = _.reject rest, (s) -> /^(\s|&nbsp;)*$/.test s

      rest_html = _.map rest, (ln) -> """<div class="plain-message" is="space-pen-div" style="font-family:courier">#{ln}</div>"""
      msg = """<div class="panel-body" style="overflow-y: scroll; max-height: 170px;">#{rest_html.join('\n')}</div>"""
      #msg = """<div class="panel-body padded" style="overflow-y: scroll; max-height: 170px;"><textarea class="plain-message" is="space-pen-div" rows="#{rest.length}" style="width:100%">#{rest.join('\n')}</textarea></div>"""

      @messages = new MessagePanelView
        title: first

      @messages.clear()
      @messages.add new PlainMessageView
          #message: "<![CDATA[" + ds + "]]"
          #message: """<textarea class="panel-body plain-message" rows="#{rest.length}" style="width:100%">#{rest.join('\n')}</textarea>"""
          message: msg
          raw: true
          #className: 'panel-body padded'
      @messages.attach()
