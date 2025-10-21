#Requires AutoHotkey v2.0
; Individual Key Toggler with Configurable Intervals
; Each key (1-6) can be toggled on/off with its own interval
; Includes dodge (space) functionality

; Global variables
global isScriptEnabled := false
global keyStates := Map()
global keyIntervals := Map()
global keyControls := Map()
global dodgeEnabled := false
global dodgeInterval := 1000
global leftClickEnabled := false
global leftClickInterval := 100
global rightClickEnabled := false
global rightClickInterval := 100

; Initialize key states and intervals
keyStates[1] := false
keyStates[2] := false
keyStates[3] := false
keyStates[4] := false
keyStates[5] := false
keyStates[6] := false

keyIntervals[1] := 1000
keyIntervals[2] := 1000
keyIntervals[3] := 500
keyIntervals[4] := 1000
keyIntervals[5] := 1000
keyIntervals[6] := 1000

; Create GUI
MyGui := Gui("+AlwaysOnTop +Resize", "Individual Key Toggler")
MyGui.SetFont("s10")

; Add title
MyGui.Add("Text", "x10 y10 w300 Center", "Individual Key Toggler")
MyGui.Add("Text", "x10 y+10 w300 Center", "Toggle each key on/off with custom intervals")

; Add master toggle
MyGui.Add("Text", "x10 y+20", "Master Toggle:")
masterToggle := MyGui.Add("Checkbox", "x+10", "Enable Script")
masterToggle.OnEvent("Click", ToggleMasterScript)

; Add global hotkey input
MyGui.Add("Text", "x10 y+10", "Global Toggle Key:")
globalToggleInput := MyGui.Add("Hotkey", "x+10 w100", "F1")

; Add separator
MyGui.Add("Text", "x10 y+20 w330", "──────────────────────────────")

; Key 1
keyControls[1] := {}
keyControls[1].checkbox := MyGui.Add("Checkbox", "x10 y+10", "Key 1")
keyControls[1].checkbox.OnEvent("Click", (*) => ToggleKey(1))
MyGui.Add("Text", "x+10", "Interval (ms):")
keyControls[1].interval := MyGui.Add("Edit", "x+5 w80", keyIntervals[1])
keyControls[1].interval.OnEvent("Change", (*) => UpdateKeyInterval(1))

; Key 2
keyControls[2] := {}
keyControls[2].checkbox := MyGui.Add("Checkbox", "x10 y+10", "Key 2")
keyControls[2].checkbox.OnEvent("Click", (*) => ToggleKey(2))
MyGui.Add("Text", "x+10", "Interval (ms):")
keyControls[2].interval := MyGui.Add("Edit", "x+5 w80", keyIntervals[2])
keyControls[2].interval.OnEvent("Change", (*) => UpdateKeyInterval(2))

; Key 3
keyControls[3] := {}
keyControls[3].checkbox := MyGui.Add("Checkbox", "x10 y+10", "Key 3")
keyControls[3].checkbox.OnEvent("Click", (*) => ToggleKey(3))
MyGui.Add("Text", "x+10", "Interval (ms):")
keyControls[3].interval := MyGui.Add("Edit", "x+5 w80", keyIntervals[3])
keyControls[3].interval.OnEvent("Change", (*) => UpdateKeyInterval(3))

; Key 4
keyControls[4] := {}
keyControls[4].checkbox := MyGui.Add("Checkbox", "x10 y+10", "Key 4")
keyControls[4].checkbox.OnEvent("Click", (*) => ToggleKey(4))
MyGui.Add("Text", "x+10", "Interval (ms):")
keyControls[4].interval := MyGui.Add("Edit", "x+5 w80", keyIntervals[4])
keyControls[4].interval.OnEvent("Change", (*) => UpdateKeyInterval(4))

; Key 5
keyControls[5] := {}
keyControls[5].checkbox := MyGui.Add("Checkbox", "x10 y+10", "Key 5")
keyControls[5].checkbox.OnEvent("Click", (*) => ToggleKey(5))
MyGui.Add("Text", "x+10", "Interval (ms):")
keyControls[5].interval := MyGui.Add("Edit", "x+5 w80", keyIntervals[5])
keyControls[5].interval.OnEvent("Change", (*) => UpdateKeyInterval(5))

; Key 6
keyControls[6] := {}
keyControls[6].checkbox := MyGui.Add("Checkbox", "x10 y+10", "Key 6")
keyControls[6].checkbox.OnEvent("Click", (*) => ToggleKey(6))
MyGui.Add("Text", "x+10", "Interval (ms):")
keyControls[6].interval := MyGui.Add("Edit", "x+5 w80", keyIntervals[6])
keyControls[6].interval.OnEvent("Change", (*) => UpdateKeyInterval(6))

; Add dodge section
MyGui.Add("Text", "x10 y+20 w330", "──────────────────────────────")
dodgeCheckbox := MyGui.Add("Checkbox", "x10 y+10", "Dodge (Space)")
dodgeCheckbox.OnEvent("Click", ToggleDodge)
MyGui.Add("Text", "x+10", "Interval (ms):")
dodgeIntervalInput := MyGui.Add("Edit", "x+5 w80", dodgeInterval)
dodgeIntervalInput.OnEvent("Change", UpdateDodgeInterval)

