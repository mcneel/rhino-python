{BufferedProcess, $}  = require "atom"
_ = require 'underscore'
fuzz = require "fuzzaldrin"
{MessagePanelView, LineMessageView, PlainMessageView} = require 'atom-message-panel'
ttr = require './talk-to-rhino'

module.exports =
class RhinoProvider
  id: 'rhino-python-rhinoprovider'
  selector: '.source.python'
  blacklist: '.source.python .comment'
  providerblacklist: 'autocomplete-plus-fuzzyprovider'
  @cachedSuggestions = []

  requestHandler: (options) ->
    lines = options.buffer.getLines()[0..options.position.row]
    return [] unless lines.length
    cursorLine = lines[lines.length-1][0..options.position.column-1]
    return [] unless cursorLine?

    lines = lines[0..lines.length-1]
    lines.push cursorLine

    if @endsWithWordThatIsPrecededBySpaceOrDot cursorLine
      suggestions = fuzz.filter RhinoProvider.cachedSuggestions, options.prefix, key: 'word'
      return suggestions.map (s) -> {word: s.word, prefix: options.prefix, label: s.label, renderLabelAsHtml: true}

    return [] unless @rhinoNeedsToBeQueriedForCompletionData lines, cursorLine

    if @endsWithOpenParen cursorLine
      @getAndShowDocString(options, lines)
      return []

    return ttr.getCompletionData lines, options.position.column, options.editor.getPath(),
      (suggestions) -> RhinoProvider.cachedSuggestions = suggestions

  endsWithOpenParen: (text) ->
    /.+\($/.test text

  endsWithWordThatIsPrecededBySpaceOrDot: (text) ->
    /[\s\.]\b[a-zA-Z0-9_-]*\b$/.test text

  rhinoNeedsToBeQueriedForCompletionData: (lines, text) ->
    lines.length and /.+[\s\.(]$/.test text

  getAndShowDocString: (options, lines) ->
    ttr.getDocString options, lines
      .done (ds) ->
        RhinoProvider.showDocString ds


  # todo: UI stuff doesn't belong here
  messages: null
  @showDocString: (ds) ->
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
