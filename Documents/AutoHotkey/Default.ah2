; @region Autorun

#SingleInstance force
#Warn All, OutputDebug

Persistent(true)
KeyHistory(150)

OnExit(ReleaseModifiers)

SetNumLockState("AlwaysOn")
SetCapsLockState("AlwaysOff")

; Remove the "show desktop" button: https://superuser.com/a/1526926
showDesktopControl := "TrayShowDesktopButtonWClass1"
shellTray := "ahk_class Shell_TrayWnd"
while true {
    try {
        ControlHide(showDesktopControl, shellTray)
    } catch Error {
        ; Sometimes it won't exist yet at startup so just wait + try again
        Sleep(1000)
    } else {
        break
    }
}

AHK_NOTIFYICON := 0x404 ; WM_USER + 4
WM_MOUSEFIRST := 0x0200
WM_MOUSEMOVE := 0x0200
WM_LBUTTONDOWN := 0x0201
WM_LBUTTONUP := 0x0202
WM_LBUTTONDBLCLK := 0x0203
WM_RBUTTONDOWN := 0x0204
WM_RBUTTONUP := 0x0205
WM_RBUTTONDBLCLK := 0x0206
WM_MBUTTONDOWN := 0x0207
WM_MBUTTONUP := 0x0208
WM_MBUTTONDBLCLK := 0x0209
WM_MOUSEWHEEL := 0x020A
WM_MOUSEHWHEEL := 0x020E

; https://www.autohotkey.com/boards/viewtopic.php?t=9501
OnMessage(AHK_NOTIFYICON, HandleTrayMsg)
ResetMenuItems()

; Match title by contains, rather than starts-with
SetTitleMatchMode(2)

; @region Groups

; Lots of apps I don't use are omitted
GroupAdd("terminal", "ahk_exe powershell.exe")
GroupAdd("terminal", "ahk_exe WindowsTerminal.exe")
GroupAdd("terminal", "ahk_exe Cmd.exe")

GroupAdd("posix", "ahk_exe WindowsTerminal.exe")

GroupAdd("ExcPaste", "ahk_exe Cmd.exe")

GroupAdd("editor", "ahk_exe Code.exe")

GroupAdd("browser", "ahk_exe chrome.exe")
GroupAdd("browser", "ahk_exe firefox.exe")
GroupAdd("browser", "ahk_exe floorp.exe")
GroupAdd("browser", "ahk_exe msedge.exe")

GroupAdd("vscode", "ahk_exe Code.exe")

GroupAdd("vstudio", "ahk_exe devenv.exe")

GroupAdd "AltTabWindow", "ahk_class MultitaskingViewFrame"  ; Windows 10
GroupAdd "AltTabWindow", "ahk_class TaskSwitcherWnd"  ; Windows Vista, 7, 8.1
GroupAdd "AltTabWindow", "ahk_class #32771"  ; Older, or with classic alt-tab enabled
GroupAdd "AltTabWindow", "ahk_exe window-switcher.exe"  ; https://github.com/sigoden/window-switcher

AddWindowCreateHook(PinWindow)

DetectHiddenWindows(true)
pipWindow := WinExist("Picture-in-Picture")
DetectHiddenWindows(false)
if pipWindow {
    DllCall("VirtualDesktopAccessor\PinWindow", "Ptr", pipWindow)
}

; @endregion

; @endregion

; @region Bindings

; NOTE: CapsLock should not be needed with SharpKeys rebind

; NOTE: winkey shortcuts can be disabled with https://superuser.com/q/1755857/1228483

; @region Kinto-like

;; Basic remap

; NOTE: SharpKeys handles these remaps, it seems to simplify things:
;   Win->Alt
;   Alt->RCtrl (cmd key)
;   RCtrl->Win ("plain" windows key)

; Suppress menubar toggling on release; RAlt can still be used
~LAlt up::{
    Send("{Blind}{vkFF}")
    KeyWait("Alt")
}

;; word/line navigation support
; I had all these using SendBlind previously, but this seems cleaner... not sure
; why it wasn't working in the first place but seems fine now

$!BackSpace::^BackSpace
$!Delete::^Delete

; wordwise support
$!Left::^Left
$!Right::^Right

; linewise support and also scrolling I guess?
$>^Left::Home
$>^Right::End

; See below for vscode/terminal version of line deletion

;; Virtual desktops/spaces emulation

; TODO: something like MaxThreadsPerHotkey but maybe with a delay, like I could Send() then Sleep() and
; force the routine to buffer, or something??? Seems like ctrl key gets released too early, normally

