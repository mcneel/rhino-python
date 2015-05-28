$ = require "jquery"
_ = require 'underscore'
fuzz = require "fuzzaldrin"
{MessagePanelView, LineMessageView, PlainMessageView} = require 'atom-message-panel'
ttr = require './talk-to-rhino'

module.exports =
class RhinoProvider
  selector: '.source.python'
  disableForSelector: '.source.python .comment'
  inclusionPriority: 1
  excludeLowerPriority: true
  @cachedSuggestions = []
  @callRhinoPosition = null

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    prefix = if /\s$/.test prefix then ' ' else prefix
    lines = editor.buffer.getLines()[0..bufferPosition.row]
    return [] unless lines.length
    cursorLine = lines[lines.length-1][0..bufferPosition.column-1]
    return [] unless cursorLine?
    callRhinoPosition = @getCallRhinoPosition cursorLine, lines.length-1
    return [] unless callRhinoPosition
    lineLeftOfCallRhinoPosition = lines[lines.length-1][0..callRhinoPosition.column]
    lines = if lines.length is 1 then [] else lines[0..lines.length-2]

    if (@positionsAreEqual callRhinoPosition, RhinoProvider.callRhinoPosition) and (not @stringIsCallRhinoChar prefix)
      return @filterCachedSuggestions prefix
    else
      @clearCache()
      if @stringIsOpenParen prefix
        lines.push cursorLine
        @getAndShowDocString({editor, bufferPosition}, lines)
        return []
      lines.push lineLeftOfCallRhinoPosition
      return ttr.getCompletionData lines, callRhinoPosition, editor.getPath(),
        if @stringIsCallRhinoChar prefix then null else prefix,
        @clearCache,
        (p, s) -> RhinoProvider.callRhinoPosition = p; RhinoProvider.cachedSuggestions = s,
        (pfx) => @filterCachedSuggestions pfx

  filterCachedSuggestions: (prefix) ->
    suggestions = fuzz.filter RhinoProvider.cachedSuggestions, prefix, key: 'text'
    console.log "hey", suggestions
    return suggestions.map (s) -> {text: s.text, replacementPrefix: prefix, rightLabelHTML: s.rightLabelHTML}

  stringIsCallRhinoChar: (s) ->
    /^[\s\.(]$/.test s
  stringIsOpenParen: (s) ->
    /^[(]$/.test s

  clearCache: ->
    RhinoProvider.cachedSuggestions = []
    RhinoProvider.callRhinoPosition = null

  getCallRhinoPosition: (line, row) ->
    m = line.match /[\s\.(][a-zA-Z0-9_-]*$/
    if m then {row: row, column: m.index} else null

  positionsAreEqual: (p1, p2) ->
    return false unless p1 and p2
    p1.row is p2.row and p1.column is p2.column

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
