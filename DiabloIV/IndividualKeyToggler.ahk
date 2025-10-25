#Requires AutoHotkey v2.0
; Individual Key Toggler with Configurable Intervals
; Each key (1-6) can be toggled on/off with its own interval
; Includes dodge (space) and mouse click functionality

; Global variables
global isScriptEnabled := false
global keyStates := Map()
global keyIntervals := Map()
global keyControls := Map()
global keyTimers := Map()
global dodgeEnabled := true
global dodgeInterval := 321
global leftClickEnabled := false
global leftClickInterval := 120
global rightClickEnabled := false
global rightClickInterval := 110
global holdRightEnabled := false
global jitterMs := 10
global key6PreWaitMs := 450
global actionGuardMs := 50
global lastActionTick := 0
global preBlockUntilTick := 0
global key6PendingSendFn := ""
global keyPressDuration := 50  ; Default key press hold time in ms

; Add global config variables
global configPath := A_ScriptDir . "\toggler_config.ini"
global statusText


; Initialize key states and intervals
keyStates[1] := true   ; Enabled by default
keyStates[2] := true   ; Enabled by default
keyStates[3] := true   ; Enabled by default
keyStates[4] := true   ; Enabled by default
keyStates[5] := false
keyStates[6] := true

keyIntervals[1] := 660
keyIntervals[2] := 570  ; Around 0.57s
keyIntervals[3] := 720  ; Around 0.62s
keyIntervals[4] := 160  ; Around 0.16s
keyIntervals[5] := 450
keyIntervals[6] := 520

; Add LoadConfig and SaveConfig functions before GUI creation

; Load configuration from INI file
LoadConfig() {
    global keyStates, keyIntervals, dodgeEnabled, dodgeInterval, leftClickEnabled, leftClickInterval
    global rightClickEnabled, rightClickInterval, holdRightEnabled, jitterMs, key6PreWaitMs, actionGuardMs, keyPressDuration
    
    if !FileExist(configPath)
        return  ; Config file doesn't exist yet, use defaults
    
    ; Load key states
    Loop 6 {
        keyNum := A_Index
        keyStates[keyNum] := (IniRead(configPath, "Keys", "Key" . keyNum . "Enabled", keyStates[keyNum] ? "1" : "0") = "1")
    }
    
    ; Load key intervals
    Loop 6 {
        keyNum := A_Index
        keyIntervals[keyNum] := Integer(IniRead(configPath, "Keys", "Key" . keyNum . "Interval", keyIntervals[keyNum]))
    }
    
    ; Load dodge settings
    dodgeEnabled := (IniRead(configPath, "Dodge", "Enabled", dodgeEnabled ? "1" : "0") = "1")
    dodgeInterval := Integer(IniRead(configPath, "Dodge", "Interval", dodgeInterval))
    
    ; Load left click settings
    leftClickEnabled := (IniRead(configPath, "LeftClick", "Enabled", leftClickEnabled ? "1" : "0") = "1")
    leftClickInterval := Integer(IniRead(configPath, "LeftClick", "Interval", leftClickInterval))
    
    ; Load right click settings
    rightClickEnabled := (IniRead(configPath, "RightClick", "Enabled", rightClickEnabled ? "1" : "0") = "1")
    rightClickInterval := Integer(IniRead(configPath, "RightClick", "Interval", rightClickInterval))
    
    ; Load hold right
    holdRightEnabled := (IniRead(configPath, "RightClick", "HoldEnabled", holdRightEnabled ? "1" : "0") = "1")
    
    ; Load advanced
    jitterMs := Integer(IniRead(configPath, "Advanced", "JitterMs", jitterMs))
    key6PreWaitMs := Integer(IniRead(configPath, "Advanced", "Key6PreWaitMs", key6PreWaitMs))
    actionGuardMs := Integer(IniRead(configPath, "Advanced", "ActionGuardMs", actionGuardMs))
    keyPressDuration := Integer(IniRead(configPath, "Advanced", "KeyPressDuration", keyPressDuration))
}

