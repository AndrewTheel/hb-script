#Requires AutoHotkey v2.0

; AHK settings
CoordMode "Mouse", "Client" ; Client / Window / Screen (Client might be best)
CoordMode "ToolTip", "Client"
SendMode "Event"

; Global variables
Global ConfigFile := "hb_script_config.ini"
Global activeMenuManager := ""  ; Global variable to store the active MenuManager instance
Global WinTitle := "Helbreath Olympia 18.2" ; Title of the window
Global bIsCursorHidden := false
Global bShowGUI := false
Global bDebugMode := false
/*
Global ScreenResolution
Global SpellHorizontalPos
Global ScriptActiveIndicatorPos
Global CoordsIndicatorPos
Global AutoPotHealthIndicatorPos
Global AutoPotManaIndicatorPos
Global StartAutoPotHealthPos
Global StartAutoPotManaPos
Global HighHealthPos
Global HighManaPos
*/

; Global variables from config
SpellHorizontalPos := IniRead(ConfigFile, "Settings", "SpellHorizontalPos")
ScreenResolution := StrSplit(IniRead(ConfigFile, "Settings", "ScreenResolution"), ",")
ScriptActiveIndicatorPos := StrSplit(IniRead(ConfigFile, "Settings", "ScriptActiveIndicatorPos"), ",")
CoordsIndicatorPos := StrSplit(IniRead(ConfigFile, "Settings", "CoordsIndicatorPos"), ",")

AutoPotHealthIndicatorPos := StrSplit(IniRead(ConfigFile, "Settings", "AutoPotHealthIndicatorPos"), ",")
StartAutoPotHealthPos := StrSplit(IniRead(ConfigFile, "Settings", "StartAutoPotHealthPos"), ",")
HighHealthPos := StrSplit(IniRead(ConfigFile, "Settings", "HighHealthPos"), ",")

AutoPotManaIndicatorPos := StrSplit(IniRead(ConfigFile, "Settings", "AutoPotManaIndicatorPos"), ",")
StartAutoPotManaPos := StrSplit(IniRead(ConfigFile, "Settings", "StartAutoPotManaPos"), ",")
HighManaPos := StrSplit(IniRead(ConfigFile, "Settings", "HighManaPos"), ",")

; AHK initiatives
WinWaitActive WinTitle ;Script waits until HB window is active/front
HotIfWinActive WinTitle ;Attempt to make Hotkeys only work inside the HB window

; F1 should only be used to suspend or unsuspend the script, the * designates this (aka it prevents the HB F1 help menu from popping up)
#SuspendExempt
*F1:: ; Toggles suspend of the script
{
	if A_IsSuspended
		Suspend false
	else
		Suspend true
}

!K::ExitApp ; Kill the app (useful if mouse gets locked or program is not responding)
#SuspendExempt false

; ══════════════════════════════════════════════════════  Optional Systems ══════════════════════════════════════════════════════ ;

if (IniRead(ConfigFile, "Settings", "CheckForMinimize") == "true")
{
	CheckForMinimize()
}

if (IniRead(ConfigFile, "Settings", "UseAutoPotting") == "true")
{
	SetTimer(AutoPot, 100)
}

if (IniRead(ConfigFile, "Settings", "DebugMode") == "true")
{
	bDebugMode := true
}

if (IniRead(ConfigFile, "Settings", "ShowGUI") == "true")
{
	bShowGUI := true
}

if (IniRead(ConfigFile, "Settings", "UnbindKeys") == "true")
{
	UnbindKeys := HotkeyUnbindClass() ; Obj instance that unbinds a bunch of keys by setting hotkeys to do nothing
}

; ══════════════════════════════════════════════════════  Classes ══════════════════════════════════════════════════════ ;

class HotkeyUnbindClass {
	; Unbind keys to prevent unintended typing during combat.
	; Rebind keys for spells (e.g., q to a spell) later in script or from config.
	; Unbind shift+keys to avoid issues with sprint and spell casting.
	; Caution: Binding shift+keys while sprinting may interrupt your run.
	; Note: Disabled hotkeys must be re-enabled (e.g., Hotkey("1", "Off")) when defined as such "Hotkey::".

    keys := ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "+1", "2", "+2", "3", "+3", "4", "+4", "5", "+5", "6", "+6", "7", "+7", "8", "+8", "9", "+9", "0", "+0", "-", "=", "Space", ",", ".", "/", "'", "[", "]", "\", "+-", "{", "}", "+=", "+q", "+w", "+e", "+r", "+t", "+y", "+u", "+i", "+o", "+p", "+a", "+s", "+d", "+f", "+g", "+h", "+j", "+k", "+l", "+z", "+x", "+c", "+v", "+b", "+n", "+m", "+Space", "+CapsLock", "+,", "+.", "+/", ";", "+;", "+'", "+[", "+]", "+\", "Volume_Up", "Volume_Down", "Volume_Mute"]

