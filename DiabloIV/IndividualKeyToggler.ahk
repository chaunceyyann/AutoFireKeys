#Requires AutoHotkey v2.0
; Individual Key Toggler with Configurable Intervals
; Each key (1-6) can be toggled on/off with its own interval
; Keys 1-5 support cooldown feature: prevents automated press if manually pressed within cooldown window
; Includes dodge (space) functionality

; Global variables
global isScriptEnabled := false
global keyStates := Map()
global keyIntervals := Map()
global keyControls := Map()
global dodgeEnabled := true
global dodgeInterval := 300
global leftClickEnabled := true
global leftClickInterval := 100
global rightClickEnabled := false
global rightClickInterval := 100

; Cooldown feature for keys 1-5
global keyCooldowns := Map()  ; Stores cooldown intervals (ms)
global lastManualPress := Map()  ; Stores timestamp of last manual press
global keyHeldDown := Map()  ; Tracks which keys are currently held down

; Initialize key states and intervals
keyStates[1] := false
keyStates[2] := true   ; Enabled by default
keyStates[3] := true   ; Enabled by default
keyStates[4] := true   ; Enabled by default
keyStates[5] := true   ; Enabled by default
keyStates[6] := false

keyIntervals[1] := 1000
keyIntervals[2] := 770   ; Around 0.77s
keyIntervals[3] := 1100  ; Around 1s
keyIntervals[4] := 205   ; Very fast spam
keyIntervals[5] := 198   ; Very fast spam
keyIntervals[6] := 1000

; Initialize cooldown intervals (0 = disabled)
keyCooldowns[1] := 0
keyCooldowns[2] := 0
keyCooldowns[3] := 0
keyCooldowns[4] := 1020  ; Ensures key 5 fires before key 4 resumes
keyCooldowns[5] := 0

; Initialize last manual press times
lastManualPress[1] := 0
lastManualPress[2] := 0
lastManualPress[3] := 0
lastManualPress[4] := 0
lastManualPress[5] := 0

; Initialize held down states
keyHeldDown[1] := false
keyHeldDown[2] := false
keyHeldDown[3] := false
keyHeldDown[4] := false
keyHeldDown[5] := false
keyHeldDown[6] := false

; Create GUI
MyGui := Gui("+AlwaysOnTop +Resize", "Individual Key Toggler")
MyGui.SetFont("s10")

; Add title
MyGui.Add("Text", "x10 y10 w480 Center", "Individual Key Toggler")
MyGui.Add("Text", "x10 y+10 w480 Center", "Toggle each key on/off with custom intervals")

; Add master toggle
MyGui.Add("Text", "x10 y+20", "Master Toggle:")
masterToggle := MyGui.Add("Checkbox", "x+10", "Enable Script")
masterToggle.OnEvent("Click", ToggleMasterScript)

; Add global hotkey input
MyGui.Add("Text", "x10 y+10", "Global Toggle Key:")
globalToggleInput := MyGui.Add("Hotkey", "x+10 w100", "F1")

; Add separator
MyGui.Add("Text", "x10 y+20 w450", "──────────────────────────────────────────────────")

; Add legend
MyGui.Add("Text", "x10 y+10 w450", "Interval: Auto-press rate (ms, 0=hold key) | Cooldown: Manual block (ms, 0=off)")

; Key 1
keyControls[1] := {}
keyControls[1].checkbox := MyGui.Add("Checkbox", "x10 y+15", "Key 1")
keyControls[1].checkbox.OnEvent("Click", (*) => ToggleKey(1))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[1].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[1])
keyControls[1].interval.OnEvent("Change", (*) => UpdateKeyInterval(1))
MyGui.Add("Text", "x+10", "Cooldown:")
keyControls[1].cooldown := MyGui.Add("Edit", "x+5 w70", keyCooldowns[1])
keyControls[1].cooldown.OnEvent("Change", (*) => UpdateKeyCooldown(1))

; Key 2
keyControls[2] := {}
keyControls[2].checkbox := MyGui.Add("Checkbox", "x10 y+15 Checked", "Key 2")
keyControls[2].checkbox.OnEvent("Click", (*) => ToggleKey(2))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[2].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[2])
keyControls[2].interval.OnEvent("Change", (*) => UpdateKeyInterval(2))
MyGui.Add("Text", "x+10", "Cooldown:")
keyControls[2].cooldown := MyGui.Add("Edit", "x+5 w70", keyCooldowns[2])
keyControls[2].cooldown.OnEvent("Change", (*) => UpdateKeyCooldown(2))

