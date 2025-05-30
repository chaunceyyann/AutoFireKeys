#Requires AutoHotkey v2.0
; Added script to tap skills in an interval in a loop
; Add ui take input of hotkeys and show description
; skill key 1-6, space, mouse 1
; Sequence (F1): tap skill key 1, 2, 3, 4, every 500ms interval
; tap dodge key (space) every 1s interval 
; click mouse 1 every 200ms interval

; Global variables
global isEnabled := false
global isRotating := false
global lastDodgeTime := 0
global lastMouseClickTime := 0
global defaultKeybinds := {
    Skill1: "1",
    Skill2: "2", 
    Skill3: "3",
    Skill4: "4",
    Skill5: "5",
    Skill6: "6",
    Dodge: "Space",
    ToggleKey: "^+F2"  ; Ctrl+Shift+F2
}

; Create GUI
MyGui := Gui("+AlwaysOnTop", "Auto Sorcery")
MyGui.SetFont("s10")

; Add skill hotkey inputs
MyGui.Add("Text",, "Skill 1:")
skill1Input := MyGui.Add("Hotkey", "w100", defaultKeybinds.Skill1)

MyGui.Add("Text", "x10 y+10", "Skill 2:")
skill2Input := MyGui.Add("Hotkey", "w100", defaultKeybinds.Skill2)

MyGui.Add("Text", "x10 y+10", "Skill 3:")
skill3Input := MyGui.Add("Hotkey", "w100", defaultKeybinds.Skill3)

MyGui.Add("Text", "x10 y+10", "Skill 4:")
skill4Input := MyGui.Add("Hotkey", "w100", defaultKeybinds.Skill4)

MyGui.Add("Text", "x10 y+10", "Skill 5:")
skill5Input := MyGui.Add("Hotkey", "w100", defaultKeybinds.Skill5)

MyGui.Add("Text", "x10 y+10", "Skill 6:")
skill6Input := MyGui.Add("Hotkey", "w100", defaultKeybinds.Skill6)

MyGui.Add("Text", "x10 y+10", "Dodge:")
dodgeInput := MyGui.Add("Hotkey", "w100", defaultKeybinds.Dodge)

MyGui.Add("Text", "x10 y+10", "Toggle Key:")
toggleInput := MyGui.Add("Hotkey", "w100", defaultKeybinds.ToggleKey)

; Add interval input
MyGui.Add("Text", "x10 y+10", "Cast Interval (ms):")
intervalInput := MyGui.Add("Edit", "w100", "100")  ; Default to 100ms

; Add buttons
MyGui.Add("Button", "x10 y+20 w100", "Activate").OnEvent("Click", ActivateScript)
MyGui.Add("Button", "x+10 w100", "Exit").OnEvent("Click", (*) => ExitApp())

; Show GUI
MyGui.Show()

; Activate script function
ActivateScript(*) {
    global isEnabled := true
    
    ; Get current hotkey values
    keys := {
        Skill1: skill1Input.Value,
        Skill2: skill2Input.Value,
        Skill3: skill3Input.Value,
        Skill4: skill4Input.Value,
        Skill5: skill5Input.Value,
        Skill6: skill6Input.Value,
        Dodge: dodgeInput.Value
    }
    
    interval := Integer(intervalInput.Value)
    
    ; Set up toggle hotkey
    Hotkey toggleInput.Value, ToggleScript
    
    ; Set up F1 rotation hotkey (with dodge)
    Hotkey "F1", (*) => SkillDodgeRotation(keys, interval)
    
    ; Set up F3 rotation hotkey (skills only)
    Hotkey "F3", (*) => SkillOnlyRotation(keys, interval)
    
    ; Minimize GUI
    MyGui.Hide()
    
    ; Show activation message
    ToolTip "Script activated! Press " toggleInput.Value " to toggle, F2 for full rotation, or F3 for skills only"
    SetTimer () => ToolTip(), -2000
}

; Toggle script function
ToggleScript(*) {
    global isEnabled := !isEnabled
    global isRotating := false  ; Stop rotation when toggling script
    status := isEnabled ? "enabled" : "disabled"
    ToolTip "Script " status
    SetTimer () => ToolTip(), -1000
}

; Skill rotation function
SkillDodgeRotation(keys, interval) {
    global isEnabled
    global isRotating
    
    if !isEnabled
        return
        
    isRotating := !isRotating
    
    if isRotating {
        ToolTip "Rotation started"
        SetTimer () => ToolTip(), -1000
        
        ; Start the rotation immediately
        RunRotation(keys, interval)
        ; Start independent timers for dodge and mouse click
        SetTimer () => RunDodge(keys), 500
        ; SetTimer () => RunMouseClick(), 100
        ; Start Skill 6 rapid casting
        SetTimer () => RunSkill6(keys), 100
    } else {
        ToolTip "Rotation stopped"
        SetTimer () => ToolTip(), -1000
        ; Stop all timers
        SetTimer () => RunRotation(keys, interval), 0
        SetTimer () => RunDodge(keys), 0
        ; SetTimer () => RunMouseClick(), 0
        SetTimer () => RunSkill6(keys), 0
    }
}

RunRotation(keys, interval) {
    global isRotating
    global isEnabled
    
    if !(isRotating && isEnabled)
        return
        
    ; Cast skills in sequence
    Send "{" keys.Skill1 "}"
    Sleep interval
    
    Send "{" keys.Skill2 "}"
    Sleep interval
    
    Send "{" keys.Skill3 "}"
    Sleep interval
    
    Send "{" keys.Skill4 "}"
    Sleep interval

    Send "{" keys.Skill5 "}"
    Sleep interval

    if (isRotating && isEnabled)
        SetTimer () => RunRotation(keys, interval), -interval  ; Schedule next rotation
}

; Separate function for Skill 6 rapid casting
RunSkill6(keys) {
    global isRotating
    global isEnabled
    
    if !(isRotating && isEnabled)
        return
        
    Send "{" keys.Skill6 "}"
}

RunDodge(keys) {
    global isRotating
    global isEnabled
    
    if !(isRotating && isEnabled)
        return
        
    Send "{" keys.Dodge " down}"
    Sleep 50
    Send "{" keys.Dodge " up}"
    Sleep 20
}

RunMouseClick() {
    global isRotating
    global isEnabled
    
    if !(isRotating && isEnabled)
        return
        
    Send "{LButton down}"
    Sleep 30
    Send "{LButton up}"
    Sleep 20
}

; Skill only rotation function (no dodge or mouse click)
SkillOnlyRotation(keys, interval) {
    global isEnabled
    global isRotating
    
    if !isEnabled
        return
        
    isRotating := !isRotating
    
    if isRotating {
        ToolTip "Skill rotation started (F2)"
        SetTimer () => ToolTip(), -1000
        
        ; Start the rotation immediately
        RunRotation(keys, interval)
        ; Start Skill 6 rapid casting
        SetTimer () => RunSkill6(keys), 100
    } else {
        ToolTip "Skill rotation stopped"
        SetTimer () => ToolTip(), -1000
        ; Stop rotation timer
        SetTimer () => RunRotation(keys, interval), 0
        SetTimer () => RunSkill6(keys), 0
    }
}