# <img src="./icon.ico" height=27px> Right Click Master
Implements context menu logic from Linux and MacOS in Windows. When you push right mouse button down, context menu opens immediately, allowing you to move mouse cursor over any item, and then select it by releasing the mouse button. It is super lightweight and runs on Autohotkey under the hood. 

In addition, it provides few useful shortcuts while you're holding right mouse button: 
- Left click (_default_: Reload <kbd>Ctrl</kbd>+<kbd>R</kbd>)
- Middle click (_default_: Paste <kbd>Ctrl</kbd>+<kbd>V</kbd>)
- Scroll up (_default_: Scroll to start <kbd>Ctrl</kbd>+<kbd>Home</kbd>)
- Scroll down (_default_: Scroll to end <kbd>Ctrl</kbd>+<kbd>End</kbd>)

### Compatibility
It works in all Windows apps and system-wide.

To prevent unwanted activation in games, Right Click Master provides few options: 

- Disable in fullscreen apps (_enabled_ by default) 
- Excluded processes list, where you can additionally add your games (in case first option doesn't detect your game)

### Settings
Settings `.ini` file is stored under `%AppData%\RightClickMaster`.

### Building
You can compile `.exe` file by using Ahk2Exe utility, which comes along with Autohotkey. Also, you can use utility as Autohotkey script as well, no need to compile it. 

## Support project
If you enjoy this project, please consider supporting its further development by making a small donation using one of the options below. 

<a href="https://ko-fi.com/emvaized"><img src="https://storage.ko-fi.com/cdn/kofi5.png?v=6" alt="Support on Ko-fi" height="40"></a> &nbsp; <a href="https://www.patreon.com/emvaized/membership"><img src="https://github.com/emvaized/emvaized.github.io/blob/main/donate/assets/patreon-donate-button.png?raw=true" alt="Patreon" height="40" /></a> &nbsp; <a href="https://liberapay.com/emvaized/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg" height="40"></a> &nbsp; <a href="https://emvaized.github.io/donate/bitcoin/"><img src="https://github.com/emvaized/emvaized.github.io/blob/main/donate/bitcoin/assets/bitcoin-donate-button.png?raw=true" alt="Donate Bitcoin" height="40" /></a>