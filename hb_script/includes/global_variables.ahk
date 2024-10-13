; Script config
Global ConfigFile := "hb_script_config_andrew.ini"

; GUI variables
Global gGUI := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000") ;Disabled
gGUI.BackColor := "EEAA99" ; Makes the GUI transparent
WinSetTransColor(gGUI.BackColor, gGUI) ; " 150" Makes the GUI transparent
Global activeMenuManager := ""  ; Global variable to store the active MenuManager instance

; Script variables
Global WinTitle := "Helbreath Olympia 18.2" ; Title of the window
Global bDebugMode := false
Global CastingEffectSpell := ""
Global Effects := []
Global stopFlag := false  ; Flag to stop loops
Global SquarePercentageX := 4
Global SquarePercentageY := 5.35
Global SpellHorizontalPos := 62.5

; Auto Trade Rep
Global bAutoTradeRepping := false 

; From ConfigFile
Global ScreenResolution := StrSplit(IniRead(ConfigFile, "Coords", "ScreenResolution"), ",")
Global CenterX := ScreenResolution[1] / 2
Global CenterY := ScreenResolution[2] / 2

; Calculate pixel offsets for square positions
GridSquaresX := 25
GridSquaresY := 17
XOffset := CtPixel(SquarePercentageX, "X")
YOffset := CtPixel(SquarePercentageY, "Y")
XOffsets := [-XOffset, 0, XOffset]
YOffsets := [-YOffset, 0, YOffset]
directions := Object() ; Define coordinates for each adjacent square using valid object literal syntax
directions.RightDown := [CenterX + XOffsets[3], CenterY + YOffsets[3]]
directions.LeftDown := [CenterX + XOffsets[1], CenterY + YOffsets[3]]
directions.LeftUp := [CenterX + XOffsets[1], CenterY + YOffsets[1]]
directions.RightUp := [CenterX + XOffsets[3], CenterY + YOffsets[1]]
directions.Up := [CenterX + XOffsets[2], CenterY + (YOffsets[1])]
directions.Down := [CenterX + XOffsets[2], CenterY + YOffsets[3]]
directions.Left := [CenterX + XOffsets[1], CenterY + YOffsets[2]]
directions.Right := [CenterX + XOffsets[3], CenterY + YOffsets[2]]

; Global AutoPot()
Global bTryHPPotting := true
Global bTryManaPotting := true
Global AutoPotLifeAtPercent := IniRead(ConfigFile, "AutoPot", "AutoPotLifeAtPercent")
Global AutoPotManaAtPercent := IniRead(ConfigFile, "AutoPot", "AutoPotManaAtPercent")

; Define the global array of inventory slot positions
Global InventorySlotPos := []  ; Initialize as an empty array
Global DefaultItemLandingPos := [CtPixel(71.6, "X"),CtPixel(61.9, "Y")]

; Player and Game Variables
Global playerGameCoords := [0,0]
GameCoords := [0,0]

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
InventorySlotPos.Push([CtPixel(82.001, "X"), CtPixel(67.333, "Y")])  ; Item 11
InventorySlotPos.Push([CtPixel(78.3765, "X"), CtPixel(67.333, "Y")])  ; Item 12
InventorySlotPos.Push([CtPixel(74.752, "X"), CtPixel(67.333, "Y")])  ; Item 13
InventorySlotPos.Push([CtPixel(71.1275, "X"), CtPixel(67.333, "Y")])  ; Item 14


