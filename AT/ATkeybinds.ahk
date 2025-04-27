#Requires AutoHotkey v2.0

; Define default keybinds
defaultKeybinds := {NormalAttack: "C", Dodge: "Space", Skill1: "1", Skill2: "2", Skill3: "3", Skill4: "4", Skill5: "5", ToggleKey: "^+F1"}

; Global toggle state - start disabled
global isEnabled := false

; Load keybinds from config.ini or use defaults
configFile := A_ScriptDir "\config.ini"
keybinds := LoadKeybinds(configFile, defaultKeybinds)

; Create GUI for assigning keybinds
MyGui := Gui()
MyGui.Add("Text", "x10 y10", "Normal Attack:")
normalAttackInput := MyGui.Add("Hotkey", "x120 y10 w100", keybinds.NormalAttack)
MyGui.Add("Text", "x230 y10 w300", "Basic attack key")
MyGui.Add("Text", "x10 y40", "Dodge:")
dodgeInput := MyGui.Add("Hotkey", "x120 y40 w100", keybinds.Dodge)
MyGui.Add("Text", "x230 y40 w300", "Basic dodge key")

; Add skill type keybinds
MyGui.Add("Text", "x10 y70", "Skill Type 1:")
skill1Input := MyGui.Add("Hotkey", "x120 y70 w100", keybinds.Skill1)
MyGui.Add("Text", "x230 y70 w300", "Normal Attack once, hold attack 0.5s, then 8 repeats")
MyGui.Add("Text", "x10 y100", "Skill Type 2:")
skill2Input := MyGui.Add("Hotkey", "x120 y100 w100", keybinds.Skill2)
MyGui.Add("Text", "x230 y100 w300", "Normal Attack repeat 8 times")
MyGui.Add("Text", "x10 y130", "Skill Type 3:")
skill3Input := MyGui.Add("Hotkey", "x120 y130 w100", keybinds.Skill3)
MyGui.Add("Text", "x230 y130 w300", "Hold Attack (0.5s) to charge and release")
MyGui.Add("Text", "x10 y160", "Skill Type 4:")
skill4Input := MyGui.Add("Hotkey", "x120 y160 w100", keybinds.Skill4)
MyGui.Add("Text", "x230 y160 w300", "Hold Dodge (0.5s) to charge and release")
MyGui.Add("Text", "x10 y190", "Skill Type 5:")
skill5Input := MyGui.Add("Hotkey", "x120 y190 w100", keybinds.Skill5)
MyGui.Add("Text", "x230 y190 w300", "Tap Dodge, then Attack")

; Add toggle keybind
MyGui.Add("Text", "x10 y220", "Toggle Key:")
toggleInput := MyGui.Add("Hotkey", "x120 y220 w100", keybinds.ToggleKey)
MyGui.Add("Text", "x230 y220 w300", "Toggle all keybinds on/off (default: Ctrl+Shift+F1)")

; Add Activate and Exit buttons
MyGui.Add("Button", "x10 y250 w100", "Activate").OnEvent("Click", ActivateAndSave)
MyGui.Add("Button", "x120 y250 w100", "Exit").OnEvent("Click", (*) => ExitApp())

; Create tray menu
; A_TrayMenu.Delete  ; Remove default menu items
A_TrayMenu.Add("Show Window", ShowWindow)
; A_TrayMenu.Add("Exit", (*) => ExitApp())

MyGui.Show()

; Function to show window from tray
ShowWindow(*) {
    MyGui.Show()
}

; Function to activate keybinds and save config
ActivateAndSave(*) {
    global isEnabled, keybinds
    
    ; Save current input values to keybinds
    keybinds.NormalAttack := normalAttackInput.Value
    keybinds.Dodge := dodgeInput.Value
    keybinds.Skill1 := skill1Input.Value
    keybinds.Skill2 := skill2Input.Value
    keybinds.Skill3 := skill3Input.Value
    keybinds.Skill4 := skill4Input.Value
    keybinds.Skill5 := skill5Input.Value
    keybinds.ToggleKey := toggleInput.Value
    
    ; Save to config file
    SaveKeybinds(configFile, keybinds.NormalAttack, keybinds.Dodge, keybinds.Skill1, keybinds.Skill2, keybinds.Skill3, keybinds.Skill4, keybinds.Skill5, keybinds.ToggleKey)
    
    ; Enable keybinds
    isEnabled := true
    
    ; Set up hotkeys
    SetupHotkeys()
    
    ; Show success message and minimize
    ToolTip("Keybinds activated!")
    SetTimer () => ToolTip(), -1000
    MyGui.Hide()
}

