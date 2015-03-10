{$} = require 'atom'
shelljs = require "shelljs"
ttr = require './talk-to-rhino'

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
    atom.workspaceView.command "rhino-python:saveAndRunInRhinoFromTreeView", => @saveAndRunInRhinoFromTreeView()

  deactivate: ->
    @provider = null

  getProvider: ->
      return @provider if @provider?
      RhinoProvider = require('./rhino-autocomplete-plus-python-provider')
      @provider = new RhinoProvider()
      return @provider

  provide: ->
    return {provider: @getProvider()}

  saveAndRunInRhino: ->
    rhinoIsntListeningMsg = "Rhino isn't listening for requests.  Run the \"StartAtomEditorListener\" command from within Rhino."
    editor = atom.workspace.getActiveTextEditor()
    if editor and not /.py$/.test editor.getPath()
      alert("Can't save and run.  Not a python file.")
      return
    editor.save()
    ttr.rhinoIsListening()
      .done (isListening) =>
        [isListening, rhinoPath] = isListening
        if isListening
          @bringRhinoToFront(rhinoPath)
          ttr.runInRhino editor.getPath()
            .done (msg) ->
              console.log msg
            .fail (errorObject) ->
              alert(rhinoIsntListeningMsg)
        else
          alert(rhinoIsntListeningMsg)
      .fail (errorObject) ->
        alert(rhinoIsntListeningMsg)

  bringRhinoToFront: (rhinoPath) ->
    #console.log "bringRhinoToFront: open #{rhinoPath}"
    rhino = shelljs.exec("open #{rhinoPath}", async: true, (code, output) ->
      #console.log "bringRhinoToFront: exit code: #{code}"
      console.log "bringRhinoToFront: output: #{output}" unless not output
    )

  saveAndRunInRhinoFromTreeView: ->
    #s = document.querySelectorAll('[is="tree-view-file"] .selected [data-name$=".py"]')
    selected = document.querySelectorAll('[is="tree-view-file"].selected span')
    if selected.length isnt 1
      alert('This command can only be run when exactly 1 file is selected')
      return
    fileName = selected[0].attributes["data-path"].value
    atom.workspace.open fileName
      .done (o) =>
        @saveAndRunInRhino()
