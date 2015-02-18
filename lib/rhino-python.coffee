#RhinoPythonView = require './rhino-python-view'
#RhinoAutocompletePlusPythonProvider = require './rhino-autocomplete-plus-python-provider'
{$} = require 'atom'
shelljs = require "shelljs"

module.exports = RhinoPython =
  config:
    httpPort:
      title: 'Port Number'
      description: 'Port number that Rhino listens on for http requests.  NOTE: has to match the port number configured in Rhinoceros.'
      type: 'integer'
      default: 8080

  #rhinoPythonView: null
  editorSubscription: null
  autocomplete: null
  providers: []
  rhinoPath: null

  #"activationCommands": {
  #  "atom-workspace": "rhino-python:toggle"
  #},
  #"activationEvents": ["rhino-python:saveAndRunInRhino"],
  activate: (state) ->
    console.log 'state', state
    #@rhinoPythonView = new RhinoPythonView(state.rhinoPythonViewState)
    atom.workspaceView.command "rhino-python:saveAndRunInRhino", => @saveAndRunInRhino()

    atom.packages.activatePackage("autocomplete-plus")
      .then (pkg) =>
        @autocomplete = pkg.mainModule
        return unless @autocomplete?
        console.log 'before Provider'
        Provider = (require './rhino-autocomplete-plus-python-provider').ProviderClass(@autocomplete.Provider, @autocomplete.Suggestion)
        return unless Provider?
        console.log 'after Provider'
        @editorSubscription = atom.workspace.observeTextEditors((editor) => @registerProvider(Provider, editor))

    #ac+ doesn't fire when "(" is typed so create a command for now
    console.log 'activate rhino-python'
    atom.workspaceView.command "rhino-python:getDocString", => @getDocString()
    atom.workspaceView.command "rhino-python:deactivate", => @deactivate()
    atom.workspaceView.command "rhino-python:activate", => @activate()

  getDocString: ->
    console.log 'rhino-python getDocString', @providers
    @providers[0].getDocString()

  registerProvider: (Provider, editor) ->
    return unless Provider?
    return unless editor?
    editorView = atom.views.getView(editor)
    return unless editorView?
    if not editorView.mini
      provider = new Provider(editor)
      @autocomplete.registerProviderForEditor(provider, editor)
      @providers.push(provider)

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @providers.forEach (provider) =>
      @autocomplete.unregisterProvider provider
    @providers = []
    console.log 'providers', @providers

  #serialize: ->
  #  rhinoPythonViewState: @rhinoPythonView.serialize()

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
      @rhinoPath = pathToRhino
      return isListening

  bringRhinoToFront: =>
    if @rhinoPath
      #rhino = shelljs.exec("open /Users/acormier/Library/Developer/Xcode/DerivedData/MacRhino-eyizkxchsvxtptaqlkvbexthtwuy/Build/Products/Debug/Rhinoceros.app", async: true)
      console.log "bringRhinoToFront: open #{@rhinoPath}"
      rhino = shelljs.exec("open #{@rhinoPath}", async: true, (code, output) ->
        console.log "bringRhinoToFront: exit code: #{code}"
        console.log "bringRhinoToFront: output: #{output}" unless not output
      )