    __New() {
        ; Assign hotkeys using a loop
        for key in this.keys
		{
			Hotkey(key, this.DoNothing.Bind(this))
		}
    }

	DoNothing(*) {
	}
}

class SpellInfo {
	__Initialize() { ; Initialize instance variables *Important: will flag errors if omitted* TODO: perhaps these just need to be class variables
		MagicPage := ""
		YCoord := ""
		HotKeyName := ""
	}

    __New(aMagicPage, aCoord, aHK) { ; Constructor
        this.MagicPage := aMagicPage
        this.YCoord := aCoord
		this.HotKeyName := aHK

		Hotkey(this.HotKeyName, this.CastSpell.Bind(this)) ; Bind the hotkey so whenever it is struck it calls the CastSPell function
    }

	CastSpell(*) {
		Global SpellHorizontalPos

		if WinActive(WinTitle) ; This supposedly stops the hotkey from working outside of the HB client
		{
			BlockInput true
			MouseGetPos &begin_x, &begin_y ; Get the position of the mouse

			;FixCoords() ; move the mouse to top left and bottom right, then center to debug screen coords
			;MouseClick "right" ; right-click to help ensure cast ready

			if (GetKeyState("LButton", "P")) ; if we are holding down m1, like when we are chasing someone, the cast should interrupt the run so the cast doesn't fail
			{
				Send("{LButton up}")
			}

			Send this.MagicPage ; Open Magic menu tab
			MouseClick "left", SpellHorizontalPos, this.YCoord, 1, 0 ; Click spell coords
			MouseMove begin_x, begin_y ; Move mouse back to original position
			Sleep 50
			BlockInput false

			/* old cast logic
			BlockInput true
			MouseGetPos &begin_x, &begin_y ; Get the position of the mouse
			MouseMove -1000, -1000, 1  ; Move the mouse cursor far to the top left and then some, this resets the apps mouse coords (very useful because otherwise you constantly have to do it manually)
			Send this.MagicPage ; Will open Magic menu tab
			MouseClick "left", 600, this.YCoord, 1, 0 ; Click spell coords
			MouseMove begin_x, begin_y ; Move mouse back to original position
			BlockInput false
			*/
		}
	}
}

class CommandInfo {
	; Member variables
	HotKeyName := ""
	InputCommand := ""

    __New(aKey, aCommand) { ; Constructor
        this.HotKeyName := aKey
        this.InputCommand := aCommand

		try
		{
			Hotkey(this.HotKeyName, this.DoNothing)
		}
		catch ValueError
		{
			return
		}
		else
		{
			if InStr(this.InputCommand, "{")
			{
				Hotkey(this.HotKeyName, this.SendCommand.Bind(this))
			}
			else
			{
				funcRef := %this.InputCommand%.Bind()

				if IsObject(funcRef) && funcRef.HasMethod("Call")
				{
					Hotkey(this.HotKeyName, funcRef) ; .call()
				}
			}
		}
    }

	SendCommand(*) {

		if WinActive(WinTitle) ; This supposedly stops the hotkey from working outside of the HB client
		{
			Send this.InputCommand
		}
	}

	DoNothing(*) {
	}
}

class OptionsMenuManager {
    ; Member variables
    optionsGui := ""  ; Initialize as empty string
	optionMenuLabels := Array()
    optionFunctionNames := Array()

    __New(optionNames, functionNames) { ; Constructor
        ; Validate parameters
        if (optionNames.Length != functionNames.Length || optionNames.Length > 9) {
            MsgBox("Error: optionMenuLabels and optionFunctionNames must have the same number of elements. And not exceed 9")
            return
        }

		for index, optionName in optionNames {
            this.optionMenuLabels.Push(optionName)
            this.optionFunctionNames.Push(functionNames[index])
        }
    }

	; Function to show the dialog
    showOptionsDialog() {
		FixCoords()

        if (this.optionsGui == "")
        {
            this.optionsGui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000", "Select an Option")
            this.optionsGui.BackColor := 0xCCFFFFFF

			for index, optionName in this.optionMenuLabels
            {
				BoundFunc := ObjBindMethod(this, "CallFunction", index)
				btn := this.optionsGui.AddButton("w100 h15 Left", optionName).OnEvent("Click", BoundFunc)
            }

            WinSetTransColor(this.optionsGui.BackColor " 100", this.optionsGui)
            this.optionsGui.Show("x450 y200 NA NoActivate")
        }
        else
        {
            this.DestroyOptionsGUI()
        }
    }

