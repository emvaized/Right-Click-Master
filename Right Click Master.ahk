;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-SetVersion 1.0.0.0
;@Ahk2Exe-SetProductName Right Click Master
;@Ahk2Exe-SetProductVersion 1.0.0.0
;@Ahk2Exe-SetDescription Right Click Master
;@Ahk2Exe-SetCopyright emvaized
; License: MIT License

SetWorkingDir %A_ScriptDir%
#SingleInstance, Force
#Persistent
SendMode Input
CoordMode, Mouse, Screen
SetBatchLines, -1
SetDefaultMouseSpeed, 0
SetMouseDelay, -1
ListLines Off

IniDir := A_AppData "\RightClickMaster"
IniFile := IniDir "\settings.ini"
RBDown := false
LastWheelUpTime := 0
LastWheelDownTime := 0
ServiceEnabled := true
DisableInFullscreen := true
EnableRClickLBtn := false
EnableRClickMBtn := false
EnableRClickWheelUp := false
EnableRClickWheelDown := false
AutostartEnabled := false
RClickLBtnAction := "^r"
RClickMBtnAction := "^v"
RClickWheelUpAction := "^{Home}"
RClickWheelDownAction := "^{End}"
ExcludedExeText := ""
SettingsGuiCreated := false

CreateTrayMenu()
LoadSettings()

#If !ShouldBypassCustomBehavior()
$RButton::
{
    if (A_TimeSincePriorHotkey < 250 && A_PriorHotkey == "$RButton")
        return

    MouseGetPos, MouseXPos, MouseYPos, winUnderMouse
    WinGet, activeWin, ID, A
    if (winUnderMouse && winUnderMouse != activeWin)
    {
        ; Activate window under mouse (mimic default Windows behavior)
        WinActivate, ahk_id %winUnderMouse%
        Sleep, 10
    }

    ; SendMessage, 0x84, 0, (MouseXPos&0xFFFF) | ((MouseYPos&0xFFFF)<<16),, ahk_id %winUnderMouse%
    ; if (ErrorLevel = 2 || ErrorLevel = 8 || ErrorLevel = 9 || ErrorLevel = 20) {
    ;     ; right click on the titlebar (draft)
    ; }

    Click, Right
    RBDown := true
    return
}

$RButton Up::
{
    if (!RBDown)
        return

    MouseGetPos, MouseNewXPos, MouseNewYPos
    if (Abs(MouseNewXPos - MouseXPos) > 8 || Abs(MouseNewYPos - MouseYPos) > 8)
        Click

    RBDown := false
    return
}
#If

#If GetKeyState("RButton", "P") && !ShouldBypassCustomBehavior()
$LButton::
{
    if (EnableRClickLBtn && RClickLBtnAction != "")
    {
        Send, {Esc}
        SendInput, %RClickLBtnAction%
        return
    }
    Send {Blind}{LButton}
    return
}

$MButton::
{
    if (EnableRClickMBtn && RClickMBtnAction != "")
    {
        Send, {Esc}
        SendInput, %RClickMBtnAction%
        return
    }
    Send {Blind}{MButton}
    return
}

$WheelUp::
{
    global LastWheelUpTime
    currentTime := A_TickCount
    if (currentTime - LastWheelUpTime < 50)
        return
    LastWheelUpTime := currentTime

    if (EnableRClickWheelUp && RClickWheelUpAction != "")
    {
        Send, {Esc}
        SendInput, %RClickWheelUpAction%
        return
    }
    Send {Blind}{WheelUp}
    return
}

$WheelDown::
{
    global LastWheelDownTime
    currentTime := A_TickCount
    if (currentTime - LastWheelDownTime < 50)
        return
    LastWheelDownTime := currentTime

    if (EnableRClickWheelDown && RClickWheelDownAction != "")
    {
        Send, {Esc}
        SendInput, %RClickWheelDownAction%
        return
    }
    Send {Blind}{WheelDown}
    return
}
#If

ShowSettings:
    CreateSettingsGui()
    Gui, Settings: Show, 
    return

