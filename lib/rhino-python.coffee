#RhinoPythonView = require './rhino-python-view'
#RhinoAutocompletePlusPythonProvider = require './rhino-autocomplete-plus-python-provider'
jQuery = require "jquery"
shelljs = require "shelljs"

module.exports = RhinoPython =
  config:
    httpPort:
      title: 'Port Number'
      description: 'Port number that Rhino listens on for http requests.  NOTE: has to match the port number configured in Rhinoceros.'
      type: 'integer'
      default: 8080
    rhinoPath:
      title: 'Rhinoceros Path'
      description: 'Rhinoceros application path.  ex: /Applications/Rhinoceros.app'
      type: 'string'
      default: '/Applications/Rhinoceros.app'

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
        return unless @autocomplete?
        Provider = (require './rhino-autocomplete-plus-python-provider').ProviderClass(@autocomplete.Provider, @autocomplete.Suggestion)
        return unless Provider?
        @editorSubscription = atom.workspace.observeTextEditors((editor) => @registerProvider(Provider, editor))

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
    #@rhinoPythonView.destroy()
    @editorSubscription?.off()
    @editorSubscription = null
    @providers.forEach (provider) =>
      @autocomplete.unregisterProvider provider
    @providers = []

  #serialize: ->
  #  rhinoPythonViewState: @rhinoPythonView.serialize()

  saveAndRunInRhino: ->
    editor = atom.workspace.getActiveTextEditor()
    if editor and not /.py$/.test editor.getPath()
      alert("Can't save and run.  Not a python file.")
      return
    editor.save()

    @bringRhinoToFront()

    rpfreq = JSON.stringify {FileName: editor.getPath()}
    rhinoUrl = "http://localhost:#{ atom.config.get 'rhino-python.httpPort'}/runpythonscriptfile"
    jQuery.ajax
      type: "POST"
      url: rhinoUrl
      data: rpfreq
      retryLimit: 0
      success: (response) ->
        console.log "success:", response.msg
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

  bringRhinoToFront: =>
    #rhino = shelljs.exec("open /Users/acormier/Library/Developer/Xcode/DerivedData/MacRhino-eyizkxchsvxtptaqlkvbexthtwuy/Build/Products/Debug/Rhinoceros.app", async: true)
    rhinoPath = "open #{ atom.config.get 'rhino-python.rhinoPath'}"
    console.log "bringRhinoToFront: #{rhinoPath}"
    rhino = shelljs.exec(rhinoPath, async: true, (code, output) ->
      console.log "bringRhinoToFront: exit code: #{code}"
      console.log "bringRhinoToFront: output: #{output}" unless not output
    )