    ; Method to destroy this GUI
    DestroyOptionsGUI() {
		global activeMenuManager

        if IsObject(this.optionsGui)
        {
            this.optionsGui.Destroy()
            this.optionsGui := ""
            Sleep 50
        }

		activeMenuManager := ""
    }

	; Method to call the function by index with validation
    CallFunction(index, *) {
        ; Validate index
        if (index < 1 || index > this.optionFunctionNames.Length || !WinActive(WinTitle))
		{
            return
        }

        funcName := this.optionFunctionNames[index]

        ; Try to call the function and handle any errors
        try {
            %funcName%.Call()
        } catch as e {
            MsgBox("Error: Failed to execute function '" funcName "'.`n" e.Message)
        }

        this.DestroyOptionsGUI()
    }

    ; Method to get the callback function for an option
    GetOptionCallback(n) {
        return this.optionFunctionNames[n]
    }
}

; ══════════════════════════════════════════════════════  Load From Config ══════════════════════════════════════════════════════ ;

LoadSpellsFromConfig() {
	Section := IniRead(ConfigFile, "Spells")

	if (Section)
	{
		Loop Parse, Section, "`n", "`r"
		{
			; Split the line into its components using comma as delimiter
			SplitLine := StrSplit(A_LoopField, ",")

			; Extract individual components (1 is unused as it only helps the user know what they are reassigning)
			SpellCircle := SplitLine[2]
			Coord := SplitLine[3]
			Hk := SplitLine[4]

			; Create a new instance of the SpellInfo class with the extracted components
			SpellInstance := SpellInfo(SpellCircle, Coord, Hk)
		}
	}
}

LoadCommandsFromConfig(SectionName) {
	Section := IniRead(ConfigFile, SectionName)

	if (Section)
	{
		Loop Parse, Section, "`n", "`r"
		{
			; Split the line into its components using comma as delimiter
			SplitLine := StrSplit(A_LoopField, ",")

			; Extract individual components (1 is unused as it only helps the user know what they are reassigning)
			Command := SplitLine[2]
			Key := SplitLine[3]

			CommandInstance := CommandInfo(Key, Command)
		}
	}
}

LoadSpellsFromConfig()
LoadCommandsFromConfig("Script")
LoadCommandsFromConfig("Character")
LoadCommandsFromConfig("Potions")
LoadCommandsFromConfig("Taming")
LoadCommandsFromConfig("Leveling")
LoadCommandsFromConfig("Messages")
LoadCommandsFromConfig("Inventory")
LoadCommandsFromConfig("Other")

; ══════════════════════════════════════════════════════  Systems/Functions ══════════════════════════════════════════════════════ ;

CheckForMinimize() {
	static bMinimizedTipOpen := false

	if (!WinActive(WinTitle))
	{
		if (!bMinimizedTipOpen)
		{
			; Display a prompt dialog box
			MsgBoxResult := MsgBox("Do you want to close the script?",, "YesNo")

			; Check the user's response
			if (MsgBoxResult = "Yes")
				ExitApp()
			else if (MsgBoxResult = "No")
				bMinimizedTipOpen := true
		}
		else
		{
			ToolTip "HB Script is still running!"
		}
	}
	else
	{
		bMinimizedTipOpen := false
	}

	SetTimer(CheckForMinimize, 1000) ;1x a second
}

Global bTryHPPotting := true
Global bTryManaPotting := true

