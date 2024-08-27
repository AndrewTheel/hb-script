; Global variables
Global ConfigFile := "hb_script_config_andrew.ini"

; Variouis Script Variables
Global activeMenuManager := ""  ; Global variable to store the active MenuManager instance
Global WinTitle := "Helbreath Olympia 18.2" ; Title of the window
Global bShowGUI := false
Global bDebugMode := false
Global CastingEffectSpell := ""
Global Effects := []
Global stopFlag := false  ; Flag to stop loops
Global SquarePercentageX := 4
Global SquarePercentageY := 5.35

Global SpellHorizontalPos := 62.5
Global ScriptActiveIndicatorPos := [6.9,92.9166]
Global CoordsIndicatorPos := [35.0,95.1]
Global AutoPotHealthIndicatorPos := [10.31,93.0]
Global AutoPotManaIndicatorPos := [10.31,96.7]

; From ConfigFile
Global ScreenResolution := StrSplit(IniRead(ConfigFile, "Coords", "ScreenResolution"), ",")

; Global AutoPot()
Global bTryHPPotting := true
Global bTryManaPotting := true
Global AutoPotLifeAtPercent := IniRead(ConfigFile, "AutoPot", "AutoPotLifeAtPercent")
Global AutoPotManaAtPercent := IniRead(ConfigFile, "AutoPot", "AutoPotManaAtPercent")