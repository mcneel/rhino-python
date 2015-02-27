{$} = require 'atom'

module.exports =
  getCompletionData: (lines, caretColumn, path, setCached) ->
    return new Promise (resolve) ->
      suggestions = []
      ccreq = JSON.stringify {Lines: lines, CaretColumn: caretColumn, FileName: path}
      $.post "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/getcompletiondata", ccreq, 'json'
        .then (response) ->
          if /^no completion data/.test response
            console.log response
          else
            suggestions = ($.parseJSON response)?.map (cd) =>
              {word: cd.Name, prefix: '', label: '<span style="color: gray"><- Rhino</span>', renderLabelAsHtml: true}
          suggestions
        .always (newSuggestions) ->
          setCached(newSuggestions)
          resolve(newSuggestions)
        .fail (response) ->
          console.log 'getCompletionData failed:', response
  # wip: try to remove the setCached callback
  # getCompletionData: (lines, caretColumn, path) ->
  #   return new Promise (resolve) ->
  #     suggestions = []
  #     ccreq = JSON.stringify {Lines: lines, CaretColumn: caretColumn, FileName: path}
  #     $.post "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/getcompletiondata", ccreq, 'json'
  #       .then (response) ->
  #         if /^no completion data/.test response
  #           console.log response
  #         else
  #           suggestions = ($.parseJSON response)?.map (cd) =>
  #             {word: cd.Name, prefix: '', label: '<span style="color: gray"><- Rhino</span>', renderLabelAsHtml: true}
  #         suggestions
  #       .always (newSuggestions) ->
  #         resolve (newSuggestions)
  #       .fail (response) ->
  #         console.log 'getCompletionData failed:', response

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
