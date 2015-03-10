{WorkspaceView} = require 'atom'
RhinoProvider = require '../lib/rhino-autocomplete-plus-python-provider'

describe "RhinoProvider", ->
  describe "when a string is passed to provider.getCallRhinoPosition", ->
    it "means that a position is returned if there is one otherwise null is returned", ->
      provider = new RhinoProvider()
      expect((provider.getCallRhinoPosition "import Rhi", 0)?.column).toBe(6)
      expect(provider.getCallRhinoPosition "importRhi", 0).toBe(null)
      expect((provider.getCallRhinoPosition "import Rhino.Geo", 0)?.column).toBe(12)
      expect((provider.getCallRhinoPosition "import Rhino.", 0)?.column).toBe(12)
      expect((provider.getCallRhinoPosition "import ", 0)?.column).toBe(6)
      expect(provider.getCallRhinoPosition "impor", 0).toBe(null)
      #ignore problems with double dots.  Rhino will sort it out
      expect((provider.getCallRhinoPosition "import Rhino..", 0)?.column).toBe(13)