AutoPot() {
	Global bTryHPPotting, bTryManaPotting, StartAutoPotHealthPos, StartAutoPotManaPos, HighHealthPos, HighManaPos

	if WinActive(WinTitle)
	{
		static LowHPDuration := 0
		static LowManaDuration := 0

		ColorHPLowFSA := "0x313131"
		ColorManaLowFSA := "0x424142"

		;ToolTip "HP: " . PixelGetColor(149, 570) . "Mana: " . PixelGetColor(163, 592)
		;A_Clipboard := PixelGetColor(150, 571) . " " . PixelGetColor(163, 592)

		; Check low HP
		if IsColorInRange(StartAutoPotHealthPos[1], StartAutoPotHealthPos[2], ColorHPLowFSA, 35) && IsColorInRange(HighHealthPos[1], HighHealthPos[2], ColorHPLowFSA, 35)
		{
			if (bTryHPPotting)
			{
				Send "{Insert}"
				Sleep 20
			}

			if (LowHPDuration >= 3000) ; Check if we've been at Low HP for a long time (more than 2 seconds)
			{
				bTryHPPotting := false
			}

			LowHPDuration += 100 ;milliseconds
		}
		else
		{
			LowHPDuration := 0
			bTryHPPotting := true
		}

		; Check low Mana
		if IsColorInRange(StartAutoPotManaPos[1], StartAutoPotManaPos[2], ColorManaLowFSA, 35) && IsColorInRange(HighManaPos[1], HighManaPos[2], ColorManaLowFSA, 35)
		{
			if (bTryManaPotting)
			{
				Send "{Delete}"
				Sleep 20
			}

			if (LowManaDuration >= 3000) ; Check if we've been at Low Mana for a long time (more than 2 seconds)
			{
				bTryManaPotting := false
			}

			LowManaDuration += 100 ;milliseconds
		}
		else
		{
			LowManaDuration := 0
			bTryManaPotting := true
		}
	}
}

IsColorInRange(x, y, targetColor, tolerance := 10) {
    ; Get the color of the pixel at (x, y)
    pixelColor := PixelGetColor(x, y, "RGB")

    ; Extract RGB components of the pixel color
    pixelR := (pixelColor >> 16) & 0xFF
    pixelG := (pixelColor >> 8) & 0xFF
    pixelB := pixelColor & 0xFF

    ; Extract RGB components of the target color
    targetR := (targetColor >> 16) & 0xFF
    targetG := (targetColor >> 8) & 0xFF
    targetB := targetColor & 0xFF

    ; Check if the pixel color is within the tolerance range of the target color
    if (Abs(pixelR - targetR) <= tolerance && Abs(pixelG - targetG) <= tolerance && Abs(pixelB - targetB) <= tolerance) {
        return true
    } else {
        return false
    }
}

OptionsMenu(optionNames, optionFunctionNames) {
    global activeMenuManager

    if (activeMenuManager == "") {
        activeMenuManager := OptionsMenuManager(optionNames, optionFunctionNames)
        activeMenuManager.showOptionsDialog()
    } else {
        activeMenuManager.DestroyOptionsGUI()
    }
}

SendTextMessage(str := "") {
	BlockInput true
	Send "{enter}"
	SendText(str)
	Sleep 20
	Send "{enter}"
	BlockInput false
}

FixCoords()
{
	MouseMove -1000, -1000, 1
	Sleep 50
	MouseMove +3000, +3000, 1
	Sleep 50
	MouseMove 400, 300, 1
	Sleep 50
}

; ══════════════════════════════════════════════════════  Hotkeys and Game Actions ══════════════════════════════════════════════════════ ;

#SuspendExempt
ToggleSuspendScript(*) => Send("{F1}")
SuspendScript(*) => Suspend(true)
ResumeScript(*) => Suspend(false)
#SuspendExempt false

DoNothing(*) => { }
ToggleMap(*) => Send("^m")
OpenBag(*) => Send("{f6}")
ToggleRunWalk(*) => Send("^r")
OpenOptions(*) => Send("{F12}")

RecruitMessage(*) => SendTextMessage("~COPS recruiting, whisper me")
FreezeMessage(*) => SendTextMessage("This is the police! Freeze!!!")
OnTheGroundMessage(*) => SendTextMessage("Get down on the ground!")
DontMoveMessage(*) => SendTextMessage("Don't move!")
UnderArrestMessage(*) => SendTextMessage("You're under arrest.")
SuspectFleeingMessage(*) => SendTextMessage("Suspect is fleeing!")
ShowHandsMessage(*) => SendTextMessage("Show me your hands!")
ShotsFiredMessage(*) => SendTextMessage("Shots fired! Shots fired! Shots fired!")
OfficerDownMessage(*) => SendTextMessage("Officer down!")

PFMMessage(*) => SendTextMessage("pfm")
APFMMessage(*) => SendTextMessage("apfm")
BerserkMessage(*) => SendTextMessage("zerk")
InvisMessage(*) => SendTextMessage("invis")
ElvesMessage(*)  => SendTextMessage("Elvs Nearby!")

Rights1Message(*) => SendTextMessage("You have the right to remain silent.")
Rights2Message(*) => SendTextMessage("Anything you say can and will be used against you in a court of law.")
Rights3Message(*) => SendTextMessage("You have the right to an attorney. If you cannot afford an attorney, one will be provided for you.") ; TODO: too long
Rights4Message(*) => SendTextMessage("Do you understand the rights I have just read to you? With these rights in mind, do you wish to speak to me?") ; TODO: too long