$<^Left::MoveToDesktop(-1)
$<^Right::MoveToDesktop(1)

$<^Up::#Tab

; Mouse keys (used with G Hub)
F18::#Tab

; Idk this is just broken, alt is not released a lot of times and it causes many problems
; F19::{
;     Send("{Alt down}{Tab}")
;     KeyWait("F19")
;     Send("{Blind}{Alt up}")
; }

; Move windows between monitors
$<^!Left::#+Left
$<^!Right::#+Right

; Mainly used for vscode / terminal "move pane" commands (on macOS, ctrl+cmd+left)
$<^>^Left::^#!Left
$<^>^Right::^#!Right

; Mainly used for vscode / terminal "move to pane"
$>^!Left::^!Left
$>^!Right::^!Right

;; Maximize / snap

; Requires FancyZones shortcuts turned on, for now
$<^>^!Left::#Left
$<^>^!Right::#Right
$<^>^!Down::#Down
$<^>^!Up::#Up

$<^>^+Up::WinMaximize("A") ; always maximize unlike Win+Up which toggles

$^>m::WinMinimize("A")

; Media keys (ported from BTT)
$<^+Left::Media_Prev
$<^+Right::Media_Next
$<^+Space::Media_Play_Pause

; Spotify volume might be doable with
; https://gist.github.com/jcsteh/7ccbc6f7b1b7eb85c1c14ac5e0d65195
; Like Song too although I could probably also reuse like_spotify_song.py

; return
!Enter::
{
    if (GetKeyState("RAlt", "P")) {
        Send("{Insert}")
    }
    else {
        KeyWait("Alt")
        Send("{Alt down}{Enter}{Alt up}")
    }
}

; Close Apps
$>^q::Send("!{F4}")

; Spotlight emulation (PowerToys Run)
$>^Space::!Space

; Task manager (like force quit dialog)
^!Esc::^+Esc

;; AltTab fixes

; for window-switcher, to avoid e.g. terminal in vscode
$>^`::!`

; cmd+tab = alt+tab
$>^Tab::AltTabAndMenu

; Random keybind that I rarely use except Stretchly, but it opens the start menu
; so just binding to avoid any surprises from that.
>^Esc::#Esc

; Special characters + emoji picker
<^>^Space::#`;
!-::SendText("–")
!+-::SendText("—")

;; #HotIf directives
; NOTE: All shortcuts after this point take precedence over global shortcuts above

#HotIf WinExist("ahk_group AltTabWindow")
    ; Ok phew this seems to be working again, sheesh
    ~*RCtrl up::Send("{Blind}{Alt up}")

    ; Release alt if cancelled or finished
    ~*Esc::Send("{Blind}{Alt up}")
    ~*MButton::Send("{Blind}{Alt up}")
    ~*Enter::Send("{Blind}{Alt up}")
#HotIf

#HotIf GetKeyState("RCtrl")
    ; Inspired by this idea, although actually using ShiftAltTab doesn't work:
    ; https://www.autohotkey.com/boards/viewtopic.php?style=8&t=84068#p368388
    $<+Tab::+!Tab
#HotIf

; For some reason these are taking precedence over more-specific #HotIf
; so just manually disabling terminal
#HotIf not WinActive("ahk_group terminal")
    ; NOTE: vscode terminal needs to be configure to kill-line sequences for these.
    ; Windows terminal can't seem to handle it, maybe WezTerm can though??
    $>^Backspace::SendBlind("+{Home}{Backspace}")
    $>^Delete::SendBlind("+{End}{Delete}")
#HotIf

#HotIf MouseIsOverTaskbarApp()
    ; Make clicking apps in the taskbar more like macOS. Individual windows can
    ; still be selected by just hovering, then clicking. Is this the best way to
    ; deal with this? idk, but it seems to work, sometimes...

    ; A simple LButton::^LButton seemed not to work how I expected but this does:
    LButton::{
        if KeyWait("LButton", "T0.2") {
            SendBlind("^{LButton}")
        } else {
            ; handle drag without sending ctrl
            SendBlind("{LButton down}")
            KeyWait("LButton")
            SendBlind("{LButton up}")
        }
    }
#HotIf

; @endregion

; @region Per-app

