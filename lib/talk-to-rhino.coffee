{$} = require 'atom'

module.exports =
  getCompletionData: (lines, caretColumn, path, setFetched) ->
    return new Promise (resolve) ->
      ccreq = JSON.stringify {Lines: lines, CaretColumn: caretColumn, FileName: path}
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
            setFetched suggestions
            resolve(suggestions)
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
        async: true
        timeout: 3000

  getDocString: (options, lines) ->
    lines[lines.length-1] = lines[lines.length-1].replace /\($/, ''
    ccreq = JSON.stringify {Lines: lines, CaretColumn: options.position.column, FileName: options.editor.getPath()}
    return $.post "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/getdocstring", ccreq, 'json'
      .then (response) ->
        if /^no completion data/.test response then response else ($.parseJSON response)?.ds
