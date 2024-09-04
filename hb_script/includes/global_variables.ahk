; Global variables
Global ConfigFile := "hb_script_config_andrew.ini"

; Variouis Script Variables
Global gGUI := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000") ;Disabled
gGUI.BackColor := "EEAA99" ; Makes the GUI transparent
WinSetTransColor(gGUI.BackColor, gGUI) ; " 150" Makes the GUI transparent

Global activeMenuManager := ""  ; Global variable to store the active MenuManager instance
Global WinTitle := "Helbreath Olympia 18.2" ; Title of the window
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

; Gameplay 

; From ConfigFile
Global ScreenResolution := StrSplit(IniRead(ConfigFile, "Coords", "ScreenResolution"), ",")

; Global AutoPot()
Global bTryHPPotting := true
Global bTryManaPotting := true
Global AutoPotLifeAtPercent := IniRead(ConfigFile, "AutoPot", "AutoPotLifeAtPercent")
Global AutoPotManaAtPercent := IniRead(ConfigFile, "AutoPot", "AutoPotManaAtPercent")

; Define the global array of inventory slot positions
Global InventorySlotPos := []  ; Initialize as an empty array

; Populate the global array with coordinates
InventorySlotPos.Push([CtPixel(71.125, "X"), CtPixel(78.333, "Y")]) ; Item 1
InventorySlotPos.Push([CtPixel(74.75, "X"), CtPixel(78.333, "Y")])  ; Item 2
InventorySlotPos.Push([CtPixel(78.375, "X"), CtPixel(78.333, "Y")]) ; Item 3
InventorySlotPos.Push([CtPixel(82, "X"), CtPixel(78.333, "Y")])     ; Item 4
InventorySlotPos.Push([CtPixel(85.6255, "X"), CtPixel(78.333, "Y")]) ; Item 5
InventorySlotPos.Push([CtPixel(89.25, "X"), CtPixel(78.333, "Y")])  ; Item 6
InventorySlotPos.Push([CtPixel(92.875, "X"), CtPixel(78.333, "Y")]) ; Item 7
InventorySlotPos.Push([CtPixel(92.875, "X"), CtPixel(67.333, "Y")])  ; Item 8
InventorySlotPos.Push([CtPixel(89.25, "X"), CtPixel(67.333, "Y")])  ; Item 9
InventorySlotPos.Push([CtPixel(85.6255, "X"), CtPixel(67.333, "Y")])  ; Item 10