; Key 3
keyControls[3] := {}
keyControls[3].checkbox := MyGui.Add("Checkbox", "x10 y+15 Checked", "Key 3")
keyControls[3].checkbox.OnEvent("Click", (*) => ToggleKey(3))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[3].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[3])
keyControls[3].interval.OnEvent("Change", (*) => UpdateKeyInterval(3))
MyGui.Add("Text", "x+10", "Cooldown:")
keyControls[3].cooldown := MyGui.Add("Edit", "x+5 w70", keyCooldowns[3])
keyControls[3].cooldown.OnEvent("Change", (*) => UpdateKeyCooldown(3))

; Key 4
keyControls[4] := {}
keyControls[4].checkbox := MyGui.Add("Checkbox", "x10 y+15 Checked", "Key 4")
keyControls[4].checkbox.OnEvent("Click", (*) => ToggleKey(4))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[4].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[4])
keyControls[4].interval.OnEvent("Change", (*) => UpdateKeyInterval(4))
MyGui.Add("Text", "x+10", "Cooldown:")
keyControls[4].cooldown := MyGui.Add("Edit", "x+5 w70", keyCooldowns[4])
keyControls[4].cooldown.OnEvent("Change", (*) => UpdateKeyCooldown(4))

; Key 5
keyControls[5] := {}
keyControls[5].checkbox := MyGui.Add("Checkbox", "x10 y+15 Checked", "Key 5")
keyControls[5].checkbox.OnEvent("Click", (*) => ToggleKey(5))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[5].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[5])
keyControls[5].interval.OnEvent("Change", (*) => UpdateKeyInterval(5))
MyGui.Add("Text", "x+10", "Cooldown:")
keyControls[5].cooldown := MyGui.Add("Edit", "x+5 w70", keyCooldowns[5])
keyControls[5].cooldown.OnEvent("Change", (*) => UpdateKeyCooldown(5))

; Key 6
keyControls[6] := {}
keyControls[6].checkbox := MyGui.Add("Checkbox", "x10 y+15", "Key 6")
keyControls[6].checkbox.OnEvent("Click", (*) => ToggleKey(6))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[6].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[6])
keyControls[6].interval.OnEvent("Change", (*) => UpdateKeyInterval(6))

; Add dodge section
MyGui.Add("Text", "x10 y+20 w450", "──────────────────────────────────────────────────")
dodgeCheckbox := MyGui.Add("Checkbox", "x10 y+15 Checked", "Dodge (Space)")
dodgeCheckbox.OnEvent("Click", ToggleDodge)
MyGui.Add("Text", "x+10", "Interval:")
dodgeIntervalInput := MyGui.Add("Edit", "x+5 w70", dodgeInterval)
dodgeIntervalInput.OnEvent("Change", UpdateDodgeInterval)

; Add mouse click section
MyGui.Add("Text", "x10 y+20 w450", "──────────────────────────────────────────────────")
leftClickCheckbox := MyGui.Add("Checkbox", "x10 y+15 Checked", "Left Click")
leftClickCheckbox.OnEvent("Click", ToggleLeftClick)
MyGui.Add("Text", "x+10", "Interval:")
leftClickIntervalInput := MyGui.Add("Edit", "x+5 w70", leftClickInterval)
leftClickIntervalInput.OnEvent("Change", UpdateLeftClickInterval)

rightClickCheckbox := MyGui.Add("Checkbox", "x10 y+15", "Right Click")
rightClickCheckbox.OnEvent("Click", ToggleRightClick)
MyGui.Add("Text", "x+10", "Interval:")
rightClickIntervalInput := MyGui.Add("Edit", "x+5 w70", rightClickInterval)
rightClickIntervalInput.OnEvent("Change", UpdateRightClickInterval)

; Add control buttons
MyGui.Add("Button", "x10 y+30 w100", "Start All").OnEvent("Click", StartAllKeys)
MyGui.Add("Button", "x+10 w100", "Stop All").OnEvent("Click", StopAllKeys)
MyGui.Add("Button", "x+10 w100", "Exit").OnEvent("Click", (*) => ExitApp())

