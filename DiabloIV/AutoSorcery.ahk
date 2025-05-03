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
    ToggleKey: "^+F1"  ; Change from "^!z" to "^+F1" (Ctrl+Shift+F1)
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
intervalInput := MyGui.Add("Edit", "w100", "500")  ; Default to 500ms

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
    
    ; Set up rotation hotkey (F1 instead of Middle mouse button)
    Hotkey "F1", (*) => SkillRotation(keys, interval)
    
    ; Minimize GUI
    MyGui.Hide()
    
    ; Show activation message
    ToolTip "Script activated! Press " toggleInput.Value " to toggle or F1 to start rotation"
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
SkillRotation(keys, interval) {
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
        SetTimer () => RunDodge(keys), 1000
        SetTimer () => RunMouseClick(), 200
    } else {
        ToolTip "Rotation stopped"
        SetTimer () => ToolTip(), -1000
        ; Stop all timers
        SetTimer RunRotation, 0
        SetTimer RunDodge, 0
        SetTimer RunMouseClick, 0
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
    
    if (isRotating && isEnabled)
        SetTimer () => RunRotation(keys, interval), -interval  ; Schedule next rotation
}

RunDodge(keys) {
    global isRotating
    global isEnabled
    
    if !(isRotating && isEnabled)
        return
        
    Send "{" keys.Dodge "}"
}

RunMouseClick() {
    global isRotating
    global isEnabled
    
    if !(isRotating && isEnabled)
        return
        
    Send "{LButton down}"
    Sleep 50
    Send "{LButton up}"
    Sleep 50
}