;; File explorer
; TODO maybe also do some of these for ahk_class #32770 (file dialog)
#HotIf WinActive("ahk_class CabinetWClass ahk_exe explorer.exe")
    ^i::Send("!{Enter}")           ; Cmd+i: Get Info / Properties
    ^r::Send("{F5}")               ; Cmd+R: Refresh view (Not actually a Finder shortcut? But works in Linux file browsers too.)
    ^1::Send("^+2")                ; Cmd+1: View as Icons
    ^2::Send("^+6")                ; Cmd+2: View as List (Detailed)
    ^3::Send("^+5")                ; Cmd+3: View as List (Compact)
    ^4::Send("^+1")                ; Cmd+4: View as Gallery
    ^Up::Send("!{Up}")             ; Cmd+Up: Up to parent folder
    ^Left::Send("!{Left}")         ; Cmd+Left: Go to prior location in history
    ^Right::Send("!{Right}")       ; Cmd+Right: Go to next location in history
    ^Down::{
        ; Cmd-Down: Navigate into the selected directory
        for window in ComObject("Shell.Application").Windows
            if WinActive() = window.hwnd
                for item in window.document.SelectedItems {
                    window.Navigate(item.Path)
                    return
                }
    }
    ^[::Send("!{Left}")            ; Cmd+Left_Brace: Go to prior location in history
    ^]::Send("!{Right}")           ; Cmd+Right_Brace: Go to next location in history
    ^+o::Send("^{Enter}")          ; Cmd+Shift+o: Open in new window (tabs not available)
    $>^Delete::{
        if IsEditBoxActive() {
            Send("+{End}{Delete}") ; kill-line
        } else {
            Send("{Delete}")       ; Delete / Send to Trash (less common)
        }
    }
    $>^Backspace::{
        if IsEditBoxActive() {
            Send("+{Home}{Backspace}") ; backward-kill-line
        } else {
            Send("{Delete}")    ;  Delete / Send to Trash
        }
    }
    ^d::return                      ; Block the unusual Explorer "delete" shortcut of Ctrl+D, used for "bookmark" in similar apps

    ; Use Enter key to rename (F2), unless focus is inside a text input field.
    $Enter::{
        if IsEditBoxActive()
            Send("{Enter}")
        else
            Send("{F2}")
    }
    ; TODO: make these play nice with e.g. linewise delete
    ; $BackSpace::{
    ;     ; Backspace (without Cmd): Block Backspace key with error beep, unless inside text input field
    ;     fc := ControlGetClassNN(ControlGetFocus("A"))
    ;     if NOT (fc ~= "i)(Edit|Search|Notify|Windows\.UI\.Core\.CoreWindow1)")
    ;         Send("{BackSpace}")
    ;     else
    ;         Bell()
    ; }
    ; $Delete::{
    ;     ; Delete (without Cmd): Block Delete key with error beep, unless inside text input field
    ;     fc := ControlGetClassNN(ControlGetFocus("A"))
    ;     if (fc ~= "i)(Edit|Search|Notify|Windows\.UI\.Core\.CoreWindow1)")
    ;         Send("{Delete}")
    ;     else
    ;         Bell()
    ; }

    Tab::{
        ; Auto-completion - move to the next suggestion when in a text box
        fc := ControlGetClassNN(ControlGetFocus("A"))
        if (fc ~= "i)(Edit|Search)")
            Send("{Down}")
        else {
            Send("{Tab}")
        }
    }

    ; PowerToys Peek (like Quick Look)
    Space::{
        if (IsEditBoxActive()) {
            Send("{Space}")
        } else {
            Send("^{Space}")
        }
    }

#HotIf

#HotIf WinActive("ahk_exe PowerToys.Peek.UI.exe")
    Space::^Space
#HotIf

;; VSCode
#HotIf WinActive("ahk_group vscode")
    ; Send meta key instead of ctrl for commonly used shortcuts that I've already bound in macOS
    ; Most require modifier(s) to be recognized by vscode instead of intercepted by windows

    ; Basic completion/code actions
    $!Space::^Space
    $>^.::^.

    ; Reveal in sidebar
    $<^>^r::^#r

    ; find + replace
    $>^f::^#f
    $>^r::^!#r

    ; toggle regex search (needed to undo above ^r binding)
    ; although apparently alt+r by itself is enough... let's use that
    $>^!r::^!r

    ; cut, copy + paste
    $>^c::#!c
    $>^x::#!x
    $>^v::#!v

    ; select all; #a conflicts with Windows' notification center
    $>^a::#!a

    ; focus comments view (needed to undo above ^c binding)
    $>^+c::^+c

    ; set file language
    $>^l::^!l
    ; change indent size
    $>^+l::^+l

    ; Go to symbol in workspace
    $<^>^p::^!p