; Add status text
statusText := MyGui.Add("Text", "x10 y+20 w450", "Status: Script Disabled")

; Show GUI
MyGui.Show("w500 h720")

; Toggle master script
ToggleMasterScript(*) {
    global isScriptEnabled
    isScriptEnabled := masterToggle.Value
    
    if isScriptEnabled {
        ; Set up global hotkey
        Hotkey globalToggleInput.Value, ToggleMasterScriptHotkey
        
        ; Set up manual key press tracking hotkeys for keys 1-5
        ; $ prefix prevents the hotkey from being triggered by Send commands
        Hotkey "$1", (*) => TrackManualKeyPress(1), "On"
        Hotkey "$2", (*) => TrackManualKeyPress(2), "On"
        Hotkey "$3", (*) => TrackManualKeyPress(3), "On"
        Hotkey "$4", (*) => TrackManualKeyPress(4), "On"
        Hotkey "$5", (*) => TrackManualKeyPress(5), "On"
        
        ; Start all enabled keys (timers or hold mode)
        Loop 6 {
            keyNum := A_Index
            if keyStates[keyNum] {
                if keyIntervals[keyNum] = 0 {
                    ; Hold mode
                    Send "{" keyNum " down}"
                    keyHeldDown[keyNum] := true
                } else {
                    ; Timer mode
                    SetTimer () => SendKey(keyNum), keyIntervals[keyNum]
                }
            }
        }
        
        if dodgeEnabled {
            SetTimer RunDodge, dodgeInterval
        }
        
        if leftClickEnabled {
            SetTimer RunLeftClick, leftClickInterval
        }
        
        if rightClickEnabled {
            SetTimer RunRightClick, rightClickInterval
        }
        
        statusText.Text := "Status: Script Enabled - Press " globalToggleInput.Value " to toggle"
    } else {
        ; Disable manual key press tracking hotkeys
        try Hotkey "$1", "Off"
        try Hotkey "$2", "Off"
        try Hotkey "$3", "Off"
        try Hotkey "$4", "Off"
        try Hotkey "$5", "Off"
        
        ; Disable all keys
        StopAllKeys()
        statusText.Text := "Status: Script Disabled"
    }
}

; Toggle individual key
ToggleKey(keyNum) {
    global keyStates, isScriptEnabled, keyIntervals, keyHeldDown
    
    keyStates[keyNum] := keyControls[keyNum].checkbox.Value
    
    ; Only start/stop timers if script is enabled
    if isScriptEnabled {
        if keyStates[keyNum] {
            ; Check if interval is 0 (hold mode)
            if keyIntervals[keyNum] = 0 {
                ; Hold the key down
                Send "{" keyNum " down}"
                keyHeldDown[keyNum] := true
                statusText.Text := "Status: Key " keyNum " held down"
            } else {
                ; Start timer for this key
                SetTimer () => SendKey(keyNum), keyIntervals[keyNum]
                statusText.Text := "Status: Key " keyNum " enabled"
            }
        } else {
            ; Release held key if it was held
            if keyHeldDown[keyNum] {
                Send "{" keyNum " up}"
                keyHeldDown[keyNum] := false
            }
            ; Stop timer for this key
            SetTimer () => SendKey(keyNum), 0
            statusText.Text := "Status: Key " keyNum " disabled"
        }
    } else {
        statusText.Text := "Status: Key " keyNum " toggled (script disabled)"
    }
}