SaveSettings:
    Gui, Settings: Submit, NoHide
    ExcludedExeText := RegExReplace(ExcludedExeText, "(\r\n|\r)", "`n")
    ServiceEnabled := ServiceEnabled ? true : false
    DisableInFullscreen := DisableInFullscreen ? true : false
    EnableRClickLBtn := EnableRClickLBtn ? true : false
    EnableRClickMBtn := EnableRClickMBtn ? true : false
    EnableRClickWheelUp := EnableRClickWheelUp ? true : false
    EnableRClickWheelDown := EnableRClickWheelDown ? true : false
    if (RClickLBtnAction = "")
        RClickLBtnAction := "^r"
    if (RClickMBtnAction = "")
        RClickMBtnAction := "^v"
    if (RClickWheelUpAction = "")
        RClickWheelUpAction := "^{Home}"
    if (RClickWheelDownAction = "")
        RClickWheelDownAction := "^{End}"
    IniWrite, % ServiceEnabled ? 1 : 0, %IniFile%, Settings, ServiceEnabled
    IniWrite, % DisableInFullscreen ? 1 : 0, %IniFile%, Settings, DisableInFullscreen
    IniWrite, % EnableRClickLBtn ? 1 : 0, %IniFile%, Settings, EnableRClickLBtn
    IniWrite, % EnableRClickMBtn ? 1 : 0, %IniFile%, Settings, EnableRClickMBtn
    IniWrite, % EnableRClickWheelUp ? 1 : 0, %IniFile%, Settings, EnableRClickWheelUp
    IniWrite, % EnableRClickWheelDown ? 1 : 0, %IniFile%, Settings, EnableRClickWheelDown
    IniWrite, %RClickLBtnAction%, %IniFile%, Settings, RClickLBtnAction
    IniWrite, %RClickMBtnAction%, %IniFile%, Settings, RClickMBtnAction
    IniWrite, %RClickWheelUpAction%, %IniFile%, Settings, RClickWheelUpAction
    IniWrite, %RClickWheelDownAction%, %IniFile%, Settings, RClickWheelDownAction
    IniWrite, %ExcludedExeText%, %IniFile%, Settings, ExcludedExeList
    IniWrite, % AutostartEnabled ? 1 : 0, %IniFile%, Settings, AutostartEnabled
    if (AutostartEnabled)
        EnableAutostart()
    else
        DisableAutostart()
    Menu, Tray, % ServiceEnabled ? "Check" : "Uncheck", Service is running
    ; Gui, Settings: Hide
    MsgBox, 64, Settings Saved, Settings were saved successfully.
    return

CancelSettings:
    ; Gui, Settings: Hide
    Gui, Settings: Destroy
    SettingsGuiCreated := false
    return

GuiClose:
GuiEscape:
    ; Gui, Settings: Hide
    Gui, Settings: Destroy
    SettingsGuiCreated := false
    return

ReloadScript:
    Reload
    return

ExitScript:
    ExitApp
    return