; Add mouse click section
MyGui.Add("Text", "x10 y+20 w330", "──────────────────────────────")
leftClickCheckbox := MyGui.Add("Checkbox", "x10 y+10", "Left Click")
leftClickCheckbox.OnEvent("Click", ToggleLeftClick)
MyGui.Add("Text", "x+10", "Interval (ms):")
leftClickIntervalInput := MyGui.Add("Edit", "x+5 w80", leftClickInterval)
leftClickIntervalInput.OnEvent("Change", UpdateLeftClickInterval)

rightClickCheckbox := MyGui.Add("Checkbox", "x10 y+10", "Right Click")
rightClickCheckbox.OnEvent("Click", ToggleRightClick)
MyGui.Add("Text", "x+10", "Interval (ms):")
rightClickIntervalInput := MyGui.Add("Edit", "x+5 w80", rightClickInterval)
rightClickIntervalInput.OnEvent("Change", UpdateRightClickInterval)

; Add control buttons
MyGui.Add("Button", "x10 y+30 w100", "Start All").OnEvent("Click", StartAllKeys)
MyGui.Add("Button", "x+10 w100", "Stop All").OnEvent("Click", StopAllKeys)
MyGui.Add("Button", "x+10 w100", "Exit").OnEvent("Click", (*) => ExitApp())

; Add status text
statusText := MyGui.Add("Text", "x10 y+20 w300", "Status: Script Disabled")

; Show GUI
MyGui.Show("w350 h700")

; Toggle master script
ToggleMasterScript(*) {
    global isScriptEnabled
    isScriptEnabled := masterToggle.Value
    
    if isScriptEnabled {
        ; Set up global hotkey
        Hotkey globalToggleInput.Value, ToggleMasterScriptHotkey
        
        ; Start all enabled timers
        if keyStates[1] {
            SetTimer () => SendKey(1), keyIntervals[1]
        }
        if keyStates[2] {
            SetTimer () => SendKey(2), keyIntervals[2]
        }
        if keyStates[3] {
            SetTimer () => SendKey(3), keyIntervals[3]
        }
        if keyStates[4] {
            SetTimer () => SendKey(4), keyIntervals[4]
        }
        if keyStates[5] {
            SetTimer () => SendKey(5), keyIntervals[5]
        }
        if keyStates[6] {
            SetTimer () => SendKey(6), keyIntervals[6]
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
        ; Disable all keys
        StopAllKeys()
        statusText.Text := "Status: Script Disabled"
    }
}

; Toggle individual key
ToggleKey(keyNum) {
    global keyStates, isScriptEnabled
    
    keyStates[keyNum] := keyControls[keyNum].checkbox.Value
    
    ; Only start/stop timers if script is enabled
    if isScriptEnabled {
        if keyStates[keyNum] {
            ; Start timer for this key
            SetTimer () => SendKey(keyNum), keyIntervals[keyNum]
            statusText.Text := "Status: Key " keyNum " enabled"
        } else {
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
    global keyIntervals, keyStates
    
    try {
        newInterval := Integer(keyControls[keyNum].interval.Value)
        if newInterval > 0 {
            keyIntervals[keyNum] := newInterval
            
            ; Restart timer if key is enabled
            if keyStates[keyNum] {
                SetTimer () => SendKey(keyNum), 0
                SetTimer () => SendKey(keyNum), keyIntervals[keyNum]
            }
        }
    } catch {
        ; Invalid input, revert to previous value
        keyControls[keyNum].interval.Value := keyIntervals[keyNum]
    }
}

; Send key function
SendKey(keyNum) {
    global keyStates, isScriptEnabled
    
    if !(isScriptEnabled && keyStates[keyNum])
        return
        
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
    global isScriptEnabled
    
    if !isScriptEnabled {
        statusText.Text := "Status: Enable script first"
        return
    }
    
    if keyStates[1] {
        SetTimer () => SendKey(1), keyIntervals[1]
    }
    if keyStates[2] {
        SetTimer () => SendKey(2), keyIntervals[2]
    }
    if keyStates[3] {
        SetTimer () => SendKey(3), keyIntervals[3]
    }
    if keyStates[4] {
        SetTimer () => SendKey(4), keyIntervals[4]
    }
    if keyStates[5] {
        SetTimer () => SendKey(5), keyIntervals[5]
    }
    if keyStates[6] {
        SetTimer () => SendKey(6), keyIntervals[6]
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
    SetTimer () => SendKey(1), 0
    SetTimer () => SendKey(2), 0
    SetTimer () => SendKey(3), 0
    SetTimer () => SendKey(4), 0
    SetTimer () => SendKey(5), 0
    SetTimer () => SendKey(6), 0
    SetTimer RunDodge, 0
    SetTimer RunLeftClick, 0
    SetTimer RunRightClick, 0
    statusText.Text := "Status: All keys stopped"
}

; Hotkey to toggle master script
ToggleMasterScriptHotkey(*) {
    masterToggle.Value := !masterToggle.Value
    ToggleMasterScript()
}