CopsMessageMenu1(*) {
    OptionsMenu(["1. Freeze", "2. On The Ground", "3. Dont Move", "4. UnderArrest", "5. Sus Fleeing", "6. Show Hands", "7. Shots Fire", "8. Officer Down"],
                ["FreezeMessage", "OnTheGroundMessage", "DontMoveMessage", "UnderArrestMessage", "SuspectFleeingMessage", "ShowHandsMessage", "ShotsFiredMessage", "OfficerDownMessage"])
}

CopsMessageMenu2(*) {
    OptionsMenu(["1. Rights 1", "2. Rights 2", "3. Rights 3", "4. Rights 4"],
                ["Rights1Message", "Rights2Message", "Rights3Message", "Rights4Message"])
}

LevelingMenu(*) {
    OptionsMenu(["1. PretendCorpse", "2. MagicLeveling", "3. FishingLeveling", "4. PoisonLeveling"],
                ["PretendCorpseLeveling", "ToggleMagicLeveling", "FishingLeveling", "DoNothing"])
}

UncommonCommands(*) {
    OptionsMenu(["1. Eat Food", "2. Sell Items", "3. ShieldBind", "4. ArrangeWindows"],
                ["EatFood", "SellStackedItems", "ShieldBind", "ArrangeWindows"])
}

TamingDoubleClick(*)
{
	BlockInput true
	Send "{Click, 404, 534, 2}"
	MouseMove 402, 277
	BlockInput false
}

TamingAssist(*)
{
	BlockInput true
	Send "/assist"
	Sleep 20
	Send "{enter}"
	BlockInput false
}

TamingHold(*)
{
	BlockInput true
	Send "/hold"
	Sleep 20
	Send "{enter}"
	BlockInput false
}