; Save configuration to INI file
SaveConfig(*) {
    global keyStates, keyIntervals, dodgeEnabled, dodgeInterval, leftClickEnabled, leftClickInterval
    global rightClickEnabled, rightClickInterval, holdRightEnabled, jitterMs, key6PreWaitMs, actionGuardMs, keyPressDuration
    
    ; Save key states
    Loop 6 {
        keyNum := A_Index
        IniWrite (keyStates[keyNum] ? "1" : "0"), configPath, "Keys", "Key" . keyNum . "Enabled"
    }
    
    ; Save key intervals
    Loop 6 {
        keyNum := A_Index
        IniWrite keyIntervals[keyNum], configPath, "Keys", "Key" . keyNum . "Interval"
    }
    
    ; Save dodge
    IniWrite (dodgeEnabled ? "1" : "0"), configPath, "Dodge", "Enabled"
    IniWrite dodgeInterval, configPath, "Dodge", "Interval"
    
    ; Save left click
    IniWrite (leftClickEnabled ? "1" : "0"), configPath, "LeftClick", "Enabled"
    IniWrite leftClickInterval, configPath, "LeftClick", "Interval"
    
    ; Save right click
    IniWrite (rightClickEnabled ? "1" : "0"), configPath, "RightClick", "Enabled"
    IniWrite rightClickInterval, configPath, "RightClick", "Interval"
    
    ; Save hold right
    IniWrite (holdRightEnabled ? "1" : "0"), configPath, "RightClick", "HoldEnabled"
    
    ; Save advanced
    IniWrite jitterMs, configPath, "Advanced", "JitterMs"
    IniWrite key6PreWaitMs, configPath, "Advanced", "Key6PreWaitMs"
    IniWrite actionGuardMs, configPath, "Advanced", "ActionGuardMs"
    IniWrite keyPressDuration, configPath, "Advanced", "KeyPressDuration"
    
    if IsSet(statusText) {
        statusText.Text := "Status: Settings saved to config.ini"
    }
}

; Load config before creating GUI
LoadConfig()

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
MyGui.Add("Text", "x10 y+10 w450", "Interval: Auto-press rate in milliseconds (lower = faster, minimum 10ms)")

; Global action guard and advanced settings - split into two lines
MyGui.Add("Text", "x10 y+15", "Action Guard (ms):")
actionGuardInput := MyGui.Add("Edit", "x+5 w70", actionGuardMs)
actionGuardInput.OnEvent("Change", UpdateActionGuardMs)
MyGui.Add("Text", "x+10", "Jitter (+/- ms):")
jitterInput := MyGui.Add("Edit", "x+5 w50", jitterMs)
jitterInput.OnEvent("Change", UpdateJitterMs)

MyGui.Add("Text", "x10 y+10", "Key6 Pre-Wait (ms):")
key6PreWaitInput := MyGui.Add("Edit", "x+5 w60", key6PreWaitMs)
key6PreWaitInput.OnEvent("Change", UpdateKey6PreWaitMs)
MyGui.Add("Text", "x+10", "Key Press (ms):")
keyPressDurationInput := MyGui.Add("Edit", "x+5 w60", keyPressDuration)
keyPressDurationInput.OnEvent("Change", UpdateKeyPressDuration)

; Key 1
keyControls[1] := {}
keyControls[1].checkbox := MyGui.Add("Checkbox", "x10 y+15", "Key 1")
keyControls[1].checkbox.Value := keyStates[1] ? 1 : 0
keyControls[1].checkbox.OnEvent("Click", (*) => ToggleKey(1))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[1].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[1])
keyControls[1].interval.OnEvent("Change", (*) => UpdateKeyInterval(1))

; Key 2
keyControls[2] := {}
keyControls[2].checkbox := MyGui.Add("Checkbox", "x10 y+15", "Key 2")
keyControls[2].checkbox.Value := keyStates[2] ? 1 : 0
keyControls[2].checkbox.OnEvent("Click", (*) => ToggleKey(2))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[2].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[2])
keyControls[2].interval.OnEvent("Change", (*) => UpdateKeyInterval(2))

; Key 3
keyControls[3] := {}
keyControls[3].checkbox := MyGui.Add("Checkbox", "x10 y+15", "Key 3")
keyControls[3].checkbox.Value := keyStates[3] ? 1 : 0
keyControls[3].checkbox.OnEvent("Click", (*) => ToggleKey(3))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[3].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[3])
keyControls[3].interval.OnEvent("Change", (*) => UpdateKeyInterval(3))