; Update key interval
UpdateKeyInterval(keyNum) {
    global keyIntervals, keyStates, keyHeldDown, isScriptEnabled
    
    try {
        newInterval := Integer(keyControls[keyNum].interval.Value)
        if newInterval >= 0 {
            oldInterval := keyIntervals[keyNum]
            keyIntervals[keyNum] := newInterval
            
            ; Only update if key is enabled and script is running
            if keyStates[keyNum] && isScriptEnabled {
                ; Handle transition from hold mode to tap mode
                if oldInterval = 0 && newInterval > 0 {
                    ; Release the held key
                    if keyHeldDown[keyNum] {
                        Send "{" keyNum " up}"
                        keyHeldDown[keyNum] := false
                    }
                    ; Start timer
                    SetTimer () => SendKey(keyNum), keyIntervals[keyNum]
                }
                ; Handle transition from tap mode to hold mode
                else if oldInterval > 0 && newInterval = 0 {
                    ; Stop timer
                    SetTimer () => SendKey(keyNum), 0
                    ; Hold the key down
                    Send "{" keyNum " down}"
                    keyHeldDown[keyNum] := true
                }
                ; Handle tap mode interval change
                else if newInterval > 0 {
                    ; Restart timer with new interval
                    SetTimer () => SendKey(keyNum), 0
                    SetTimer () => SendKey(keyNum), keyIntervals[keyNum]
                }
            }
        }
    } catch {
        ; Invalid input, revert to previous value
        keyControls[keyNum].interval.Value := keyIntervals[keyNum]
    }
}

; Update key cooldown
UpdateKeyCooldown(keyNum) {
    global keyCooldowns
    
    try {
        newCooldown := Integer(keyControls[keyNum].cooldown.Value)
        if newCooldown >= 0 {
            keyCooldowns[keyNum] := newCooldown
        }
    } catch {
        ; Invalid input, revert to previous value
        keyControls[keyNum].cooldown.Value := keyCooldowns[keyNum]
    }
}

; Send key function
SendKey(keyNum) {
    global keyStates, isScriptEnabled, keyCooldowns, lastManualPress, keyIntervals
    
    if !(isScriptEnabled && keyStates[keyNum])
        return
    
    ; Ignore cooldown if interval is 0 (hold mode)
    if keyIntervals[keyNum] > 0 {
        ; Check cooldown for keys 1-5
        if keyNum >= 1 && keyNum <= 5 {
            cooldown := keyCooldowns[keyNum]
            if cooldown > 0 {
                currentTime := A_TickCount
                timeSinceLastPress := currentTime - lastManualPress[keyNum]
                
                ; If key was pressed manually within cooldown window, skip
                if timeSinceLastPress < cooldown {
                    return
                }
            }
        }
    }
        
    Send "{" keyNum "}"
}

; Track manual key press
TrackManualKeyPress(keyNum) {
    global lastManualPress, keyCooldowns
    
    ; Only track if cooldown is enabled for this key
    if keyCooldowns[keyNum] > 0 {
        lastManualPress[keyNum] := A_TickCount
    }
    
    ; Pass through the key press
    Send "{" keyNum "}"
}

; Toggle dodge
ToggleDodge(*) {
    global dodgeEnabled, isScriptEnabled
    
    dodgeEnabled := dodgeCheckbox.Value
    
    ; Only start/stop timers if script is enabled
    if isScriptEnabled {
        if dodgeEnabled {
            SetTimer RunDodge, dodgeInterval
            statusText.Text := "Status: Dodge enabled"
        } else {
            SetTimer RunDodge, 0
            statusText.Text := "Status: Dodge disabled"
        }
    } else {
        statusText.Text := "Status: Dodge toggled (script disabled)"
    }
}

; Update dodge interval
UpdateDodgeInterval(*) {
    global dodgeInterval, dodgeEnabled
    
    try {
        newInterval := Integer(dodgeIntervalInput.Value)
        if newInterval > 0 {
            dodgeInterval := newInterval
            
            ; Restart timer if dodge is enabled
            if dodgeEnabled {
                SetTimer RunDodge, 0
                SetTimer RunDodge, dodgeInterval
            }
        }
    } catch {
        ; Invalid input, revert to previous value
        dodgeIntervalInput.Value := dodgeInterval
    }
}

; Run dodge function
RunDodge() {
    global dodgeEnabled, isScriptEnabled
    
    if !(isScriptEnabled && dodgeEnabled)
        return
        
    Send "{Space}"
}

; Toggle left click
ToggleLeftClick(*) {
    global leftClickEnabled, isScriptEnabled
    
    leftClickEnabled := leftClickCheckbox.Value
    
    ; Only start/stop timers if script is enabled
    if isScriptEnabled {
        if leftClickEnabled {
            SetTimer RunLeftClick, leftClickInterval
            statusText.Text := "Status: Left Click enabled"
        } else {
            SetTimer RunLeftClick, 0
            statusText.Text := "Status: Left Click disabled"
        }
    } else {
        statusText.Text := "Status: Left Click toggled (script disabled)"
    }
}

