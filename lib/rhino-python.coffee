#RhinoPythonView = require './rhino-python-view'
RhinoAutocompletePlusPythonProvider = require './rhino-autocomplete-plus-python-provider'
jQuery = require "jquery"

module.exports =
  #rhinoPythonView: null
  editorSubscription: null
  autocomplete: null
  providers: []

  #"activationCommands": {
  #  "atom-workspace": "rhino-python:toggle"
  #},
  #"activationEvents": ["rhino-python:saveAndRunInRhino"],
  activate: (state) ->
    #@rhinoPythonView = new RhinoPythonView(state.rhinoPythonViewState)
    atom.workspaceView.command "rhino-python:saveAndRunInRhino", => @saveAndRunInRhino()
    atom.packages.activatePackage("autocomplete-plus")
      .then (pkg) =>
        @autocomplete = pkg.mainModule
        @registerProviders()

  deactivate: ->
    #@rhinoPythonView.destroy()
    @editorSubscription?.off()
    @editorSubscription = null
    @providers.forEach (provider) =>
      @autocomplete.unregisterProvider provider
    @providers = []

  registerProviders: ->
    @editorSubscription = atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini
        provider = new RhinoAutocompletePlusPythonProvider editorView
        @autocomplete.registerProviderForEditorView provider, editorView
        @providers.push provider

  #serialize: ->
  #  rhinoPythonViewState: @rhinoPythonView.serialize()

  saveAndRunInRhino: ->
    editor = atom.workspace.getActiveTextEditor()
    if editor and not /.py$/.test editor.getPath()
      alert("Can't save and run.  Not a python file.")
      return
    editor.save()
    rpfreq = JSON.stringify {FileName: editor.getPath()}
    jQuery.ajax
      type: "POST"
      url: "http://localhost:8080/runpythonscriptfile"
      data: rpfreq
      retryLimit: 0
      success: (response) ->
        console.log "success:", response
      error: (response, status, error) ->
        if /^NetworkError/.test response.statusText
          alert("Rhino isn't listening for requests.  Run the \"StartAtomEditorListener\" command from within Rhino.")
        else
          console.log "error:", response, status, error
          alert("Could not run python script in Rhino (check Atom Console).")
      contentType: "application/json"
      dataType: "json"
      async: false
      #timeout: 3000  # timeout doesn't work when async is false
