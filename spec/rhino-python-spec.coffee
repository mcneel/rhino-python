{WorkspaceView} = require 'atom'
RhinoPython = require '../lib/rhino-python'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RhinoPython", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('rhino-python')

  # describe "when the rhino-python:toggle event is triggered", ->
  #   it "attaches and then detaches the view", ->
  #     expect(atom.workspaceView.find('.rhino-python')).not.toExist()
  #
  #     # This is an activation event, triggering it will cause the package to be
  #     # activated.
  #     atom.commands.dispatch atom.workspaceView.element, 'rhino-python:toggle'
  #
  #     waitsForPromise ->
  #       activationPromise
  #
  #     runs ->
  #       expect(atom.workspaceView.find('.rhino-python')).toExist()
