{$} = require 'atom'

module.exports =
  getCompletionData: (lines, callRhinoPosition, path, prefix, clearCache, cache, filter) ->
    return new Promise (resolve) ->
      suggestions = []
      ccreq = JSON.stringify {Lines: lines, CaretColumn: callRhinoPosition.column, FileName: path}
      console.log 'ccreq:', ccreq
      $.post "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/getcompletiondata", ccreq, 'json'
        .then (response) ->
          if /^no completion data/.test response
            console.log response
          else
            suggestions = ($.parseJSON response)?.map (cd) =>
              {word: cd.Name, prefix: '', label: '<span style="color: gray"><- Rhino</span>', renderLabelAsHtml: true}
            console.log "fetched from Rhino: #{suggestions?.length} suggestions"
          suggestions
        .always (newSuggestions) ->
          cache(callRhinoPosition, newSuggestions)
          resolve(if prefix then filter(prefix) else newSuggestions)
        .fail (response) ->
          console.log 'getCompletionData failed:', response

  getDocString: (options, lines) ->
    lines[lines.length-1] = lines[lines.length-1].replace /\($/, ''
    ccreq = JSON.stringify {Lines: lines, CaretColumn: options.position.column, FileName: options.editor.getPath()}
    return $.post "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/getdocstring", ccreq, 'json'
      .then (response) ->
        if /^no completion data/.test response then response else ($.parseJSON response)?.ds

  rhinoIsListening: ->
    return $.getJSON "http://localhost:#{atom.config.get 'rhino-python.httpPort'}/ping"
      .then (response) ->
        if /Rhinoceros.app$/.test response.msg then [true, response.msg] else false

  runInRhino: (path) ->
    rpfreq = JSON.stringify {FileName: path}
    rhinoUrl = "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/runpythonscriptfile"
    $.post rhinoUrl, rpfreq, 'json'
      .then (response) ->
        ($.parseJSON response)?.msg