; Update left click interval
UpdateLeftClickInterval(*) {
    global leftClickInterval, leftClickEnabled
    
    try {
        newInterval := Integer(leftClickIntervalInput.Value)
        if newInterval > 0 {
            leftClickInterval := newInterval
            
            ; Restart timer if left click is enabled
            if leftClickEnabled {
                SetTimer RunLeftClick, 0
                SetTimer RunLeftClick, leftClickInterval
            }
        }
    } catch {
        ; Invalid input, revert to previous value
        leftClickIntervalInput.Value := leftClickInterval
    }
}

; Run left click function
RunLeftClick() {
    global leftClickEnabled, isScriptEnabled
    
    if !(isScriptEnabled && leftClickEnabled)
        return
        
    Click
}

; Toggle right click
ToggleRightClick(*) {
    global rightClickEnabled, isScriptEnabled
    
    rightClickEnabled := rightClickCheckbox.Value
    
    ; Only start/stop timers if script is enabled
    if isScriptEnabled {
        if rightClickEnabled {
            SetTimer RunRightClick, rightClickInterval
            statusText.Text := "Status: Right Click enabled"
        } else {
            SetTimer RunRightClick, 0
            statusText.Text := "Status: Right Click disabled"
        }
    } else {
        statusText.Text := "Status: Right Click toggled (script disabled)"
    }
}

; Update right click interval
UpdateRightClickInterval(*) {
    global rightClickInterval, rightClickEnabled
    
    try {
        newInterval := Integer(rightClickIntervalInput.Value)
        if newInterval > 0 {
            rightClickInterval := newInterval
            
            ; Restart timer if right click is enabled
            if rightClickEnabled {
                SetTimer RunRightClick, 0
                SetTimer RunRightClick, rightClickInterval
            }
        }
    } catch {
        ; Invalid input, revert to previous value
        rightClickIntervalInput.Value := rightClickInterval
    }
}

; Run right click function
RunRightClick() {
    global rightClickEnabled, isScriptEnabled
    
    if !(isScriptEnabled && rightClickEnabled)
        return
        
    Click "Right"
}

; Start all enabled keys
StartAllKeys(*) {
    global isScriptEnabled, keyHeldDown
    
    if !isScriptEnabled {
        statusText.Text := "Status: Enable script first"
        return
    }
    
    ; Start all enabled keys (timers or hold mode)
    Loop 6 {
        keyNum := A_Index
        if keyStates[keyNum] {
            if keyIntervals[keyNum] = 0 {
                ; Hold mode
                if !keyHeldDown[keyNum] {
                    Send "{" keyNum " down}"
                    keyHeldDown[keyNum] := true
                }
            } else {
                ; Timer mode
                SetTimer () => SendKey(keyNum), keyIntervals[keyNum]
            }
        }
    }
    
    if dodgeEnabled {
        SetTimer RunDodge, dodgeInterval
    }
    
    if leftClickEnabled {
        SetTimer RunLeftClick, leftClickInterval
    }
    
    if rightClickEnabled {
        SetTimer RunRightClick, rightClickInterval
    }
    
    statusText.Text := "Status: All enabled keys started"
}

; Stop all keys
StopAllKeys(*) {
    global keyHeldDown
    
    ; Stop all timers
    SetTimer () => SendKey(1), 0
    SetTimer () => SendKey(2), 0
    SetTimer () => SendKey(3), 0
    SetTimer () => SendKey(4), 0
    SetTimer () => SendKey(5), 0
    SetTimer () => SendKey(6), 0
    SetTimer RunDodge, 0
    SetTimer RunLeftClick, 0
    SetTimer RunRightClick, 0
    
    ; Release all held keys
    Loop 6 {
        keyNum := A_Index
        if keyHeldDown[keyNum] {
            Send "{" keyNum " up}"
            keyHeldDown[keyNum] := false
        }
    }
    
    statusText.Text := "Status: All keys stopped"
}

; Hotkey to toggle master script
ToggleMasterScriptHotkey(*) {
    masterToggle.Value := !masterToggle.Value
    ToggleMasterScript()
}
