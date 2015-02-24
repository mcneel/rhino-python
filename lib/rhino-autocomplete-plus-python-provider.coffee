{BufferedProcess, $}  = require "atom"
_ = require 'underscore'
fuzz = require "fuzzaldrin"
{MessagePanelView, LineMessageView, PlainMessageView} = require 'atom-message-panel'

exports.fetchedCompletionData = []

module.exports =
class RhinoProvider
  id: 'rhino-python-rhinoprovider'
  selector: '.source.python'
  blacklist: '.source.python .comment'

  requestHandler: (options) ->
    lines = options.buffer.getLines()[0..options.position.row]
    return [] unless lines.length
    cursorLine = lines[lines.length-1][0..options.position.column-1]
    return [] unless cursorLine?

    lines = lines[0..lines.length-1]
    lines.push cursorLine

    if @endsWithWordThatIsPrecededBySpaceOrDot cursorLine
      suggestions = fuzz.filter exports.fetchedCompletionData, options.prefix, key: 'word'
      return suggestions.map (s) -> {word: s.word, prefix: options.prefix, label: s.label, renderLabelAsHtml: true}

    return [] unless @rhinoNeedsToBeQueriedForCompletionData lines, cursorLine

    if /.+\($/.test cursorLine
      ds = @getDocString(options, lines)
      if ds?
        @showDocString ds
        return []

    ccreq = JSON.stringify {Lines: lines, CaretColumn: options.position.column, FileName: options.editor.getPath()}

    suggestions = []
    $.ajax
      type: "POST"
      url: "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/getcompletiondata"
      data: ccreq
      retryLimit: 0
      success: (data) ->
        if not /^no completion data/.test data
          suggestions = data.map (s) =>
            {word: s.Name, prefix: '', label: '<span style="color: gray"><- Rhino</span>', renderLabelAsHtml: true}
        else
          console.log data
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

    exports.fetchedCompletionData = suggestions
    return suggestions

  endsWithWordThatIsPrecededBySpaceOrDot: (cursorLine) ->
    /[\s\.]\b[a-zA-Z0-9_-]*\b$/.test cursorLine

  rhinoNeedsToBeQueriedForCompletionData: (lines, cursorLine) ->
    lines.length and /.+[\s\.(]$/.test cursorLine

  getDocString: (options, lines) ->
    lines[lines.length-1] = lines[lines.length-1].replace /\($/, ''
    ccreq = JSON.stringify {Lines: lines, CaretColumn: options.position.column, FileName: options.editor.getPath()}
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

    return docString


  # todo: UI stuff doesn't belong here
  messages: null
  showDocString: (ds) ->
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
    msg = """<div class="panel-body padded" style="overflow-y: scroll; max-height: 170px;">#{rest_html.join('\n')}</div>"""
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

  dispose: ->
    console.log 'dispose rhino-python'