; Function to set up all hotkeys
SetupHotkeys() {
    ; Set up toggle hotkey (always active after activation)
    Hotkey(keybinds.ToggleKey, ToggleKeybinds)
    
    ; Set up skill hotkeys
    Hotkey(keybinds.Skill1, SkillType1)
    Hotkey(keybinds.Skill2, SkillType2)
    Hotkey(keybinds.Skill3, SkillType3)
    Hotkey(keybinds.Skill4, SkillType4)
    Hotkey(keybinds.Skill5, SkillType5)
}

; Global toggle hotkey
ToggleKeybinds(*) {
    global isEnabled
    isEnabled := !isEnabled
    status := isEnabled ? "enabled" : "disabled"
    ToolTip("Keybinds " status)
    SetTimer () => ToolTip(), -1000
}

; Skill Type 1: Normal Attack once, hold attack 0.5s, then 5 repeats
SkillType1(*) {
    if !isEnabled
        return
    ; First normal attack
    Send "{Blind}{" keybinds.NormalAttack " down}"
    Sleep 50
    Send "{Blind}{" keybinds.NormalAttack " up}"
    Sleep 50
    ; Hold attack for 0.5s
    Send "{Blind}{" keybinds.NormalAttack " down}"
    Sleep 350
    Send "{Blind}{" keybinds.NormalAttack " up}"
    Sleep 50
    ; Then 8 quick repeats
    Loop 8 {
        Send "{Blind}{" keybinds.NormalAttack " down}"
        Sleep 50
        Send "{Blind}{" keybinds.NormalAttack " up}"
        Sleep 250
    }
}

; Skill Type 2: Normal Attack repeat 8 times
SkillType2(*) {
    if !isEnabled
        return
    Loop 8 {
        Send "{Blind}{" keybinds.NormalAttack " down}"
        Sleep 50
        Send "{Blind}{" keybinds.NormalAttack " up}"
        Sleep 250
    }
}

; Skill Type 3: Hold Attack (0.5s) to charge and release
SkillType3(*) {
    if !isEnabled
        return
    Send "{Blind}{" keybinds.NormalAttack " down}"
    Sleep 500
    Send "{Blind}{" keybinds.NormalAttack " up}"
}

; Skill Type 4: Hold Dodge (0.5s) to charge and release
SkillType4(*) {
    if !isEnabled
        return
    Send "{Blind}{" keybinds.Dodge " down}"
    Sleep 500
    Send "{Blind}{" keybinds.Dodge " up}"
}

; Skill Type 5: Tap Dodge, then Attack
SkillType5(*) {
    if !isEnabled
        return
    Send "{Blind}{" keybinds.Dodge " down}"
    Sleep 50
    Send "{Blind}{" keybinds.Dodge " up}"
    Sleep 150
    Send "{Blind}{" keybinds.NormalAttack " down}"
    Sleep 50
    Send "{Blind}{" keybinds.NormalAttack " up}"
}

; Function to load keybinds from config.ini
LoadKeybinds(file, defaults) {
    if !FileExist(file)
        return defaults
    
    ini := Map()
    Loop Read, file {
        if (A_LoopReadLine = "" || SubStr(A_LoopReadLine, 1, 1) = ";")
            continue
        parts := StrSplit(A_LoopReadLine, "=", " `t")
        if (parts.Length >= 2) {
            key := Trim(parts[1])
            value := Trim(parts[2])
            ini.Set(key, value)
        }
    }
    
    return {
        NormalAttack: ini.Has("NormalAttack") ? ini.Get("NormalAttack") : defaults.NormalAttack,
        Dodge: ini.Has("Dodge") ? ini.Get("Dodge") : defaults.Dodge,
        Skill1: ini.Has("Skill1") ? ini.Get("Skill1") : defaults.Skill1,
        Skill2: ini.Has("Skill2") ? ini.Get("Skill2") : defaults.Skill2,
        Skill3: ini.Has("Skill3") ? ini.Get("Skill3") : defaults.Skill3,
        Skill4: ini.Has("Skill4") ? ini.Get("Skill4") : defaults.Skill4,
        Skill5: ini.Has("Skill5") ? ini.Get("Skill5") : defaults.Skill5,
        ToggleKey: ini.Has("ToggleKey") ? ini.Get("ToggleKey") : defaults.ToggleKey
    }
}

; Function to save keybinds to config.ini
SaveKeybinds(file, normalAttack, dodge, skill1, skill2, skill3, skill4, skill5, toggleKey) {
    if FileExist(file) {
        FileDelete(file)
    }
    FileAppend("NormalAttack=" normalAttack "`n", file)
    FileAppend("Dodge=" dodge "`n", file)
    FileAppend("Skill1=" skill1 "`n", file)
    FileAppend("Skill2=" skill2 "`n", file)
    FileAppend("Skill3=" skill3 "`n", file)
    FileAppend("Skill4=" skill4 "`n", file)
    FileAppend("Skill5=" skill5 "`n", file)
    FileAppend("ToggleKey=" toggleKey "`n", file)
}