; Key 4
keyControls[4] := {}
keyControls[4].checkbox := MyGui.Add("Checkbox", "x10 y+15", "Key 4")
keyControls[4].checkbox.Value := keyStates[4] ? 1 : 0
keyControls[4].checkbox.OnEvent("Click", (*) => ToggleKey(4))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[4].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[4])
keyControls[4].interval.OnEvent("Change", (*) => UpdateKeyInterval(4))

; Key 5
keyControls[5] := {}
keyControls[5].checkbox := MyGui.Add("Checkbox", "x10 y+15", "Key 5")
keyControls[5].checkbox.Value := keyStates[5] ? 1 : 0
keyControls[5].checkbox.OnEvent("Click", (*) => ToggleKey(5))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[5].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[5])
keyControls[5].interval.OnEvent("Change", (*) => UpdateKeyInterval(5))

; Key 6
keyControls[6] := {}
keyControls[6].checkbox := MyGui.Add("Checkbox", "x10 y+15", "Key 6")
keyControls[6].checkbox.Value := keyStates[6] ? 1 : 0
keyControls[6].checkbox.OnEvent("Click", (*) => ToggleKey(6))
MyGui.Add("Text", "x+10", "Interval:")
keyControls[6].interval := MyGui.Add("Edit", "x+5 w70", keyIntervals[6])
keyControls[6].interval.OnEvent("Change", (*) => UpdateKeyInterval(6))

; Add dodge section
MyGui.Add("Text", "x10 y+20 w450", "──────────────────────────────────────────────────")
dodgeCheckbox := MyGui.Add("Checkbox", "x10 y+15", "Dodge (Space)")
dodgeCheckbox.Value := dodgeEnabled ? 1 : 0
dodgeCheckbox.OnEvent("Click", ToggleDodge)
MyGui.Add("Text", "x+10", "Interval:")
dodgeIntervalInput := MyGui.Add("Edit", "x+5 w70", dodgeInterval)
dodgeIntervalInput.OnEvent("Change", UpdateDodgeInterval)

; Add mouse click section
MyGui.Add("Text", "x10 y+20 w450", "──────────────────────────────────────────────────")
leftClickCheckbox := MyGui.Add("Checkbox", "x10 y+15", "Left Click")
leftClickCheckbox.Value := leftClickEnabled ? 1 : 0
leftClickCheckbox.OnEvent("Click", ToggleLeftClick)
MyGui.Add("Text", "x+10", "Interval:")
leftClickIntervalInput := MyGui.Add("Edit", "x+5 w70", leftClickInterval)
leftClickIntervalInput.OnEvent("Change", UpdateLeftClickInterval)

rightClickCheckbox := MyGui.Add("Checkbox", "x10 y+15", "Right Click")
rightClickCheckbox.Value := rightClickEnabled ? 1 : 0
rightClickCheckbox.OnEvent("Click", ToggleRightClick)
MyGui.Add("Text", "x+10", "Interval:")
rightClickIntervalInput := MyGui.Add("Edit", "x+5 w70", rightClickInterval)
rightClickIntervalInput.OnEvent("Change", UpdateRightClickInterval)

; Hold Right Click
holdRightCheckbox := MyGui.Add("Checkbox", "x10 y+15", "Hold Right Click")
holdRightCheckbox.Value := holdRightEnabled ? 1 : 0
holdRightCheckbox.OnEvent("Click", ToggleHoldRightClick)

; Add control buttons
MyGui.Add("Button", "x10 y+30 w100", "Start All").OnEvent("Click", StartAllKeys)
MyGui.Add("Button", "x+10 w100", "Stop All").OnEvent("Click", StopAllKeys)
MyGui.Add("Button", "x+10 w100", "Save Settings").OnEvent("Click", SaveConfig)
MyGui.Add("Button", "x+10 w100", "Exit").OnEvent("Click", (*) => ExitApp())

; Add status text
statusText := MyGui.Add("Text", "x10 y+20 w450", "Status: Script Disabled")

; Show GUI
MyGui.Show("w470 h840")

