#Requires AutoHotkey v2.0

CoordMode "Mouse", "Client" ; Client / Window / Screen (Client might be best)
CoordMode "ToolTip", "Client"
SendMode "Event"

/* Helbreath Script
Author: Andrew
Version: 3.0
Date: 6/12/2024
*/

; This makes it so the script only has hotkeys function if HB Nemesis is the active window/client (attempts)
;WinActivate "HB Nemesis"
WinWaitActive "HB Nemesis"
HotIfWinActive "HB Nemesis"

; Global variables
Global activeMenuManager := ""  ; Global variable to store the active MenuManager instance
Global WinTitle := "HB Nemesis" ; Title of the window
Global bIsCursorHidden := false

#SuspendExempt
*F1::
{
	if A_IsSuspended
		Suspend false
	else
		Suspend true

	return
}
#SuspendExempt false

/*
#==============================================================#
||                     Optional Systems                       ||
#==============================================================#
*/

if (IniRead("hb_script_config.ini", "Settings", "CheckForMinimize") == "true")
{
	CheckForMinimize
}

if (IniRead("hb_script_config.ini", "Settings", "UseAutoPotting") == "true")
{
	SetTimer(AutoPot, 100) ;10x a second
}

if (IniRead("hb_script_config.ini", "Settings", "DebugMode") == "true")
{
	DebugMode := true ; Set to true to use mouse4 tooltip to get client coords
}

if (IniRead("hb_script_config.ini", "Settings", "ShowGUI") == "true")
{
	ShowGUI := true
}

; Create an instance of the class which executes the hotkeys to do nothing
if (IniRead("hb_script_config.ini", "Settings", "UnbindKeys") == "true")
{
	UnbindKeys := HotkeyUnbindClass()
}

/*
#==============================================================#
||                  Script Control Commands                   ||
#==============================================================#
*/

