# rhino-python

Code completion support for your Python scripts that are executed by [Rhinoceros for Mac] (https://www.rhino3d.com/mac).

![rhino-python](https://raw.githubusercontent.com/mcneel/rhino-python/master/docs/main.gif)  

## Installation

  - Download and install the latest [Rhino 5 for Mac][2]
  - Download and install the [Atom text editor][1]
  - From the "Atom" menu select "Install Shell Commands" in case they are not already installed.
  - Press the <kbd>`cmd`</kbd> + <kbd>`,`</kbd> to launch the Settings view.
  - Click on the Install tab and then click on the "Packages" button right of the top edit box.
  - Type "rhino-python" in the "Search Packages" edit box followed by the <kbd>`Enter`</kbd> key.
  - The rhino-python package will be the 1st one in the list.  Click the "Install" button.

## Quick Start

  - From Rhino run the **```StartAtomEditorListener```** command.
  - Launch the Atom editor and save the "untitled" document as mypythonscript.py.  The file needs to have a ".py" extension for the rhino-python package to recognize it.
  - Type **```import ```** (followed by a trailing space).  Depending on how you have Atom configured and which other packages you have installed you'll see a completion window with suggestions on what to type next.  Type "rh" to start filtering the list and notice that the suggestions provided by Rhino are labeled with the "<- Rhino" hint on the right of the suggestion.
  - As you continue typing **```rhinos```** you'll see the completion data list get filtered until the only option left is "rhinoscriptsyntax".  Press the <kbd>`tab`</kbd> key (or <kbd>`enter`</kbd> if configured that way) to accept it.  Finish typing the line:  
  **```import rhinoscriptsyntax as rs```**
  - On the next line type **```from Rhino.Geometry import Point3d```**.  The completion data will pop up for **```Rhino```**, **```Geometry```**, and **```Point3d```**.  Press the <kbd>`tab`</kbd> key (or <kbd>`enter`</kbd> if configured that way) to accept each.
  - For the next line type **```rs.AddCircle(Point3d.Origin, 5.0)```** and again notice the completion window after each <kbd>`.`</kbd> and the doc string panel after the <kbd>`(`</kbd>. Keep typing until the desired data is highlighted in the completion window and press the <kbd>`tab`</kbd> (or <kbd>`enter`</kbd> if configured that way) key to accept.
  - To send the file to Rhino for execution press the <kbd>`ctrl`</kbd> + <kbd>`alt`</kbd> + <kbd>`r`</kbd> keys.

## Manage Python Search Paths (supported by version 5.2 WIP 5C41w and later)

Press the <kbd>`ctrl`</kbd> + <kbd>`alt`</kbd> + <kbd>`s`</kbd> keys to open the Rhino Python Search Paths panel.

  - When the window is first opened only the add <kbd>`+`</kbd> button is enabled.
  - After adding one or more pates click on one to select it and the other nav buttons become enabled.  This doesn't apply to the default paths (system paths) because they cannot be edited.
  - None of the changes made are saved until the save button is clicked which sends the save request to Rhino.
  - Clicking the revert button discards all changes made since the last save.

## Autocomplete Plus configuration and additional notes

Experiment with the Autocomplete Plus settings to fine tune your setup:  

  - Press the <kbd>`cmd`</kbd> + <kbd>`,`</kbd> keys to open the Settings panel.
  - Click on the Packages tab and type "autocomplete plus" in the "Filter packages by name" edit box.
  - Click on the "Settings" button of the autocomplete-plus package and experiment with the settings.

Because completion data can come from many providers if you installed other packages or if you have the "Enable Built-In Provider" checked in Autocomplete Plus settings, the data coming from rhino is labeled "`<- Rhino`" (right-most column of completion window).

## Get Involved  

  - Join discussions on our [forum](http://discourse.mcneel.com)  
  - Report Issues on our [youtrack](http://mcneel.myjetbrains.com/youtrack/dashboard) site.


  [1]: https://atom.io
  [2]: http://https://www.rhino3d.com/download/rhino-for-mac/5.0/wip
