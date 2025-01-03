; Script config
Global ConfigFile := "cfg\poe2_script_config_andrew.ini"

; GUI variables
Global gGUI := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000") ;Disabled
gGUI.BackColor := "EEAA99" ; Makes the GUI transparent
WinSetTransColor(gGUI.BackColor, gGUI) ; " 150" Makes the GUI transparent
Global activeMenuManager := ""  ; Global variable to store the active MenuManager instance

; Script variables
Global WinTitle := "Path of Exile 2" ; Title of the window
Global bDebugMode := false
Global CastingEffectSpell := ""
Global Effects := []
Global stopFlag := false  ; Flag to stop loops

; From ConfigFile
;Global ScreenResolution := StrSplit(IniRead(ConfigFile, "Coords", "ScreenResolution"), ",")
;Global CenterX := ScreenResolution[1] / 2
;Global CenterY := ScreenResolution[2] / 2