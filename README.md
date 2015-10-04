# rhino-python

Code completion support for your Python scripts that are executed by [Rhinoceros for Mac] (https://www.rhino3d.com/mac).

![rhino-python](https://raw.githubusercontent.com/mcneel/rhino-python/master/docs/main.gif)  

## Installation

  - Download and install the latest [Rhino 5 for Mac][2]
  - Download and install the [Atom text editor][1] (tested with version 0.186.0)
  - From the "Atom" menu select "Install Shell Commands" in case they are not already installed.
  - Close Atom
  - Open a terminal window (In Finder: Applications/Utilities/Terminal.app)
  - In the terminal window type the following 2 commands:  
    **```apm install autocomplete-plus@2.3.0```**  
    **```apm install rhino-python```**
  - Relaunch Atom and disable the "Autocomplete Brackets" setting in the bracket-matcher package
    - press the <kbd>`cmd`</kbd> + <kbd>`,`</kbd> keys to open the Settings panel.
    - click on the Packages tab and type "bracket" in the "Filter packages by name" edit box.
    - click on the "Settings" button of the bracket-matcher package and uncheck "Autocomplete Brackets"
    - NOTE: if you prefer not to disable "Autocomplete Brackets" the doc string panel will not automatically appear when you type a "(" after a function.  In this case you'll have to manually open it with <kbd>`ctrl`</kbd> + <kbd>`shift`</kbd> + <kbd>`space`</kbd>.

## Quick Start

  - From Rhino run the **```StartAtomEditorListener```** command.
  - Launch the Atom editor and save the "untitled" document as mypythonscript.py.  The file needs to have a ".py" extension for the rhino-python package to be activated.
  - Type **```import ```** (with a trailing space).  To open the completion window type the first letter of the module you wish to import or press the <kbd>`ctrl`</kbd> + <kbd>`shift`</kbd> + <kbd>`space`</kbd> keys to see all options.
  - As you type **```rhinos```** you'll see the completion data list get filtered until the only option left is "rhinoscriptsyntax".  Press the <kbd>`tab`</kbd> key (or <kbd>`enter`</kbd> if configured that way) to accept it.  The finished line is:  
  **```import rhinoscriptsyntax as rs```**
  - On the next line type **```from Rhino.Geometry import Point3d```**.  The completion data will pop up for **```Rhino```**, **```Geometry```**, and **```Point3d```**.  Press the <kbd>`tab`</kbd> key (or <kbd>`enter`</kbd> if configured that way) to accept each.
  - For the next line type **```rs.AddCircle(Point3d.Origin, 5.0)```** and again notice the completion window after each <kbd>`.`</kbd> and the doc string panel after the <kbd>`(`</kbd>. Keep typing until the desired data is highlighted in the completion window and press the <kbd>`tab`</kbd> (or <kbd>`enter`</kbd> if configured that way) key to accept.
  - To send the file to Rhino for execution press the <kbd>`ctrl`</kbd> + <kbd>`alt`</kbd> + <kbd>`r`</kbd> keys.

## A useful workflow to manage your scripts

Since rhino-python also provides the ability to launch scripts from Atom it also makes it easy to centrally manage your scripts.  Especially with symbolic links (described below).  You can view [a one minute screencast] (http://youtu.be/pAxssTpj4g4) or follow the steps below:

  - Determine the main folder that will be the root for all your Python scripts (Ex: ~/src/py).
  - Copy your Python files or directories that contain Python files to that directory.  
  - Open a terminal window (Finder: Applications/Utilities/Terminal.app) and go to your root directory and launch Atom.  Launching Atom at the command line opens the current directory in a tree view panel on the left.  
  **```cd ~/src/py```**  
  **```atom```**  
  - If you have files that reside outside this main directory you can link to them with a symbolic link instead of copying them.  For example to create a link to the sample scripts that ship with Rhino type the following:  
  **```ln -s ~/Library/Application\ Support/McNeel/Rhinoceros/MacPlugIns/ironpython/settings/samples samples```**  
  - Notice how the "samples" directory is now in the Atom three view and has a different folder icon to show that it links to another directory.  If you forget where the real directory is <kbd>`ctrl`</kbd> + <kbd>`click`</kbd> on the "samples" directory in Finder and select "Get Info"
  - You can <kbd>`ctrl`</kbd> + <kbd>`click`</kbd> any Python file in the tree view and select "Save and Run in Rhino" from the "RhinoPython" context menu.

## Autocomplete Plus configuration and additional notes

Experiment with the Autocomplete Plus settings to fine tune your setup:  

  - Press the <kbd>`cmd`</kbd> + <kbd>`,`</kbd> keys to open the Settings panel.
  - Click on the Packages tab and type "autocomplete plus" in the "Filter packages by name" edit box.
  - Click on the "Settings" button of the autocomplete-plus package and experiment with the settings.

Because completion data can come from many providers, the data coming from rhino is labeled "`<- Rhino`" (right-most column of completion window).  This adds clarity especially if you have the "Enable Built-In Provider" checked in Autocomplete Plus settings.  

In this release getting completion data after "import ", "from ", or "from x import " doesn't work exactly
the same way as in the embedded editor that's in Rhino for Windows where the completion window opens right after you type the trailing space as in "import ".  In Atom you need to press the first letter of the module you want to import before the completion window opens (ex: "import r").  This is how many other editors work (Visual Studio with Resharper, PyCharm) and it's how the latest release Atom works for now.  This might change in the future and when it does then the completion window will open just like in Rhino for Windows.

## Get Involved  

  - Join discussions on our [forum](http://discourse.mcneel.com)  
  - Report Issues on our [youtrack](http://mcneel.myjetbrains.com/youtrack/dashboard) site.


  [1]: https://atom.io
  [2]: http://https://www.rhino3d.com/download/rhino-for-mac/5.0/wip
