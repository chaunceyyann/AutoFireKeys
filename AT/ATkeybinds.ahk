#Requires AutoHotkey v2.0

; This is a helper to get AT weird skill keybinds to be normal 1, 2, 3
; Noraml Attack: C
; Dodge: Space
; Skill Type 1: Hold Attack(0.5s), then 4 repeat
; Skill Type 2: Normal Attack repeat 5 times
; Skill Type 3: Hold Attack(0.2s) to charge and Release
; Skill Type 4: Hold Dodge(0.2s) to charge and Release
; Skill Type 5: Tap Dodge, then Attack

; Create UI for assigning keybinds to skills
; Create a GUI window
Gui, New, +Resize +MinSize
Gui, Add, Text, , Assign Keybinds to Skills
Gui, Add, Text, , Skill Type 1  