LoadSettings()
{
    global IniDir, IniFile, ServiceEnabled, DisableInFullscreen, EnableRClickLBtn, EnableRClickMBtn, EnableRClickWheelUp, EnableRClickWheelDown, RClickLBtnAction, RClickMBtnAction, RClickWheelUpAction, RClickWheelDownAction, ExcludedExeText, AutostartEnabled

    if !FileExist(IniDir)
        FileCreateDir, %IniDir%

    if !FileExist(IniFile)
    {
        IniWrite, 1, %IniFile%, Settings, ServiceEnabled
        IniWrite, 1, %IniFile%, Settings, DisableInFullscreen
        IniWrite, 0, %IniFile%, Settings, EnableRClickLBtn
        IniWrite, 0, %IniFile%, Settings, EnableRClickMBtn
        IniWrite, 0, %IniFile%, Settings, EnableRClickWheelUp
        IniWrite, 0, %IniFile%, Settings, EnableRClickWheelDown
        IniWrite, ^r, %IniFile%, Settings, RClickLBtnAction
        IniWrite, ^v, %IniFile%, Settings, RClickMBtnAction
        IniWrite, ^{Home}, %IniFile%, Settings, RClickWheelUpAction
        IniWrite, ^{End}, %IniFile%, Settings, RClickWheelDownAction
        IniWrite, "", %IniFile%, Settings, ExcludedExeList
    }

    IniRead, rawValue, %IniFile%, Settings, ServiceEnabled, 1
    ServiceEnabled := (rawValue = "0") ? false : true
    IniRead, rawValue, %IniFile%, Settings, DisableInFullscreen, 1
    DisableInFullscreen := (rawValue = "0") ? false : true
    IniRead, rawValue, %IniFile%, Settings, EnableRClickLBtn, 0
    EnableRClickLBtn := (rawValue = "1") ? true : false
    IniRead, rawValue, %IniFile%, Settings, EnableRClickMBtn, 0
    EnableRClickMBtn := (rawValue = "1") ? true : false
    IniRead, rawValue, %IniFile%, Settings, EnableRClickWheelUp, 0
    EnableRClickWheelUp := (rawValue = "1") ? true : false
    IniRead, rawValue, %IniFile%, Settings, EnableRClickWheelDown, 0
    EnableRClickWheelDown := (rawValue = "1") ? true : false
    IniRead, RClickLBtnAction, %IniFile%, Settings, RClickLBtnAction, {Esc}
    IniRead, RClickMBtnAction, %IniFile%, Settings, RClickMBtnAction, ^v
    IniRead, RClickWheelUpAction, %IniFile%, Settings, RClickWheelUpAction, ^{Home}
    IniRead, RClickWheelDownAction, %IniFile%, Settings, RClickWheelDownAction, ^{End}

    IniRead, ExcludedExeText, %IniFile%, Settings, ExcludedExeList,
    if (ErrorLevel)
        ExcludedExeText := ""

    StringReplace, ExcludedExeText, ExcludedExeText, `r`n, `n, All
    StringReplace, ExcludedExeText, ExcludedExeText, `r, `n, All
    Menu, Tray, % ServiceEnabled ? "Check" : "Uncheck", Service is running
    IniRead, rawValue, %IniFile%, Settings, AutostartEnabled, 0
    AutostartEnabled := (rawValue = "1") ? true : false
    if (AutostartEnabled)
        EnableAutostart()
    Menu, Tray, % AutostartEnabled ? "Check" : "Uncheck", Autostart on log in
}

CreateSettingsGui()
{
    global SettingsGuiCreated, ServiceEnabled, AutostartEnabled, DisableInFullscreen, EnableRClickLBtn, EnableRClickMBtn, EnableRClickWheelUp, EnableRClickWheelDown, RClickLBtnAction, RClickMBtnAction, RClickWheelUpAction, RClickWheelDownAction, ExcludedExeText
    if (SettingsGuiCreated)
        return

    Gui, Settings: New, +Resize, Settings - Right Click Master
    Gui, Settings: Margin, 10, 10
    Gui, Settings: Font, s10, Segoe UI

    ; --- General Settings ---
    Gui, Settings:Add, GroupBox, x10 y10 w420 h80, General settings
    Gui, Settings:Add, Checkbox, vServiceEnabled x20 y35, Service is running
    Gui, Settings:Add, Checkbox, vDisableInFullscreen x20 y60, Disable in fullscreen apps
    Gui, Settings:Add, Checkbox, vAutostartEnabled x250 y35, Autostart on log in

    ; --- Custom Actions ---
    Gui, Settings:Add, GroupBox, x10 y100 w420 h280, Additional actions while right-clicking
    Gui, Settings:Add, Text, x20 y120 cGray, Use AHK Send syntax, e.g. ^v, {Esc}, {LWin}+{F4}
    Gui, Settings:Add, Text, x345 y120 cBlue gOpenSendHelp, Learn more
    Gui, Settings:Add, Checkbox, vEnableRClickLBtn x20 y150, Left button
    Gui, Settings:Add, Edit, vRClickLBtnAction x20 y175 w400, %RClickLBtnAction%
    Gui, Settings:Add, Checkbox, vEnableRClickMBtn x20 y205, Middle button
    Gui, Settings:Add, Edit, vRClickMBtnAction x20 y230 w400, %RClickMBtnAction%
    Gui, Settings:Add, Checkbox, vEnableRClickWheelUp x20 y260, Wheel up
    Gui, Settings:Add, Edit, vRClickWheelUpAction x20 y285 w400, %RClickWheelUpAction%
    Gui, Settings:Add, Checkbox, vEnableRClickWheelDown x20 y315, Wheel down
    Gui, Settings:Add, Edit, vRClickWheelDownAction x20 y340 w400, %RClickWheelDownAction%

    ; --- Excluded Programs ---
    Gui, Settings:Add, GroupBox, x10 y390 w420 h155, Excluded programs
    Gui, Settings:Add, Text, x20 y410 cGray, List of excluded .exe (one per line):
    Gui, Settings:Add, Edit, vExcludedExeText x20 y435 w400 h100 +Wrap +WantReturn

    ; --- Footer Buttons ---
    Gui, Settings:Add, Button, gSaveSettings Default x10 y555 w100, Save settings
    Gui, Settings:Add, Button, gCancelSettings x120 y555 w100, Close

    GuiControl,, ServiceEnabled, % ServiceEnabled ? 1 : 0
    GuiControl,, DisableInFullscreen, % DisableInFullscreen ? 1 : 0
    GuiControl,, EnableRClickLBtn, % EnableRClickLBtn ? 1 : 0
    GuiControl,, EnableRClickMBtn, % EnableRClickMBtn ? 1 : 0
    GuiControl,, EnableRClickWheelUp, % EnableRClickWheelUp ? 1 : 0
    GuiControl,, EnableRClickWheelDown, % EnableRClickWheelDown ? 1 : 0
    GuiControl,, RClickLBtnAction, %RClickLBtnAction%
    GuiControl,, RClickMBtnAction, %RClickMBtnAction%
    GuiControl,, RClickWheelUpAction, %RClickWheelUpAction%
    GuiControl,, RClickWheelDownAction, %RClickWheelDownAction%
    GuiControl,, ExcludedExeText, %ExcludedExeText%
    GuiControl,, AutostartEnabled, % AutostartEnabled ? 1 : 0
    Gui, Settings: Hide

    SettingsGuiCreated := true
}

CreateTrayMenu()
{
    Menu, Tray, NoStandard
    Menu, Tray, Add, Service is running, ToggleService
    Menu, Tray, Add, Autostart on log in, ToggleAutostart
    if (!A_IsCompiled) {
        Menu, Tray, Add, Reload script, ReloadScript
    }
    Menu, Tray, Add, Settings, ShowSettings
    Menu, Tray, Add
    Menu, Tray, Add, Exit, ExitScript
    Menu, Tray, Tip, Right Click Master
    ; Menu, Tray, Icon, shell32.dll, 44
    ; Menu, Tray, Icon, imageres.dll, 283
    ; Menu, Tray, Icon, ddores.dll, 32
    if (A_IsCompiled) {
        Menu, Tray, Icon, %A_ScriptFullPath%, 1
    } else if (FileExist("icon.ico")) {
        Menu, Tray, Icon, icon.ico
    } else {
        Menu, Tray, Icon, ddores.dll, 32
    }
    Menu, Tray, % ServiceEnabled ? "Check" : "Uncheck", Service is running
    Menu, Tray, % AutostartEnabled ? "Check" : "Uncheck", Autostart on log in

    Menu, Tray, Click, 1
    Menu, Tray, Default, Settings
}

ToggleService:
    ServiceEnabled := !ServiceEnabled
    IniWrite, % ServiceEnabled ? 1 : 0, %IniFile%, Settings, ServiceEnabled
    Menu, Tray, % ServiceEnabled ? "Check" : "Uncheck", Service is running
    if (SettingsGuiCreated)
        GuiControl,, ServiceEnabled, % ServiceEnabled ? 1 : 0
    return

ToggleAutostart:
    AutostartEnabled := !AutostartEnabled
    IniWrite, % AutostartEnabled ? 1 : 0, %IniFile%, Settings, AutostartEnabled
    if (AutostartEnabled)
        EnableAutostart()
    else
        DisableAutostart()
    Menu, Tray, % AutostartEnabled ? "Check" : "Uncheck", Autostart on log in
    if (SettingsGuiCreated)
        GuiControl,, AutostartEnabled, % AutostartEnabled ? 1 : 0
    return

EnableAutostart()
{
    ; path := "\"" . A_ScriptFullPath . "\""
    RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, Right Click Master, "%A_ScriptFullPath%"
}

DisableAutostart()
{
    RegDelete, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, Right Click Master
}

ShouldBypassCustomBehavior()
{
    global ServiceEnabled, DisableInFullscreen
    if (!ServiceEnabled)
        return true
    if (IsExcludedProcess())
        return true
    if (DisableInFullscreen && IsFullscreenActive())
        return true
    return false
}

IsFullscreenActive()
{
    WinGet, winID, ID, A
    if (!winID)
        return false

    ; Exclude explorer
    WinGet, process, ProcessName, A
    if (process = "Explorer.EXE")
        return false

    WinGetPos, , , W, H, ahk_id %winID%
    if (W < A_ScreenWidth || H < A_ScreenHeight)
        return false

    WinGet, style, Style, ahk_id %winID%
    if (style & 0x20000000)
        return false
    if (style & 0x800000)
        return false

    return true
}

IsExcludedProcess()
{
    global ExcludedExeText
    if (ExcludedExeText = "")
        return false

    ; Prefer the window under the mouse pointer (handles elevated-focused windows)
    MouseGetPos, , , winUnderMouse
    if (winUnderMouse)
        WinGet, exeName, ProcessName, ahk_id %winUnderMouse%
    else
        WinGet, exeName, ProcessName, A

    if (exeName = "")
        return false

    StringLower, currentExe, exeName

    Loop, Parse, ExcludedExeText, `n
    {
        excluded := Trim(A_LoopField)
        if (excluded = "")
            continue

        StringLower, excludedLower, excluded
        if (SubStr(excludedLower, 1, 4) == ".exe")
            excludedLower := SubStr(excludedLower, 5)

        if (currentExe == excludedLower || currentExe == excludedLower . ".exe")
            return true
    }

    return false
}

OpenSendHelp:
    Run, https://www.autohotkey.com/docs/v1/lib/Send.htm#keynames
return