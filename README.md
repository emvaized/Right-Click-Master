# <img src="./icon.ico" height=25px> Right Click Master
Implements context menu logic from Linux and MacOS in Windows. When you push right mouse button down, context menu opens immediately, allowing you to move mouse cursor over any item, and then select it by releasing the mouse button. It is super lightweight and runs on Autohotkey under the hood. 

In addition, it provides few useful shortcuts while you're holding right mouse button: 
- Left click (default: _Reload_ <kbd>Ctrl</kbd>+<kbd>R</kbd>)
- Middle click (default: _Paste_ <kbd>Ctrl</kbd>+<kbd>V</kbd>)
- Scroll up (default: _Scroll to start_ <kbd>Ctrl</kbd>+<kbd>Home</kbd>)
- Scroll down (default: _Scroll to end_ <kbd>Ctrl</kbd>+<kbd>End</kbd>)

### Compatibility
It works in all Windows apps and system-wide.

To prevent unwanted activation in games, Right Click Master provides few options: 

- Disable in fullscreen apps (_enabled_ by default) 
- Excluded processes list, where you can additionally add your games (in case first option doesn't detect your game)

### Settings
Settings `.ini` file is stored under `%AppData%\RightClickMaster`.

### Building
You can compile `.exe` file by using Ahk2Exe utility, which comes along with Autohotkey. Also, you can use utility as Autohotkey script as well, no need to compile it. 