; Sell/deposit 12 items (use by putting inventory over sell/deposit window at the bottom, hold mouse over the items you want to deposit alt+s
SellStackedItems(*)
{
	Loop 12 ; can only sell 12 items at a time
	{
		Click "Down"
		Send "{F6}" ; Toggle off the inventory menu
		Click "Up"
		Send "{F6}" ; Toggles on the inventory menu
	}
}

EatFood(*) {
	BlockInput true
	Send "{F6}"
	Sleep 10
	Send "{Click, 450, 385, 2}"
	Sleep 10
	Send "{F6}"
	BlockInput false
}

; Shield equip/unequip
ShieldToggle(*) {
	static bToggle := false

	FixCoords()

	if (bToggle)
		ShieldEquip()
	else
		ShieldUnequip()

	bToggle := !bToggle
}

ShieldUnequip(*) {
	BlockInput true
	Send "{F5}"
	Sleep 10
	Send "{Click, 90, 171, 2}"
	Sleep 10
	Send "{F5}"
	BlockInput false
}

ShieldEquip(*) => Send("{F3}")

ShieldBind(*) {
	FixCoords()
	BlockInput true
	Send "{F6}"
	Sleep 10
	Send "{Click, 485, 385, 2}"
	Sleep 10
	Send "^{F3}"
	Sleep 10
	Send "{F6}"
	BlockInput false
}

ArrangeWindows(*)
{
	static bRun := false

	if (!bRun)
	{
		ArrangeInventory()
		Sleep 1000
		ArrangeCharacter()
		Sleep 1000
		ArrangeMagicCircle()
		bRun := false
	}
}

ArrangeInventory(*)
{
	BlockInput true
	Send "{F6}"
	Sleep 10
	MouseClickDrag "Left", 390, 220, 297, 362, 10
	Sleep 500
	Send "{F6}"
	BlockInput false
}

ArrangeCharacter(*)
{
	BlockInput true
	Send "{F5}"
	Sleep 10
	MouseClickDrag "Left", 295, 35, 265, 5, 10
	Sleep 500
	Send "{F5}"
	BlockInput false
}

ArrangeMagicCircle(*)
{
	BlockInput true
	Send "{F7}"
	Sleep 10
	MouseClickDrag "Left", 590, 60, 796, 4, 10
	Sleep 500
	Send "{F7}"
	BlockInput false
}

PretendCorpseLeveling(*)
{
	static bIsFeigning := false

	bIsFeigning := !bIsFeigning

	if bIsFeigning {
		SetTimer(PretendCorpseFunction, 1000)
	}
	else {
		SetTimer(PretendCorpseFunction, 0)
	}
}

PretendCorpseFunction(*) ; Not really meant to be binded, but can be (will execute one time)
{
	MouseGetPos(&x, &y)

	Send "{Click, x, y}"
	Sleep 100
	Send "{F8}" ; toggle menu
	Sleep 100
}

ToggleMagicLeveling(*)
{	
	global MagicLevelingFuncBound

	static bIsLvling := false

	bIsLvling := !bIsLvling
	
	if (bIsLvling) {
		FixCoords()
		MouseMove(400, 290)
		Sleep 100
		MagicMissileSpell := SpellInfo("^{1}", "86", "!F1")
		CreateFoodSpell := SpellInfo("^{1}", "116", "!F1")

		MagicLevelingFuncBound := MagicLeveling.Bind(400, 290, MagicMissileSpell, CreateFoodSpell)
		SetTimer(MagicLevelingFuncBound, 100)
	}
	else
		SetTimer(MagicLevelingFuncBound, 0)
}

MagicLeveling(begin_x := 0, begin_y := 0, MagicMissileSpell := "", CreateFoodSpell := "")
{
	static lastEatTime := 0
	static eatInterval := 360000   ; 6 minutes in milliseconds

	static lastCreateFoodTime := 0
	static createFoodInterval := 4320000   ; 72 minutes in milliseconds

	static lastMagicMissileTime := 0
	static magicMissileInterval := 1900  ; 1.9 seconds in milliseconds (lowest without fails)

	currentTime := A_TickCount

	MouseMove(400, 290)
	Sleep 100

    if (currentTime - lastEatTime >= eatInterval)
    {
        EatFood()
		MouseMove(begin_x, begin_y)
		Sleep 500
        lastEatTime := currentTime
        return
    }

	if (currentTime - lastCreateFoodTime >= createFoodInterval)
    {
        Loop 12 {
			CreateFoodSpell.CastSpell()
			Sleep 1500
			Send "{Click, begin_x, begin_y}"
		}

		Loop 12 {
			Sleep 1000	
			Send "{Click, begin_x, begin_y}"
		}
		
        lastCreateFoodTime := currentTime
        return
    }

    if (currentTime - lastMagicMissileTime >= magicMissileInterval) ; Default action is casting magic missile
    {
        MagicMissileSpell.CastSpell()
		Sleep 1000
		Send "{Click, begin_x, begin_y}"
        lastMagicMissileTime := currentTime
        return
    }
}

CastRodFunction(*) ; Not really meant to be binded, but can be (will execute one time)
{
	static MoveRodResetTime := 0 ; handles potential broken rod

	MouseGetPos &x, &y ; Get the position of the mouse (start fishign with the mouse over the poll)

	Send "{Click, x, y, 2}" ; Doubleclicks fishing rod
	Sleep 100
	Send "{F6}" ; Hides the inventory menu
	Sleep 100
	Send "{Click, x, y}" ; Singleclicks water with the fishing rod engaged
	Sleep 100
	Send "{F6}" ; Shows the inventory menu again

	MoveRodResetTime += 8300 ; this should roughly equal the cast rod loop

	; If so much time has passed, lets move a potentially broken fishing rod out of the way (1500000 = 25 mins)
	if (MoveRodResetTime >= 1500000) {
		MouseClickDrag "Left", x, y, x + 100, y, 50
		Sleep 100
		MouseMove x, y, 50
		MoveRodResetTime := 0
	}
}

FishingLeveling(*)
{
	static bIsFishing := false

	bIsFishing := !bIsFishing

	if bIsFishing {
		CastRodFunction()
		SetTimer(CastRodFunction, 8300)
	}
	else {
		SetTimer(CastRodFunction, 0)
	}
}

; ══════════════════════════════════════════════════════  Other/Conditional Hotkeys  ══════════════════════════════════════════════════════ ;

#HotIf (IsObject(activeMenuManager) && activeMenuManager.optionsGui != "")
    1::activeMenuManager.CallFunction(1)
    2::activeMenuManager.CallFunction(2)
    3::activeMenuManager.CallFunction(3)
	4::activeMenuManager.CallFunction(4)
	5::activeMenuManager.CallFunction(5)
	6::activeMenuManager.CallFunction(6)
	7::activeMenuManager.CallFunction(7)
	8::activeMenuManager.CallFunction(8)
	9::activeMenuManager.CallFunction(9)
#HotIf

; ══════════════════════════════════════════════════════  Graphic User Interface  ══════════════════════════════════════════════════════ ;

if (bShowGUI)
{
	MyGui := Gui()
	CoordText := MyGui.Add("Text", "cLime", "XXXXX YYYYY")  ; XX & YY serve to auto-size the window.
	StatusText := MyGui.Add("Text", "cWhite", "S")  ; Script status
	HealthPotText := MyGui.Add("Text", "cWhite", "H")  ; Autopot Staus
	ManaPotText := MyGui.Add("Text", "cWhite", "M")  ; Autopot Staus

    InitializeGUI()
	SetTimer(CheckWindowState, 1000)
}

InitializeGUI()
{
	global MyGui, CoordText, StatusText, HealthPotText, ManaPotText, ScreenResolution, ScriptActiveIndicatorPos, CoordsIndicatorPos, AutoPotHealthIndicatorPos, AutoPotManaIndicatorPos  ; Access the global variables

	MyGui := Gui()
	MyGui.Opt("+AlwaysOnTop +ToolWindow -Caption Disabled E0x8000000") ;E0x8000000 makes it so you cannot click the GUI stuff (Disabled might be unnecessary)
	MyGui.BackColor := "EEAA99"
	MyGui.SetFont("s12", "Arial")

	CoordText := MyGui.Add("Text", "cLime", "XXXXX YYYYY")
	CoordText.Move(CoordsIndicatorPos[1], CoordsIndicatorPos[2])  ; Move the second text control to a different position.

	StatusText := MyGui.Add("Text", "cWhite", "S")  ; Initialize second text control.
    StatusText.Move(ScriptActiveIndicatorPos[1], ScriptActiveIndicatorPos[2])  ; Move the second text control to a different position.

	HealthPotText := MyGui.Add("Text", "cWhite", "H")
    HealthPotText.Move(AutoPotHealthIndicatorPos[1], AutoPotHealthIndicatorPos[2])

	ManaPotText := MyGui.Add("Text", "cWhite", "M")
    ManaPotText.Move(AutoPotManaIndicatorPos[1], AutoPotManaIndicatorPos[2])

	if (IniRead(ConfigFile, "Settings", "UseAutoPotting") != "true") {
		HealthPotText.Hidden true
		ManaPotText.Hidden true
	}

	WinSetTransColor(MyGui.BackColor " 150", MyGui)
	MyGui.Show("x0 y0 w" ScreenResolution[1] " h" ScreenResolution[2] " NA NoActivate")  ; NoActivate avoids deactivating the currently active window.

    ; Set up a timer to update the OSD
    SetTimer(UpdateOSD, 200)
    UpdateOSD()  ; Make the first update immediate rather than waiting for the timer.
}

UpdateOSD(*) {
	global MyGui, CoordText, StatusText, HealthPotText, ManaPotText, bTryHPPotting, bTryManaPotting  ; Access the global variables

	; Check if MyGui is destroyed
	if (!IsObject(MyGui) || MyGui = "") {
		return  ; Exit the function if MyGui is destroyed
	}

	MouseGetPos(&MouseX, &MouseY)
	CoordText.Value := "X" MouseX ", Y" MouseY

	; First is a boolean argument, true sends the first argument, false seconds the second
	StatusText.SetFont(A_IsSuspended ? "cff9c9c" : "c16ff58") ; pastel red if suspended, pastel green if not
	HealthPotText.SetFont(bTryHPPotting ? "c16ff58" : "cff9c9c") ; pastel green if colors are correct, pastel red if not
	ManaPotText.SetFont(bTryManaPotting ? "c16ff58" : "cff9c9c") ; pastel green if colors are correct, pastel red if not
}

RedrawGUI() {
	DestroyGUI()
	InitializeGUI()
}

DestroyGUI() {
    global MyGui  ; Access the global variable

    if IsObject(MyGui) {
		Sleep 100
		SetTimer(UpdateOSD, 0)
        MyGui.Destroy()
    }
}

; Don't show the GUI if we are minimized and put in some hacks to help ensure we are in Alt Full Screen (which has working color checking for autopot)
CheckWindowState(*) {
    global WinTitle

	static RedrawCount := 0

	if !WinExist(WinTitle) {
		if (IniRead(ConfigFile, "Settings", "HideSystemCursor") == "true" && bIsCursorHidden) {
			RestoreCursor()
		}
		return
	}

	Style := WinGetStyle(WinTitle)
	WinState := WinGetMinMax(WinTitle)
	WinExistFlag := WinExist(WinTitle)

    if (Style & 0x01000000)  ; WS_MAXIMIZE style ToolTip("HB Maximized")
    {
		if (IniRead(ConfigFile, "Settings", "HideSystemCursor") == "true" && !bIsCursorHidden)
			SetSystemCursor()

		if (RedrawCount < 3)
		{
			RedrawGUI()
			RedrawCount++
		}
    }
    else if (WinState == -1)  ; Minimized state ToolTip("HB Minimized")
    {
		RedrawCount := 0

		if (IniRead(ConfigFile, "Settings", "HideSystemCursor") == "true" && bIsCursorHidden) {
			RestoreCursor()
		}

		if (activeMenuManager != "") {
			activeMenuManager.DestroyOptionsGUI()
		}

		DestroyGUI() ; Remove the GUI when HB is minimized
    }
    else ;ToolTip("HB Normal")
    {
		RedrawCount := 0
		WinMaximize(WinTitle)
    }
}

; ══════════════════════════════════════════════════════  Cursor Methods  ══════════════════════════════════════════════════════ ;

ToggleCursor() {
	global bIsCursorHidden

	if (bIsCursorHidden)
		RestoreCursor()
	else
		SetSystemCursor()
}

SetSystemCursor(Cursor := "", cx := 0, cy := 0) {
    global bIsCursorHidden

    static SystemCursors := Map("APPSTARTING", 32650, "ARROW", 32512, "CROSS", 32515, "HAND", 32649, "HELP", 32651, "IBEAM", 32513, "NO", 32648,
                                "SIZEALL", 32646, "SIZENESW", 32643, "SIZENS", 32645, "SIZENWSE", 32642, "SIZEWE", 32644, "UPARROW", 32516, "WAIT", 32514)

    if (Cursor = "") {
        AndMask := Buffer(128, 0xFF), XorMask := Buffer(128, 0)

        for CursorName, CursorID in SystemCursors {
            CursorHandle := DllCall("CreateCursor", "ptr", 0, "int", 0, "int", 0, "int", 32, "int", 32, "ptr", AndMask, "ptr", XorMask, "ptr")
            DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID) ; calls DestroyCursor
        }
        bIsCursorHidden := true
        return
    }

    if (Cursor ~= "^(IDC_)?(?i:AppStarting|Arrow|Cross|Hand|Help|IBeam|No|SizeAll|SizeNESW|SizeNS|SizeNWSE|SizeWE|UpArrow|Wait)$") {
        Cursor := RegExReplace(Cursor, "^IDC_")

        if !(CursorShared := DllCall("LoadCursor", "ptr", 0, "ptr", SystemCursors[StrUpper(Cursor)], "ptr"))
            throw Error("Error: Invalid cursor name")

        for CursorName, CursorID in SystemCursors {
            CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", cx, "int", cy, "uint", 0, "ptr")
            DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID) ; calls DestroyCursor
        }
        bIsCursorHidden := true
        return
    }

    if FileExist(Cursor) {
        SplitPath Cursor,,, &Ext:="" ; auto-detect type
        if !(uType := (Ext = "ani" || Ext = "cur") ? 2 : (Ext = "ico") ? 1 : 0)
            throw Error("Error: Invalid file type")

        if (Ext = "ani") {
            for CursorName, CursorID in SystemCursors {
                CursorHandle := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x10, "ptr")
                DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID) ; calls DestroyCursor
            }
            bIsCursorHidden := true
        } else {
            if !(CursorShared := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x8010, "ptr"))
                throw Error("Error: Corrupted file")

            for CursorName, CursorID in SystemCursors {
                CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", 0, "int", 0, "uint", 0, "ptr")
                DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID) ; calls DestroyCursor
            }
            bIsCursorHidden := true
        }
        return
    }

    throw Error("Error: Invalid file path or cursor name")
}

RestoreCursor() {
	global bIsCursorHidden

	bIsCursorHidden := false
	return DllCall("SystemParametersInfo", "uint", SPI_SETCURSORS := 0x57, "uint", 0, "ptr", 0, "uint", 0)
}

ShowCursor(ExitReason, ExitCode) {
	RestoreCursor()
	ExitApp
}

; ══════════════════════════════════════════════════════  Debugging / WIP ══════════════════════════════════════════════════════ ;



LWin & LButton::ToggleCursor() ; command to toggle cursor in case something goes wrong

!C:: ; useful for debugging
{
	WinMaximize(WinTitle)
	;pA_Clipboard := PixelGetColor(150, 571) . " " . PixelGetColor(163, 592)
}

; Any hotkeys defined below this will work outside of HB
HotIfWinActive
OnExit ShowCursor ; make sure to show cursor again when script exits