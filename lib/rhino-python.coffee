$ = require "jquery"
shelljs = require "shelljs"
ttr = require './talk-to-rhino'
{CompositeDisposable} = require 'atom'
RhinoSettingsView = require './rhino-settings-view'
Vue = require 'vue'
remote = require 'remote'
dialog = remote.require 'dialog'
_ = require 'underscore'

module.exports =
  config:
    httpPort:
      title: 'Port Number'
      description: 'Port number that Rhino listens on for http requests.  NOTE: has to match the port number configured in Rhinoceros.'
      type: 'integer'
      default: 8080

  provider: null
  ready: false

  activate: (state) ->
    @ready = true

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'rhino-python:saveAndRunInRhino': => @saveAndRunInRhino()
    @subscriptions.add atom.commands.add 'atom-workspace', 'rhino-python:saveAndRunInRhinoFromTreeView': => @saveAndRunInRhinoFromTreeView()

    @rhinoSettingsView = new RhinoSettingsView(state.rhinoSettigsViewState)
    @modalPanel = atom.workspace.addBottomPanel(item: @rhinoSettingsView.getElement(), visible: false)
    @subscriptions.add atom.commands.add 'atom-workspace', 'rhino-python:toggleRhinoSettingsView': => @toggleRhinoSettingsView()

    v = new Vue({
      el: '#RhinoSettingsView'
      methods:
        add: ->
          p = dialog.showOpenDialog({properties:['openDirectory']})
          unless p?
            return

          fp = i.content for i in @paths when i.content == p[0]
          unless fp?
            @paths.push({content: p[0], markdelete: false})
            console.log 'paths:', @paths, 'p[0]:', p[0], 'a:', a
        save: -> alert 'save!'
      data:
        paths: [
          {
            content: '/mypath',
            markdelete: false
          },
          {
            content: '/myotherpath',
            markdelete: true
          }
        ]
    })

  localfunc: ->
    console.log 'local func'

  toggleRhinoSettingsView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  deactivate: ->
    @provider = null
    @subscriptions.dispose()

  provide: ->
    unless @provider?
      RhinoProvider = require('./rhino-autocomplete-plus-python-provider')
      @provider = new RhinoProvider()
    @provider

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