; Toggle master script
ToggleMasterScript(*) {
    global isScriptEnabled, keyTimers, holdRightEnabled
    isScriptEnabled := masterToggle.Value
    
    if isScriptEnabled {
        ; Set up global hotkey
        Hotkey globalToggleInput.Value, ToggleMasterScriptHotkey
        
        ; Start all enabled keys with timers
        Loop 6 {
            keyNum := A_Index
            
            if keyStates[keyNum] && keyIntervals[keyNum] > 0 {
                ScheduleKeyWithJitter(keyNum)
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
        
        if holdRightEnabled {
            Send "{RButton down}"
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
    global keyStates, isScriptEnabled, keyIntervals, keyTimers
    
    keyStates[keyNum] := keyControls[keyNum].checkbox.Value
    
    ; Only start/stop timers if script is enabled
    if isScriptEnabled {
        if keyStates[keyNum] && keyIntervals[keyNum] > 0 {
            ; Start timer for this key (store bound function so we can stop it later)
            if keyTimers.Has(keyNum)
                SetTimer keyTimers[keyNum], 0
            ScheduleKeyWithJitter(keyNum)
            statusText.Text := "Status: Key " keyNum " enabled"
        } else {
            ; Stop timer for this key
            if keyTimers.Has(keyNum)
                SetTimer keyTimers[keyNum], 0
            statusText.Text := "Status: Key " keyNum " disabled"
        }
    } else {
        statusText.Text := "Status: Key " keyNum " toggled (script disabled)"
    }
}

; Update key interval
UpdateKeyInterval(keyNum) {
    global keyIntervals, keyStates, isScriptEnabled, keyTimers
    
    try {
        newInterval := Integer(keyControls[keyNum].interval.Value)
        if newInterval > 0 {
            keyIntervals[keyNum] := newInterval
            
            ; Restart timer if key is enabled and script is running
            if keyStates[keyNum] && isScriptEnabled {
                if keyTimers.Has(keyNum)
                    SetTimer keyTimers[keyNum], 0
                ScheduleKeyWithJitter(keyNum)
            }
        }
    } catch {
        ; Invalid input, revert to previous value
        keyControls[keyNum].interval.Value := keyIntervals[keyNum]
    }
}

; Send key function
SendKey(keyNum) {
    global keyStates, isScriptEnabled, actionGuardMs, lastActionTick, preBlockUntilTick, keyPressDuration
    
    if !(isScriptEnabled && keyStates[keyNum])
        return
    
    now := A_TickCount
    if now < preBlockUntilTick
        return
    
    if (now - lastActionTick) < actionGuardMs
        return
    lastActionTick := now
    
    Send "{" keyNum " down}"
    Sleep keyPressDuration
    Send "{" keyNum " up}"
}

; Send key bypassing pre-block (used by key 6)
SendKeyForce(keyNum) {
    global keyStates, isScriptEnabled, actionGuardMs, lastActionTick, keyPressDuration
    
    if !(isScriptEnabled && keyStates[keyNum])
        return
    
    now := A_TickCount
    if (now - lastActionTick) < actionGuardMs
        return
    lastActionTick := now
    
    Send "{" keyNum " down}"
    Sleep keyPressDuration
    Send "{" keyNum " up}"
}

; Update action guard ms
UpdateActionGuardMs(*) {
    global actionGuardMs
    try {
        newMs := Integer(actionGuardInput.Value)
        if newMs >= 0 {
            actionGuardMs := newMs
        }
    } catch {
        actionGuardInput.Value := actionGuardMs
    }
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
    global dodgeEnabled, isScriptEnabled, keyPressDuration
    
    if !(isScriptEnabled && dodgeEnabled)
        return
        
    Send "{Space down}"
    Sleep keyPressDuration
    Send "{Space up}"
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

; Toggle hold right click
ToggleHoldRightClick(*) {
    global holdRightEnabled, isScriptEnabled
    
    holdRightEnabled := holdRightCheckbox.Value
    
    if isScriptEnabled {
        if holdRightEnabled {
            Send "{RButton down}"
            statusText.Text := "Status: Hold Right Click enabled"
        } else {
            Send "{RButton up}"
            statusText.Text := "Status: Hold Right Click disabled"
        }
    } else {
        statusText.Text := "Status: Hold Right Click toggled (script disabled)"
    }
}

; Run hold right click function
RunHoldRightClick() {
    global rightClickEnabled, isScriptEnabled
    
    if !(isScriptEnabled && rightClickEnabled)
        return
        
    Click "Right"
}

; Start all enabled keys
StartAllKeys(*) {
    global isScriptEnabled, keyTimers, holdRightEnabled
    
    if !isScriptEnabled {
        statusText.Text := "Status: Enable script first"
        return
    }
    
    ; Start all enabled keys with timers
    Loop 6 {
        keyNum := A_Index
        if keyStates[keyNum] && keyIntervals[keyNum] > 0 {
            if keyTimers.Has(keyNum)
                SetTimer keyTimers[keyNum], 0
            ScheduleKeyWithJitter(keyNum)
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
    
    if holdRightEnabled {
        Send "{RButton down}"
    }
    
    statusText.Text := "Status: All enabled keys started"
}

; Stop all keys
StopAllKeys(*) {
    ; Stop all timers
    Loop 6 {
        idx := A_Index
        if keyTimers.Has(idx)
            SetTimer keyTimers[idx], 0
    }
    SetTimer RunDodge, 0
    SetTimer RunLeftClick, 0
    SetTimer RunRightClick, 0
    
    ; Release held right button if engaged
    Send "{RButton up}"
    
    ; Clear key6 pre-block and pending send
    global preBlockUntilTick, key6PendingSendFn
    preBlockUntilTick := 0
    key6PendingSendFn := ""
    
    statusText.Text := "Status: All keys stopped"
}

; Hotkey to toggle master script
ToggleMasterScriptHotkey(*) {
    masterToggle.Value := !masterToggle.Value
    ToggleMasterScript()
}

; Ensure mouse button released on exit
OnExit(ReleaseHoldOnExit)
ReleaseHoldOnExit(ExitReason, ExitCode) {
    try {
        Send "{RButton up}"
    }
}

; Schedule next press for a key with jitter (one-shot)
ScheduleKeyWithJitter(keyNum) {
    global keyIntervals, keyStates, isScriptEnabled, keyTimers, jitterMs, key6PreWaitMs, preBlockUntilTick, key6PendingSendFn
    if !(isScriptEnabled && keyStates[keyNum])
        return
    base := keyIntervals[keyNum]
    ; Random offset in [-jitterMs, +jitterMs]
    offset := 0
    try {
        if jitterMs > 0 {
            offset := Random(-jitterMs, jitterMs)
        }
    }
    next := base + offset
    if next < 10
        next := 10
    
    if keyTimers.Has(keyNum)
        SetTimer keyTimers[keyNum], 0
    
    if (keyNum = 6) {
        ; For key 6, schedule a pre-wait block then send
        sendFn := (*) => (SendKeyForce(6), ScheduleKeyWithJitter(6))
        key6PendingSendFn := sendFn
        keyTimers[6] := sendFn
        preBlockUntilTick := A_TickCount + key6PreWaitMs
        SetTimer sendFn, -next  ; include jitter in overall cadence
        return
    }
    
    fn := (*) => (SendKey(keyNum), ScheduleKeyWithJitter(keyNum))
    keyTimers[keyNum] := fn
    SetTimer fn, -next
}

; Update jitter ms
UpdateJitterMs(*) {
    global jitterMs
    try {
        newVal := Integer(jitterInput.Value)
        if newVal >= 0 {
            jitterMs := newVal
        }
    } catch {
        jitterInput.Value := jitterMs
    }
}

UpdateKey6PreWaitMs(*) {
    global key6PreWaitMs
    try {
        newVal := Integer(key6PreWaitInput.Value)
        if newVal >= 0 {
            key6PreWaitMs := newVal
        }
    } catch {
        key6PreWaitInput.Value := key6PreWaitMs
    }
}

; Update key press duration
UpdateKeyPressDuration(*) {
    global keyPressDuration
    try {
        newVal := Integer(keyPressDurationInput.Value)
        if newVal >= 0 {
            keyPressDuration := newVal
        }
    } catch {
        keyPressDurationInput.Value := keyPressDuration
    }
}
