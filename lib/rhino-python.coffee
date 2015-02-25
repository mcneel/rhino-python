{$} = require 'atom'
shelljs = require "shelljs"

module.exports =
  config:
    httpPort:
      title: 'Port Number'
      description: 'Port number that Rhino listens on for http requests.  NOTE: has to match the port number configured in Rhinoceros.'
      type: 'integer'
      default: 8080

  provider: null
  ready: false

  activate: ->
    @ready = true
    atom.workspaceView.command "rhino-python:saveAndRunInRhino", => @saveAndRunInRhino()

  deactivate: ->
    @provider = null

  getProvider: ->
      return @provider if @provider?
      RhinoProvider = require('./rhino-autocomplete-plus-python-provider')
      @provider = new RhinoProvider()
      return @provider

  provide: ->
    return {provider: @getProvider()}

  rhinoPath: null
  saveAndRunInRhino: ->
    rhinoIsntListeningMsg = "Rhino isn't listening for requests.  Run the \"StartAtomEditorListener\" command from within Rhino."
    editor = atom.workspace.getActiveTextEditor()
    if editor and not /.py$/.test editor.getPath()
      alert("Can't save and run.  Not a python file.")
      return
    editor.save()

    if not @rhinoIsListening()
      alert(rhinoIsntListeningMsg)
      return
    else
      @bringRhinoToFront()

    rpfreq = JSON.stringify {FileName: editor.getPath()}
    rhinoUrl = "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/runpythonscriptfile"
    $.ajax
      type: "POST"
      url: rhinoUrl
      data: rpfreq
      retryLimit: 0
      success: (response) ->
        console.log "success:", response.msg
      error: (response, status, error) ->
        if /^NetworkError/.test response.statusText
          alert(rhinoIsntListeningMsg)
        else
          console.log "error:", response, status, error
          alert("Could not run python script in Rhino (check Atom Console).")
      contentType: "application/json"
      dataType: "json"
      async: false
      #timeout: 3000  # timeout doesn't work when async is false

  rhinoIsListening: =>
    isListening = false
    pathToRhino = null
    rhinoUrl = "http://localhost:#{atom.config.get 'rhino-python.httpPort'}/ping"
    try
      $.ajax
        type: "GET"
        url: rhinoUrl
        retryLimit: 0
        success: (response) ->
          if /Rhinoceros.app$/.test response.msg
            pathToRhino = response.msg unless response.msg is "Talk to me"
          isListening = true
        error: (response) ->
          #if /^NetworkError/.test response.statusText
          console.log "error:", response
        dataType: "json"
        async: false
    finally
      @rhinoPath = pathToRhino if pathToRhino?
      return isListening

  bringRhinoToFront: =>
    if @rhinoPath
      console.log "bringRhinoToFront: open #{@rhinoPath}"
      rhino = shelljs.exec("open #{@rhinoPath}", async: true, (code, output) ->
        console.log "bringRhinoToFront: exit code: #{code}"
        console.log "bringRhinoToFront: output: #{output}" unless not output
      )