!K::ExitApp ; Kill the app (useful if mouse gets locked or program is not responding

/*
#==============================================================#
||                          Classes                           ||
#==============================================================#
*/

; Begin by unbinding a lot of keys, this is useful as otherwise they begin typing when trying to be in combat
; Later we assign spells to keys (ex- q is unbound, then rebound to a spell)
; We also have to unbind shift+keys as...
; If you try to bind a shift command to a spell and are using shift hold to run, it is possible that shift gets stuck held down. Creating a potential issue. If you hold sprint + use the stantard spell memory of F2, F3, F4 it interupts your single click sprint run
; If you are holding mouse1 with shift also held, your F2-F4 cast commands do not interrupt. This is the same behavior as spells bound without shift versions.
; If you do bind as shift+ spell command and are running with shift it will interrupt your sprint, even if you are holding mouse1 down.
; Therefore it is advisable to not bind these and let them do nothing
; Additional Note: Any hotkey defined to do nothing by this will have to be disabled before being defined again. Ex- Hotkey("1", "Off") will turn 1 off so it can be assigned again via 1::
class HotkeyUnbindClass {
    keys := ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "+1", "2", "+2", "3", "+3", "4", "+4", "5", "+5", "6", "+6", "7", "+7", "8", "+8", "9", "+9", "0", "+0", "-", "=", "Space", ",", ".", "/", "'", "[", "]", "\", "+-", "{}", "+=", "+q", "+w", "+e", "+r", "+t", "+y", "+u", "+i", "+o", "+p", "+a", "+s", "+d", "+f", "+g", "+h", "+j", "+k", "+l", "+z", "+x", "+c", "+v", "+b", "+n", "+m", "+Space", "+CapsLock", "+,", "+.", "+/", ";", "+;", "+'", "+[", "+]", "+\", "Volume_Up", "Volume_Down", "Volume_Mute"]

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

; Handles the spell casting, info, and allows user to assign a key to a spell instead of the other way around
class SpellInfo
{
	__Initialize() { ; Initialize instance variables *Important: will flag errors if omitted*
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

		if WinActive("HB Nemesis") ; This supposedly stops the hotkey from working outside of the HB client
		{
			BlockInput true
			MouseGetPos &begin_x, &begin_y ; Get the position of the mouse
			DebugCoords() ; move the mouse to top left and bottom right, then center to debug screen coords
			MouseClick "right" ; right-click to help ensure cast ready
			Send this.MagicPage ; Open Magic menu tab
			MouseClick "left", 600, this.YCoord, 1, 0 ; Click spell coords
			MouseMove begin_x, begin_y ; Move mouse back to original position
			Sleep 50
			BlockInput false

			/*
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

; Handles other commands
class CommandInfo
{
	__Initialize() { ; Initialize instance variables *Important: will flag errors if omitted*
		HotKeyName := ""
		InputCommand := ""
	}

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

		if WinActive("HB Nemesis") ; This supposedly stops the hotkey from working outside of the HB client
		{
			Send this.InputCommand
		}
	}

	DoNothing(*) {
	}
}

; A class for managing menu with button options (can be clicked or use keyboard 1-9)
class OptionsMenuManager {
    ; Member variables
    optionsGui := ""  ; Initialize as empty string
	optionMenuLabels := Array()
    optionFunctionNames := Array()

    ; Constructor with parameters
    __New(optionNames, functionNames) {
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
		DebugCoords()

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
        if (index < 1 || index > this.optionFunctionNames.Length || !WinActive("HB Nemesis"))
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

/*
#==============================================================#
||                      Load From Config                      ||
#==============================================================#
*/

LoadSpellsFromConfig()
{
	Section := IniRead("hb_script_config.ini", "Spells")

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

LoadCommandsFromConfig(SectionName)
{
	Section := IniRead("hb_script_config.ini", SectionName)

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

/*
#==============================================================#
||                    Systems/Functions                       ||
#==============================================================#
*/

CheckForMinimize()
{
	static bMinimizedTipOpen := false

	if (!WinActive("HB Nemesis"))
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

	SetTimer CheckForMinimize, 1000 ;1x a second
}

; Handles checking health pool for auto pot chug
AutoPot()
{
	; FSA = Full Screen Alternative (ctrl+shift+v)
	; colors seem to be different in FSA!!!!!!
	; doesn't seem to work anymore without FSA
	; Life / Mana pool x pixel coords range: 107 to 207

	if WinActive("HB Nemesis")
	{
		static LowHPDuration := 0
		static LowManaDuration := 0
		static bTryHPPotting := true
		static bTryManaPotting := true

		ColorHPLowFSA := "0x313131"
		ColorManaLowFSA := "0x424142"

		;ToolTip "HP: " . PixelGetColor(149, 570) . "Mana: " . PixelGetColor(163, 592)
		;A_Clipboard := PixelGetColor(150, 571) . " " . PixelGetColor(163, 592)

		; Check low HP
		if IsColorInRange(149, 570, ColorHPLowFSA, 35) && IsColorInRange(111, 567, ColorHPLowFSA, 35)
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
		if IsColorInRange(163, 592, ColorManaLowFSA, 35) && IsColorInRange(111, 587, ColorManaLowFSA, 35)
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

IsColorInRange(x, y, targetColor, tolerance := 10)
{
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

SendTextMessage(str := "")
{
	BlockInput true
	Send "{enter}"
	SendText str
	Sleep 20
	Send "{enter}"
	BlockInput false
}

/*
#==============================================================#
||                   Bindable Functions                       ||
#==============================================================#
*/

#SuspendExempt
ToggleSuspendScript(*)
{
	Send "{F1}"
}

SuspendScript(*)
{
	Suspend true
}

ResumeScript(*)
{
	Suspend false
}
#SuspendExempt false

DoNothing(*)
{
}

ToggleMap(*)
{
	send "^m"
}

OpenBag(*)
{
	send "{f6}"
}

ToggleRunWalk(*)
{
	send "^r"
}

OpenOptions(*)
{
	send "{F12}"
}

RecruitMessage(*) => SendTextMessage("~COPS recruiting, whisper me")
FreezeMessage(*) => SendTextMessage("This is the police! Freeze!!!")
OnTheGroundMessage(*) => SendTextMessage("Get down on the ground!")
DontMoveMessage(*) => SendTextMessage("Don't move!")
UnderArrestMessage(*) => SendTextMessage("You're under arrest.")
SuspectFleeingMessage(*) => SendTextMessage("Suspect is fleeing!")
ShowHandsMessage(*) => SendTextMessage("Show me your hands!")
ShotsFiredMessage(*) => SendTextMessage("Shots fired! Shots fired! Shots fired!")
OfficerDownMessage(*) => SendTextMessage("Officer down!")

Rights1Message(*) => SendTextMessage("You have the right to remain silent.")
Rights2Message(*) => SendTextMessage("Anything you say can and will be used against you in a court of law.")
Rights3Message(*) => SendTextMessage("You have the right to an attorney. If you cannot afford an attorney, one will be provided for you.") ; too long
Rights4Message(*) => SendTextMessage("Do you understand the rights I have just read to you? With these rights in mind, do you wish to speak to me?") ; too long

; cops text commands "Freeze", "You have the right to remain silent.", "Anything you say can and will be used against you in a court of law.", "You have the right to an attorney. If you cannot afford an attorney, one will be provided for you."
; Do you understand the rights I have just read to you? With these rights in mind, do you wish to speak to me?”
; "Get down on the ground!", "Don't move!", "You're under arrest.", "Requesting backup!", "Shots fired!", "Suspect is fleeing!","Officer down!", "Show me your hands!"

; Hotkey to show the dialog when CapsLock is pressed

CopsMessageMenu1(*)
{
	global activeMenuManager

	if (activeMenuManager == "")
	{
		optionNames := ["1. Freeze", "2. On The Ground", "3. Dont Move", "4. UnderArrest", "5. Sus Fleeing", "6. Show Hands", "7. Shots Fire", "8. Officer Down"]
		optionFunctionNames := ["FreezeMessage", "OnTheGroundMessage", "DontMoveMessage", "UnderArrestMessage", "SuspectFleeingMessage", "ShowHandsMessage", "ShotsFiredMessage", "OfficerDownMessage"]
		activeMenuManager := OptionsMenuManager(optionNames, optionFunctionNames)
		activeMenuManager.showOptionsDialog()
	}
	else
	{
		activeMenuManager.DestroyOptionsGUI()
	}
}

CopsMessageMenu2(*)
{
	global activeMenuManager

	if (activeMenuManager == "")
	{
		optionNames := ["1. Rights 1", "2. Rights 2", "3. Rights 3", "4. Rights 4"]
		optionFunctionNames := ["Rights1Message", "Rights2Message", "Rights3Message", "Rights4Message"]
		activeMenuManager := OptionsMenuManager(optionNames, optionFunctionNames)
		activeMenuManager.showOptionsDialog()
	}
	else
	{
		activeMenuManager.DestroyOptionsGUI()
	}
}

LevelingMenu(*)
{
	global activeMenuManager

	if (activeMenuManager == "")
	{
		optionNames := ["1. PretendCorpse", "2. MagicLeveling", "3. FishingLeveling", "4. PoisonLeveling"]
		optionFunctionNames := ["PretendCorpseLeveling", "MagicLeveling", "FishingLeveling", "DoNothing"]
		activeMenuManager := OptionsMenuManager(optionNames, optionFunctionNames)
		activeMenuManager.showOptionsDialog()
	}
	else
	{
		activeMenuManager.DestroyOptionsGUI()
	}
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

; Shield equip/unequip
ShieldToggle(*)
{
	static bToggle := false

	DebugCoords

	if (bToggle)
	{
		ShieldEquip
	}
	else
	{
		ShieldUnequip
	}

	bToggle := !bToggle
}

ShieldUnequip(*)
{
	BlockInput true
	Send "{F5}"
	Sleep 10
	Send "{Click, 90, 171, 2}"
	Sleep 10
	Send "{F5}"
	BlockInput false
}

ShieldEquip(*)
{
	Send "{F3}"
}

ShieldBind(*)
{
	BlockInput true
	Send "{F6}"
	Sleep 10
	Send "{Click, 90, 171, 2}"
	Sleep 10
	Send "{^F3}"
	Sleep 10
	Send "{F6}"
	BlockInput false
}

ArrangeWindows(*)
{
	static bRun := false

	if (!bRun)
	{
		ArrangeInventory ;move inventory window
		Sleep 1000
		ArrangeCharacter ;move character window
		Sleep 1000
		ArrangeMagicCircle ;move magic window
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

	if bIsFeigning
	{
		SetTimer PretendCorpseFunction, 1000
	}
	else
	{
		SetTimer PretendCorpseFunction, 0
	}
}

PretendCorpseFunction(*) ; Not really meant to be binded, but can be (will execute one time)
{
	;static EatFood := 0 ; handles potential broken rod

	MouseGetPos &x, &y ; Get the position of the mouse (start fishign with the mouse over the poll)

	Send "{Click, x, y}"
	Sleep 100
	Send "{F8}" ; toggle menu
	Sleep 100
}

;needs work
#MaxThreadsPerHotkey 3
MagicLeveling(*) ; Magic leveling : Bind GreatHeal to F2, Magic Missle to F3, put inventory food over player to where mouse doesn't need to move to eat the food, close inventory and run command
{
	static bIsLvling := false
	i := 0

	if bIsLvling  ; If this is true the loop below is already running
    {
        bIsLvling := false  ; Signal that thread's loop to stop.
        return  ; End this thread so that the one underneath will resume and see the change made by the line above.
    }
	bIsLvling := true

	MouseGetPos &begin_x, &begin_y ; Get the position of the mouse

	Loop
	{
	    i++

		if (!mod(i, 10)) ; heal
		{
			Send "{F2}"
			Sleep 2000
			Send "{Click, begin_x, begin_y}"
		}
		else if (!mod(i, 25)) ; eat food
		{
			Send "{F6}"
			Sleep 100
			Send "{Click, begin_x, begin_y, 2}"
			Sleep 200
			Send "{F6}"
		}
		else ; cast magic missle
		{
			Send "{F3}"
			Sleep 2000
			Send "{Click, begin_x, begin_y}"
		}

		BlockInput true
		Sleep 100
		MouseMove begin_x, begin_y ; mouse mouse back to starting point incase it accidently was moved
		Sleep 200
		BlockInput false

		; This will exit the loop if we've toggled
        if not bIsLvling  ; The user signaled the loop to stop by pressing command again
            break  ; Break out of this loop.
	}
	bIsLvling := false
}
#MaxThreadsPerHotkey 1 ;sets back to global default

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

	; If so much time has passed, lets move a potentially broken fishing rod out of the way
	; 1500000 = 25 mins
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

	if bIsFishing
	{
		CastRodFunction ; cast immediately
		SetTimer CastRodFunction, 8300
	}
	else
	{
		SetTimer CastRodFunction, 0
	}
}

/*
#==============================================================#
||                 Other/Conditional Hotkeys                  ||
#==============================================================#
*/

#HotIf (IsObject(activeMenuManager) && activeMenuManager.optionsGui != "")
{
    1::activeMenuManager.CallFunction(1)
    2::activeMenuManager.CallFunction(2)
    3::activeMenuManager.CallFunction(3)
	4::activeMenuManager.CallFunction(4)
	5::activeMenuManager.CallFunction(5)
	6::activeMenuManager.CallFunction(6)
	7::activeMenuManager.CallFunction(7)
	8::activeMenuManager.CallFunction(8)
	9::activeMenuManager.CallFunction(9)
}
#HotIf

/*
#==============================================================#
||                   Graphic User Interface                   ||
#==============================================================#
*/

RedrawCount := 0
bColorsCorrect := false

if (ShowGUI)
{
	MyGui := Gui()
	CoordText := MyGui.Add("Text", "cLime", "XXXXX YYYYY")  ; XX & YY serve to auto-size the window.
	StatusText := MyGui.Add("Text", "cWhite", "S")  ; Script status
	AutoPotText := MyGui.Add("Text", "cWhite", "A")  ; Autopot Staus

    InitializeGUI()
	SetTimer CheckWindowState, 1000
}

InitializeGUI()
{
	global MyGui, CoordText, StatusText, AutoPotText  ; Access the global variables

	MyGui := Gui()
	MyGui.Opt("+AlwaysOnTop +ToolWindow -Caption Disabled E0x8000000") ;E0x8000000 makes it so you cannot click the GUI stuff (Disabled might be unessary)
	MyGui.BackColor := "EEAA99"
	MyGui.SetFont("s7", "Arial")

	CoordText := MyGui.Add("Text", "cLime", "XXXXX YYYYY")
	CoordText.Move(290, 588)  ; Move the second text control to a different position.
	CoordText.OnEvent("Click", DoNothing)

	StatusText := MyGui.Add("Text", "cWhite", "S")  ; Initialize second text control.
    StatusText.Move(89, 557)  ; Move the second text control to a different position.
	StatusText.OnEvent("Click", (self, info) => "")

	AutoPotText := MyGui.Add("Text", "cWhite", "A")
    AutoPotText.Move(89, 570)

	if (IniRead("hb_script_config.ini", "Settings", "UseAutoPotting") != "true")
	{
		AutoPotText.Hidden true
	}

	WinSetTransColor(MyGui.BackColor " 150", MyGui)
	MyGui.Show("x0 y0 w800 h600 NA NoActivate")  ; NoActivate avoids deactivating the currently active window.

    ; Set up a timer to update the OSD
    SetTimer(UpdateOSD, 200)
    UpdateOSD()  ; Make the first update immediate rather than waiting for the timer.
}

UpdateOSD(*)
{
	global MyGui, CoordText, StatusText, AutoPotText, bColorsCorrect  ; Access the global variables

	; Check if MyGui is destroyed
	if (!IsObject(MyGui) || MyGui = "") {
		return  ; Exit the function if MyGui is destroyed
	}

	MouseGetPos &MouseX, &MouseY
	CoordText.Value := "X" MouseX ", Y" MouseY

	if (A_IsSuspended)
	{
		StatusText.SetFont("cff9c9c") ; pastel red
	}
	else
	{
		StatusText.SetFont("c16ff58") ; pastel green
	}

	if (!bColorsCorrect) ; TODO: Remove this variable and replace with a check on the HP/Mana pool colors or something
	{
		AutoPotText.SetFont("cff9c9c") ; pastel red
	}
	else
	{
		AutoPotText.SetFont("c16ff58") ; pastel green
	}
}

RedrawGUI()
{
	DestroyGUI()
	InitializeGUI()
}

DestroyGUI()
{
    global MyGui  ; Access the global variable
    if IsObject(MyGui)
    {
		Sleep 100
		SetTimer(UpdateOSD, 0)
        MyGui.Destroy()
    }
}

; Don't show the GUI if we are minimized and put in some hacks to help ensure we are in Alt Full Screen (which has working color checking for autopot)
CheckWindowState(*)
{
    global WinTitle, RedrawCount, bColorsCorrect

	static bAFSEnabled := false
	static AFSAttemts := 0

    ; Get window information
	if WinExist("HB Nemesis")
	{
		Style := WinGetStyle(WinTitle)
		WinState := WinGetMinMax(WinTitle)
		WinExistFlag := WinExist(WinTitle)
	}
	else
	{
		return
	}

    ; Check if the window is maximized
    if (Style & 0x01000000)  ; WS_MAXIMIZE style ToolTip("HB Maximized")
    {
		if (IniRead("hb_script_config.ini", "Settings", "HideSystemCursor") == "true" && !bIsCursorHidden)
		{
			SetSystemCursor()
		}

		if (RedrawCount <= 5)
		{
			RedrawGUI()
			RedrawCount++
		}

		; Check to see if the GUI colors are correct, we check two far away pixels on the HB GUI so the cursor can't mess with this
		if (PixelGetColor(85, 555) != "0x212021" && PixelGetColor(710, 555) != "0x212421")
		{
			bColorsCorrect := false

			; hack to fix color checking
			if (IniRead("hb_script_config.ini", "Settings", "ColorFixHack") == "true")
			{
				if (AFSAttemts <= 10)
				{
					AFSAttemts++
					Send "^+{V}"
					Sleep 2000
				}
			}
		}
		else
		{
			bColorsCorrect := true
		}

    }
    else if (WinState == -1)  ; Minimized state ToolTip("HB Minimized")
    {
		if (IniRead("hb_script_config.ini", "Settings", "HideSystemCursor") == "true" && bIsCursorHidden)
		{
			RestoreCursor()
		}

		if (activeMenuManager != "")
		{
			activeMenuManager.DestroyOptionsGUI()
		}

		DestroyGUI() ; This disables the GUI when HB is minimized
		bAFSEnabled := false
    }
    else if (WinExistFlag == 0)  ; Window does not exist
    {
    }
    else ;ToolTip("HB Normal")
    {
		RedrawCount := 0
		WinMaximize("HB Nemesis")

		; hack to automate alt full screen
		if (!bAFSEnabled && IniRead("hb_script_config.ini", "Settings", "AltFullScreenHack") == "true")
		{
			bAFSEnabled := true
			Send "^+{V}"
		}
    }
}

/*
#==============================================================#
||                       Cursor Methods                       ||
#==============================================================#
*/

ToggleCursor()
{
	global bIsCursorHidden

	if (bIsCursorHidden)
	{
		RestoreCursor()
	}
	else
	{
		SetSystemCursor()
	}
}

SetSystemCursor(Cursor := "", cx := 0, cy := 0)
{
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
			bIsCursorHidden := true
		 }
	  } else {
		 if !(CursorShared := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x8010, "ptr"))
			throw Error("Error: Corrupted file")

		 for CursorName, CursorID in SystemCursors {
			CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", 0, "int", 0, "uint", 0, "ptr")
			DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID) ; calls DestroyCursor
		 }
	  }
	  bIsCursorHidden := true
	  return
	}

	throw Error("Error: Invalid file path or cursor name")
}

GetCursorState()
{
	global bIsCursorHidden

	return bIsCursorHidden
}

RestoreCursor()
{
	global bIsCursorHidden

	bIsCursorHidden := false
	return DllCall("SystemParametersInfo", "uint", SPI_SETCURSORS := 0x57, "uint", 0, "ptr", 0, "uint", 0)
}

ShowCursor(ExitReason, ExitCode)
{
	RestoreCursor()
	ExitApp
}

/*
#==============================================================#
||                          Debugging                         ||
#==============================================================#
*/

LWin & LButton::ToggleCursor() ; command to toggle cursor in case something goes wrong

!C:: ; useful for debuggin
{
	WinMaximize("HB Nemesis")
	;pA_Clipboard := PixelGetColor(150, 571) . " " . PixelGetColor(163, 592)
}

^+V::
{
	global RedrawCount

	RedrawCount := 0
}

DebugCoords()
{
	MouseMove -1000, -1000, 1
	Sleep 50
	MouseMove +3000, +3000, 1
	Sleep 50
	MouseMove 400, 300, 1
	Sleep 50
}


; Any hotkeys defined below this will work outside of HB Nemesis
HotIfWinActive
OnExit ShowCursor ; make sure to show cursor again when script exits

; ideas to implement
; text requests for zerk, apfm, pfm, invis, etc
