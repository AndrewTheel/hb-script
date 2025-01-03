#Requires AutoHotkey v2.0
#SingleInstance Force  ; Prevents multiple instances of the same script from runnin

Persistent

; Path to the main script
MainScriptPath := "poe2_script.ahk"

; Launch the main script
!J:: Run(MainScriptPath)