#HotIf

;; Terminals
#HotIf WinActive("ahk_group terminal")
    ; linewise deletion supported by readline/in-app bindings
    $>^Backspace::^+Backspace
    $>^Delete::^+Delete
#HotIf

#HotIf WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS")
    ; Windows terminal doesn't have middle-click paste yet:
    ; https://github.com/microsoft/terminal/issues/1553
    ; Unfortunately this rebind breaks middle-click to close tabs...
    ; MButton::Send("^v")
#HotIf

;; All Browsers
#HotIf WinActive("ahk_group browser")
#HotIf

;; Firefox/Floorp
#HotIf WinActive("ahk_exe firefox.exe") or WinActive("ahk_exe floorp.exe")
    ; dev tools, console, etc.
    $>^!i::^+i
    $>^!k::^+k
    $>^!c::^+c
    $>^!e::^+e
    $>^!m::^+m
#HotIf

#HotIf WinActive("ahk_exe firefox.exe")
    ; Preferences shortcut... this is ridiculous but I guess if it works?
    $>^,::{
        Send("!t") ; Tools
        Sleep(100) ; needed to wait for the menu to appear
        Send("s") ; Settings
    }
#HotIf

;; Outlook
#HotIf WinActive("ahk_exe olk.exe")
#HotIf

;; Teams
#HotIf WinActive("ahk_exe ms-teams.exe")
    ^k::^g ; goto channel or chat
    ^+a::Send("^1^!u") ; goto activity, then show all unreads
    ^/::^. ; show shortcuts
    ^+f::^e ; search all (vs ^f which is find in current channel)

    ; history navigation
    ^[::!Left
    ^]::!Right

    ; sadly there is no way to toggle sidebar like slack...
#HotIf

;; Slack
#HotIf WinActive("ahk_exe Slack.exe")
    ; History navigation
    ^[::!Left
    ^]::!Right
#HotIf

;; KeepassXC
#HotIf WinActive("ahk_exe KeePassXC.exe")
#HotIf

;; WSLg (NixOS)
#HotIf WinActive("(NixOS) ahk_exe msrdc.exe")
    ; Instead of converting to alt-f4 like usual, just programatically close the window
    ; https://github.com/microsoft/wslg/issues/187
    ; For whatever reason this manifests as a long delay before quitting instead of
    ; passing the keys to the window.
    ; Of all the methods (WinClose(), PostMessage(0x0112, 0xF060)), this seems to be the
    ; most effective, and it does still seem to allow for "app shutdown" in most cases:
    $>^q::WinKill()
#HotIf

;; Fork
#HotIf WinActive("ahk_exe Fork.exe")
    ; Refresh repo
    >^r::F5
#HotIf

; @endregion

; @endregion

; @region Helpers

AddWindowCreateHook(func) {
    WinEventProc := CallbackCreate(func, "Fast")  ; function callback

    EVENT_OBJECT_CREATE := 0x8000 ; window or control created

    DllCall("SetWinEventHook"
        , "Int", EVENT_OBJECT_CREATE    ; eventMin
        , "Int", EVENT_OBJECT_CREATE    ; eventMax
        , "Ptr", 0                      ; hmodWinEventProc
        , "Ptr", WinEventProc           ; lpfnWinEventProc
        , "UInt", 0                     ; PID, 0 receives events from all windows
        , "UInt", 0                     ; idThread
        , "UInt", 0x2                   ; dwFlags (0x2 = OutOfContext|SkipOwnProcess)
        , "Int"
    )
}

; hWinEventHook - handle to current hook
; event         - Event that occurred
; hwnd          - hwnd that triggered event
PinWindow(hWinEventHook, event, hwnd) {
    DetectHiddenWindows(true)
    ; Title can take time to set, wait before determining this window doesn't match. Even if we don't
    ; pin until a little later, it should still work and start appearing on all desktops
    if WinWait("Picture-in-Picture ahk_id " hwnd, , 2) {
        ; Wow, lucky find: https://github.com/Ciantic/VirtualDesktopAccessor
        DllCall("VirtualDesktopAccessor\PinWindow", "Ptr", hwnd)
    }
    DetectHiddenWindows(false)
}

