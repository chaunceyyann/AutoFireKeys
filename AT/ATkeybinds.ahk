#Requires AutoHotkey v2.0

; Define default keybinds
defaultKeybinds := {NormalAttack: "C", Dodge: "Space"}

; Load keybinds from config.ini or use defaults
configFile := A_ScriptDir "\config.ini"
keybinds := LoadKeybinds(configFile, defaultKeybinds)

; Create GUI for assigning keybinds
MyGui := Gui()
MyGui.Add("Text", "x10 y10", "Normal Attack:")
normalAttackInput := MyGui.Add("Edit", "x120 y10 w100", keybinds.NormalAttack)
MyGui.Add("Text", "x10 y40", "Dodge:")
dodgeInput := MyGui.Add("Edit", "x120 y40 w100", keybinds.Dodge)
MyGui.Add("Button", "x10 y80 w100", "Save").OnEvent("Click", (*) => SaveKeybinds(configFile, normalAttackInput.Value, dodgeInput.Value))
MyGui.Add("Button", "x120 y80 w100", "Exit").OnEvent("Click", (*) => ExitApp())
MyGui.Show()

; Skill Type 1: Hold Attack (0.5s), then 4 repeats
Hotkey(keybinds.NormalAttack, SkillType1)

SkillType1(*) {
    Send "{Blind}{" keybinds.NormalAttack " down}"
    Sleep 500
    Send "{Blind}{" keybinds.NormalAttack " up}"
    Loop 4 {
        Send "{Blind}{" keybinds.NormalAttack "}"
        Sleep 100
    }
}

; Skill Type 2: Normal Attack repeat 5 times
Hotkey("*" keybinds.NormalAttack, SkillType2)

SkillType2(*) {
    Loop 5 {
        Send "{Blind}{" keybinds.NormalAttack "}"
        Sleep 100
    }
}

; Skill Type 3: Hold Attack (0.2s) to charge and release
Hotkey("+*" keybinds.NormalAttack, SkillType3)

SkillType3(*) {
    Send "{Blind}{" keybinds.NormalAttack " down}"
    Sleep 200
    Send "{Blind}{" keybinds.NormalAttack " up}"
}

; Skill Type 4: Hold Dodge (0.2s) to charge and release
Hotkey("+*" keybinds.Dodge, SkillType4)

SkillType4(*) {
    Send "{Blind}{" keybinds.Dodge " down}"
    Sleep 200
    Send "{Blind}{" keybinds.Dodge " up}"
}

; Skill Type 5: Tap Dodge, then Attack
Hotkey(keybinds.Dodge, SkillType5)

SkillType5(*) {
    Send "{Blind}{" keybinds.Dodge "}"
    Sleep 100
    Send "{Blind}{" keybinds.NormalAttack "}"
}

; Function to load keybinds from config.ini
LoadKeybinds(file, defaults) {
    if !FileExist(file)
        return defaults
    ini := {}
    Loop Read, file {
        line := StrSplit(A_LoopReadLine, "=")
        ini[line[1]] := line[2]
    }
    return {NormalAttack: ini.HasKey("NormalAttack") ? ini.NormalAttack : defaults.NormalAttack
           ,Dodge: ini.HasKey("Dodge") ? ini.Dodge : defaults.Dodge}
}

; Function to save keybinds to config.ini
SaveKeybinds(file, normalAttack, dodge) {
    if FileExist(file) {
        FileDelete(file)
    }
    FileAppend("NormalAttack=" normalAttack "`n", file)
    FileAppend("Dodge=" dodge "`n", file)
    MsgBox("Keybinds saved!")
}