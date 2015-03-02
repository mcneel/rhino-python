# rhino-python

Code completion support for your Python scripts that are executed by [Rhinoceros for Mac] (https://www.rhino3d.com/mac).

![rhino-python](docs/main.gif)  

## Installation

  - Download and install the latest [Rhino 5 for Mac][2]
  - Download and install the [Atom text editor][1] (tested with version 0.184.0)
  - From the "Atom" menu select "Install Shell Commands" in case they are not already installed.
  - Close Atom
  - Open a terminal window (In Finder: Applications/Utilities/Terminal.app)
  - In the terminal window type the following 2 commands:  
    **```apm install autocomplete-plus@2.3.0```**  
    **```apm install rhino-python```**

## Quick Start

  - From Rhino run the **```StartAtomEditorListener```** command.
  - Launch the Atom editor and save the "untitled" document as mypythonscript.py.  The file needs to have a ".py" extension for the rhino-python package to be activated.
  - Type **```import ```** (trailing space) and a window with completion data will pop up.
  - As you type **```rhinos```** you'll see the completion data list get filtered until the only option left is "rhinoscriptsyntax".  Press the <kbd>tab</kbd> key to accept it.  The finished line is:  
  **```import rhinoscriptsyntax as rs```**
  - On the next line type **```from Rhino.Geometry import Point3d```**.  The completion data will pop up for **```Rhino```**, **```Geometry```**, and **```Point3d```**.  Press the <kbd>tab</kbd> key to accept each.
  - For the next line type **```rs.AddCircle(Point3d.Origin, 5.0)```** and again notice the completion window after each <kbd>.</kbd> and the doc string panel after the <kbd>(</kbd>. Keep typing until the desired data is highlighted in the completion window and press the <kbd>tab</kbd> key to accept.
  - To send the file to Rhino for execution press the <kbd>ctrl</kbd>-<kbd>alt</kbd>-<kbd>r</kbd> keys.

## A useful workflow to manage your scripts

  Since rhino-python also provides the ability to launch scripts from Atom it's also easy to centrally manage your scripts.  Especially with symbolic links (described below).  You can view [a one minute screencast] (http://youtu.be/pAxssTpj4g4) or follow the steps below:

  - determine the main folder that will be the root for all your Python scripts (Ex: ~/src/py).
  - copy your Python files or directories that contain Python files to that directory.  
  - open a terminal window (Finder: Applications/Utilities/Terminal.app) and go to your root directory and launch Atom.  Launching Atom at the command line opens the current directory in a tree view panel on the left.  
  **```cd ~/src/py```**  
  **```atom```**  
  - if you have files that reside outside this main directory you can link to them with a symbolic link instead of copying them.  For example to create a link to the sample scripts that ship with Rhino type the following:  
  **```ln -s ~/Library/Application\ Support/McNeel/Rhinoceros/MacPlugIns/ironpython/settings/samples samples```**  
  - notice how the "samples" directory is now in the Atom three view and has a different folder icon to show that it links to another directory.  If you forget where the real directory is <kbd>ctrl</kbd>+<kbd>click</kbd> on the "samples" directory in Finder and select "Get Info"
  - you can <kbd>ctrl</kbd>+<kbd>click</kbd> any Python file in the tree view and select "Save and Run in Rhino" from the "RhinoPython" context menu.


  [1]: https://atom.io
  [2]: http://https://www.rhino3d.com/download/rhino-for-mac/5.0/wip