MoveToDesktop(relativeIndex) {
    DetectHiddenWindows(true)

    ; TODO: a bunch of these DllCalls coul dbe made into LoadLibrary + GetProcAddress
    ; which is probably faster, but for now this seems fine I guess
    total := DllCall("VirtualDesktopAccessor\GetDesktopCount")
    current := DllCall("VirtualDesktopAccessor\GetCurrentDesktopNumber")
    next := current + relativeIndex
    if next >= 0 && next < total {
        ; https://github.com/Ciantic/VirtualDesktopAccessor/blob/rust/example.ah2
        if (GetKeyState("LButton")) {
            activeWin := WinGetID("A")
            DllCall(
                "VirtualDesktopAccessor\MoveWindowToDesktopNumber",
                "Ptr", activeWin,
                "Int", next,
                "Int"
            )
        }

        ; TODO: possibly can get animations back using something like
        ; https://github.com/Grabacr07/VirtualDesktop/pull/23#issuecomment-334918711
        ; or just finding a window on the other desktop idk
        ; https://github.com/FuPeiJiang/VD.ahk/blob/v2_port/VD.ah2#L400-L410
        /*
        g := Gui.Call()
        g.Show()
        WinActivate(g.Hwnd)
        Sleep(200)
        DllCall(
            "VirtualDesktopAccessor\MoveWindowToDesktopNumber",
            "Ptr", g.Hwnd,
            "Int", next,
            "Int"
        )
        Sleep(200)
        WinActivate(g.Hwnd)
        
        Sleep(100)
        g.Destroy()
        ;*/

        result := DllCall(
            "VirtualDesktopAccessor\GoToDesktopNumber",
            "Int", next,
            "Int"
        )
    }

    DetectHiddenWindows(false)
}

Exit() {
    ReleaseModifiers()
    ExitApp()
}

ReloadScript() {
    ReleaseModifiers()
    Sleep(100)
    Reload()
    ; See help for reload
    Sleep(1000)
    ; MsgBox,,, The script could not be reloaded.
    return
}

ReleaseModifiers(args*) {
    for Each, Modifier in [
        "LShift",
        "RShift",
        "LControl",
        "RControl",
        "LWin",
        "RWin",
        "LAlt",
        "RAlt",
    ]
        if GetKeyState(Modifier) And !GetKeyState(Modifier, "P")
            Send("{" Modifier " Up}")
}

/**
 * @description Sends a key sequence with {Blind!#^+} to suppress all modifiers
 * but retain other Blind functionality e.g. held modifiers
 */
SendBlind(keys) {
    Send("{Blind!#^+}" . keys)
}

Bell() {
    SoundPlay(A_WinDir "\Media\Windows Ding.wav")
}

MouseIsOverTaskbarApp() {
    ListLines(false)
    winID := -1
    hoveredControl := ""
    try {
        MouseGetPos(, , &winID, &hoveredControl)
    } catch {
        ; this randomly happens sometimes idk, maybe a bug
        return false
    }

    exists := WinExist(shellTray . " ahk_id " . winID)
    ; I guess Win10 uses the former while Win11 and/or TaskbarX use the latter
    matches := hoveredControl == "MSTaskListWClass1" OR hoveredControl == "MSTaskSwWClass1"
    ListLines(true)
    return exists and matches
}

HandleTrayMsg(wParam, lParam, msg, hwnd) {
    ListLines(false)
    if (lParam == WM_RBUTTONUP) {
        ResetMenuItems()
        if (GetKeyState("Shift", "P")) {
            A_TrayMenu.Add()
            A_TrayMenu.AddStandard()
            A_TrayMenu.Delete("E&xit") ; remove the builtin exit in favor of custom
        }
        ; We don't need to Show() the menu here, since that's the default action
        ; Unclear if there's a way to suppress that but this works for now
    }
    ListLines(true)
}

ResetMenuItems() {
    A_TrayMenu.Delete()

    A_TrayMenu.Add("Reload", (args*) => ReloadScript())
    A_TrayMenu.Add("History", (args*) => KeyHistory())
    A_TrayMenu.Add("Exit", (args*) => Exit())

    A_TrayMenu.Default := "Reload"
}

IsControlKindActive(className) {
    FocusedHwnd := ControlGetFocus("A")
    try {
        return className == WinGetClass(FocusedHwnd)
    } catch Error {
        return false
    }
}

IsEditBoxActive() {
    fc := ControlGetClassNN(ControlGetFocus("A"))
    return (fc ~= "i)(Edit|Search|Notify|Windows\.UI\.Core\.CoreWindow1|SysTreeView321)")
}

; @endregion
