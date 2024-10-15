#Requires AutoHotkey v2.0
#SingleInstance Force  ; Prevents multiple instances of the same script from runnin

Persistent

; Path to the other script
MainScriptPath := "hb_script.ahk"

; Launch the other script
!J:: Run(MainScriptPath)