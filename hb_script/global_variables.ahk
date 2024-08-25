; Global variables
Global ConfigFile := "hb_script_config.ini"
Global activeMenuManager := ""  ; Global variable to store the active MenuManager instance
Global WinTitle := "Helbreath Olympia 18.2" ; Title of the window
Global bShowGUI := false
Global bDebugMode := false
Global CastingEffectSpell := ""
Global Effects := []

; Global variables from config
Global SpellHorizontalPos := IniRead(ConfigFile, "Coords", "SpellHorizontalPos")
Global ScreenResolution := StrSplit(IniRead(ConfigFile, "Coords", "ScreenResolution"), ",")
Global ScriptActiveIndicatorPos := StrSplit(IniRead(ConfigFile, "Coords", "ScriptActiveIndicatorPos"), ",")
Global CoordsIndicatorPos := StrSplit(IniRead(ConfigFile, "Coords", "CoordsIndicatorPos"), ",")

Global AutoPotHealthIndicatorPos := StrSplit(IniRead(ConfigFile, "Coords", "AutoPotHealthIndicatorPos"), ",")
Global StartAutoPotHealthPos := StrSplit(IniRead(ConfigFile, "Coords", "StartAutoPotHealthPos"), ",")
Global HighHealthPos := StrSplit(IniRead(ConfigFile, "Coords", "HighHealthPos"), ",")

Global AutoPotManaIndicatorPos := StrSplit(IniRead(ConfigFile, "Coords", "AutoPotManaIndicatorPos"), ",")
Global StartAutoPotManaPos := StrSplit(IniRead(ConfigFile, "Coords", "StartAutoPotManaPos"), ",")
Global HighManaPos := StrSplit(IniRead(ConfigFile, "Coords", "HighManaPos"), ",")

; Global AutoPot()
Global bTryHPPotting := true
Global bTryManaPotting := true