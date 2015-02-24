{WorkspaceView} = require 'atom'
RhinoProvider = require '../lib/rhino-autocomplete-plus-python-provider'

describe "RhinoProvider", ->

  describe "when character directly left of cursor is a '.', ' ', or '('", ->
    it "means that Rhino should be called to provide completion data", ->
      # ask Rhino based on the simple rule described above.  In this case it means
      # that "rs.AddCircle " or "Rhino " would call Rhino which obviously won't return any
      # data but keeping as much of the logic on the Rhino side is one of the goals.  If
      # performance becomes a problem then we can filter here for "import ", or "from "
      provider = new RhinoProvider()
      lines = [
        "import rhinoscriptsyntax as rs"
      ]
      expect(provider.rhinoNeedsToBeQueriedForCompletionData lines, "rs.").toBe(true)
      expect(provider.rhinoNeedsToBeQueriedForCompletionData lines, "rs.AddCir").toBe(false)
      expect(provider.rhinoNeedsToBeQueriedForCompletionData lines, "rs.AddCircle(").toBe(true)
      expect(provider.rhinoNeedsToBeQueriedForCompletionData lines, "import ").toBe(true)
      expect(provider.rhinoNeedsToBeQueriedForCompletionData lines, "import Rhi").toBe(false)
      expect(provider.rhinoNeedsToBeQueriedForCompletionData lines, "rs.AddCircle ").toBe(true)
      expect(provider.rhinoNeedsToBeQueriedForCompletionData lines, "Rhino ").toBe(true)

  describe "when calling lastWordDirectlyInFrontOfCursorIsPrecededBySpaceOrDot", ->
    it "returns true if a word is immediately to the left of cursor and it is preceded by space or dot", ->
      provider = new RhinoProvider()
      expect(provider.endsWithWordThatIsPrecededBySpaceOrDot "e.au").toBe(true)
      expect(provider.endsWithWordThatIsPrecededBySpaceOrDot "e au_ok").toBe(true)
      expect(provider.endsWithWordThatIsPrecededBySpaceOrDot "e(au").toBe(false)
      expect(provider.endsWithWordThatIsPrecededBySpaceOrDot "e.au.").toBe(false)
      expect(provider.endsWithWordThatIsPrecededBySpaceOrDot "e.au(").toBe(false)
      expect(provider.endsWithWordThatIsPrecededBySpaceOrDot "e.au@").toBe(false)
