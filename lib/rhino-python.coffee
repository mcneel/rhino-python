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

  _indexOf: (coll, item) ->
    _.indexOf(coll, item)

  activate: (state) ->
    @ready = true

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'rhino-python:saveAndRunInRhino': => @saveAndRunInRhino()
    @subscriptions.add atom.commands.add 'atom-workspace', 'rhino-python:saveAndRunInRhinoFromTreeView': => @saveAndRunInRhinoFromTreeView()

    @rhinoSettingsView = new RhinoSettingsView(state.rhinoSettigsViewState)
    @modalPanel = atom.workspace.addBottomPanel(item: @rhinoSettingsView.getElement(), visible: false)
    @subscriptions.add atom.commands.add 'atom-workspace', 'rhino-python:toggleRhinoSettingsView': => @toggleRhinoSettingsView()

    @v = new Vue({
      el: '#RhinoSettingsView'
      methods:
        add: ->
          path_to_add = dialog.showOpenDialog({properties:['openDirectory']})
          unless path_to_add?
            return
          #dup_path = _.find(@paths, (p) -> p.path == path_to_add[0])
          for p in @paths
            if p.selected
              dup_path = p
          unless dup_path?
            console.log 'no dup_path', @paths
            len = @paths.push({path: path_to_add[0], selected: false})
            console.log 'paths:', @paths
            @dirty = true
            #@select _.last(@paths)
            @select @paths[len-1]
        delete: ->
          unless @aPathIsSelected()?
            # this should never happen
            alert 'no path is selected'
          sp = @selectedPath()
          #newps = _.reject(@paths, (p) -> p.path == sp.path)
          #@paths = newps
          idx = -1
          `for (i = 0; i < this.paths.length; i++) {
            if (this.paths[i].path == sp.path) {
              idx = i;
            }
          }`
          #newps = _.reject(@paths, (p) -> p.path == sp.path)
          @paths.splice(idx, 1) # delete from array
          @dirty = true
          @setBtnEnabled()
        moveUp: -> @move('up')
        moveDown: -> @move('down')
        move: (upOrDown) ->
          if upOrDown == 'up' and @selectedIsFirst()
            return
          if upOrDown == 'down' and @selectedIsLast()
            return
          @dirty = true
          sp = @selectedPath()
          #idx = _.indexOf(@paths, sp)
          idx = -1
          `for (i = 0; i < this.paths.length; i++) {
            if (this.paths[i].path == sp.path) {
              idx = i;
            }
          }`
          #newps = _.reject(@paths, (p) -> p.path == sp.path)
          @paths.splice(idx, 1) # delete from array
          newidx = if upOrDown == 'up' then --idx else ++idx
          @paths.splice(newidx, 0, sp) # add item in new position
          @setBtnEnabled()
        show: -> alert 'show!'
        save: ->
          ttr.setPythonSearchPaths(@paths, @restartEngineChecked, (response) =>
            if /^ok/.test response
              @dirty = false
              @setBtnEnabled()
          )
        revert: ->
          ttr.getPythonSearchPaths((psp) =>
            @paths = psp
            @dirty = false
            @setBtnEnabled()
          )
        select: (path) ->
          #_.each(_.filter(@paths, (i) -> i.selected == true), (p) -> p.selected = false)
          for p in @paths
            if p.selected == true
              p.selected = false
          path.selected = true
          @setBtnEnabled()
        setBtnEnabled: ->
          @disableAllBtnsExceptAdd()
          if @aPathIsSelected()
            @deleteDisabled = false
            @showDisabled = false
            if @selectedIsNotFirst()
              @upDisabled = false
            if @selectedIsNotLast()
              @downDisabled = false
          if @dirty
            @saveDisabled = false
            @revertDisabled = false

        disableAllBtnsExceptAdd: ->
          @deleteDisabled = true
          @upDisabled = true
          @downDisabled = true
          @showDisabled = true
          @saveDisabled = true
          @revertDisabled = true

        aPathIsSelected: ->
          #can't access the underscore lib from here?
          #_.any(@paths, (p) -> p.selected)
          console.log 'paths:', @paths
          apis = false
          for p in @paths
            if p.selected
              apis = true
          apis

        selectedPath: ->
          #_.find(@paths, (p) -> p.selected)
          for p in @paths
            if p.selected
              sp = p
          sp

        selectedIsFirst: ->
          #@aPathIsSelected() and @selectedPath().path == _.first(@paths).path
          @aPathIsSelected() and @selectedPath().path == @paths[0].path
        selectedIsNotFirst: ->
          not @selectedIsFirst()

        selectedIsLast: ->
          #@aPathIsSelected() and @selectedPath().path == _.last(@paths).path
          @aPathIsSelected() and @selectedPath().path == @paths[@paths.length-1].path
        selectedIsNotLast: ->
          not @selectedIsLast()
      data:
        dirty: false
        deleteDisabled: true
        upDisabled: true
        downDisabled: true
        showDisabled: true
        saveDisabled: true
        revertDisabled: true
        restartEngineChecked: true
        paths: []
    })

  toggleRhinoSettingsView: ->
    #ttr.rhinoIsListening()
    console.log 'toggle:', @modalPanel
    if @modalPanel.isVisible()
      if @v.dirty
        alert "Rhino Python Search Paths: have unresolved changes.  Save or revert them before closing."
        return
      @modalPanel.hide()
    else
      if @v.dirty
        alert "Closed settings view is dirty.  This should never happen."
      ttr.rhinoIsListening()
        .done (isListening) =>
          [isListening, _] = isListening
          if isListening
            ttr.getPythonSearchPaths((psp) =>
              @v.paths = psp
              @v.dirty = false
              @v.setBtnEnabled()
              @modalPanel.show()
            )
        .fail (errorObject) ->
          alert "Rhino isn't listening for requests.  Run the \"StartAtomEditorListener\" command from within Rhino."

  deactivate: ->
    @provider = null
    @subscriptions.dispose()

  provide: ->
    unless @provider?
      RhinoProvider = require('./rhino-autocomplete-plus-python-provider')
      @provider = new RhinoProvider()
    @provider

  saveAndRunInRhino: ->
    ttr.rhinoIsListening()
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
