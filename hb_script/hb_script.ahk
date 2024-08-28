#Requires AutoHotkey v2.0

; AHK settings
CoordMode "Mouse", "Client" ; Client / Window / Screen (Client might be best)
CoordMode "ToolTip", "Client"
SendMode "Event"

#Include includes\global_variables.ahk

; AHK initiatives
WinWaitActive WinTitle ;Script waits until HB window is active/front
HotIfWinActive WinTitle ;Attempt to make Hotkeys only work inside the HB window
SetWorkingDir A_InitialWorkingDir ;Forces the script to use the folder it was initially launched from as its working directory

#Include includes\load_from_ini.ahk
#Include includes\class_commandinfo.ahk
#Include includes\class_hotkeyunbind.ahk
#Include includes\class_optionsmenumanager.ahk
#Include includes\class_spellinfo.ahk
#Include includes\class_statuseffectindicator.ahk
#Include includes\class_repbutton.ahk
#Include includes\functions_autopot.ahk
#Include includes\functions_leveling.ahk
#Include includes\functions_messages.ahk
#Include includes\gui_main.ahk

#SuspendExempt
!K::ExitApp ; Kill the app (useful if mouse gets locked or program is not responding)

; F1 should only be used to suspend or unsuspend the script, the * designates this (aka it prevents the HB F1 help menu from popping up)
*F1:: A_IsSuspended ? Suspend(false) : Suspend(true)

~Escape::
{
	global stopFlag, activeMenuManager

	stopFlag := true

    if (activeMenuManager != "") {
        activeMenuManager.DestroyOptionsGUI()
    }	
}

~LButton:: ; ~ means the button should behave as normal in addition to this code
{
	Global CastingEffectSpell, Effects

	if (CastingEffectSpell != "") 
	{
		Effects.Push(StatusEffectIndicator(CastingEffectSpell[1], CastingEffectSpell[2], ""))

		for (i, indicator in Effects)
		{
			if (!indicator.IsActive())
			{
				Effects.RemoveAt(i) ; Remove the expired instance from the array 
			}
		}
	}

	CastingEffectSpell := ""
}

~RButton::
{
	Global CastingEffectSpell

	CastingEffectSpell := ""
}

ToggleSuspendScript(*) => Send("{F1}") ; unused, consider removing?
SuspendScript(*) => Suspend(true)
ResumeScript(*) => Suspend(false)

#SuspendExempt false

; ══════════════════════════════════════════════════════  Systems/Functions ══════════════════════════════════════════════════════ ;

CtPixel(percent, axis) {
    ScreenResolutionX := ScreenResolution[1] + 0  ; Cast to number
    ScreenResolutionY := ScreenResolution[2] + 0  ; Cast to number

    if (axis = "X") {
        return Round((percent / 100) * ScreenResolutionX)
    } else if (axis = "Y") {
        return Round((percent / 100) * ScreenResolutionY)
    }
}

CtPercent(pixel, axis) {
    ScreenResolutionX := ScreenResolution[1] + 0  ; Cast to number
    ScreenResolutionY := ScreenResolution[2] + 0  ; Cast to number

    if (axis = "X") {
        return (pixel / ScreenResolutionX) * 100
    } else if (axis = "Y") {
        return (pixel / ScreenResolutionY) * 100
    }
}

; CctPixels function: Converts percentage coordinates to pixel coordinates
CctPixels(x, y) {
    pixelX := CtPixel(x, "X")  ; Convert x percentage to pixels
    pixelY := CtPixel(y, "Y")  ; Convert y percentage to pixels
    return [pixelX, pixelY]    ; Return array with both pixel values
}

DoNothing(*) => { } ; A placeholder function used when a method is required, but no action is needed.

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

OptionsMenu(optionNames, optionFunctionNames) {
    global activeMenuManager

    if (activeMenuManager == "") {
        activeMenuManager := OptionsMenuManager(optionNames, optionFunctionNames)
        activeMenuManager.showOptionsDialog()
    } else {
        activeMenuManager.DestroyOptionsGUI()
    }
}

; add this function to the beginning of functions that will often be used in combat
RemoveHolds(*) {
    Send("{Ctrl up}")
    Send("{Alt up}")
    Send("{Shift up}")
}

PretendCorpse(*) {
	RemoveHolds()

	BlockInput true
	MouseClick "right"
	Sleep 10
	MouseClick "right"
	Sleep 10
	Send "{F8}"
	Sleep 10
	MouseClick "left", CtPixel(26.6666, "X"), CtPixel(26.7592, "Y")
	Sleep 10
	BlockInput false
}

EatFood(*) {
	BlockInput true
	Send "{F6}"
	Sleep 10
	MouseClick "left", CtPixel(93.0, "X"), CtPixel(55.2, "Y"), 2, 0
	Sleep 10
	Send "{F6}"
	BlockInput false
}

TakeInvisPot(*) {
	BlockInput true
	Send "{F6}"
	Sleep 10
	MouseClick "left", CtPixel(37.1875, "X"), CtPixel(30.6481, "Y"), 2, 0
	Sleep 10
	Send "{F6}"
	BlockInput false
}

; ══════════════════════════════════════════════════════  Hotkeys and Game Actions ══════════════════════════════════════════════════════ ;

ToggleMap(*) => Send("^m")
OpenBag(*) => Send("{f6}")
ToggleRunWalk(*) => Send("^r")
OpenOptions(*) => Send("{F12}")

RequestMenu(*) {
    OptionsMenu(["1. PFM", "2. AMP", "3. Zerk", "4. Invies", "5. Enemies!"],
                ["PFMMessage", "APFMMessage", "BerserkMessage", "InvisMessage", "EnemiesMessage"])
}

LevelingMenu(*) {
    OptionsMenu(["1. PretendCorpse", "2. MagicLeveling", "3. SlimeLeveling 5343211456"],
                ["PretendCorpseLeveling", "ToggleMagicLeveling", "SlimeLeveling"])
}

UncommonCommands(*) {
    OptionsMenu(["1. Eat Food", "2. Sell Items"],
                ["EatFood", "SellStackedItems"])
}

; Sell/deposit 12 items (use by putting inventory over sell/deposit window at the bottom, hold mouse over the items you want to deposit alt+s
; is this obsolete?
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

; ══════════════════════════════════════════════════════  Debugging / WIP ══════════════════════════════════════════════════════ ;

!C:: ; useful for debugging
{
	;WinMaximize(WinTitle)
	;pA_Clipboard := PixelGetColor(150, 571) . " " . PixelGetColor(163, 592)
}

ReturnInputs(*)
{
	BlockInput false
	BlockInput "MouseMoveOff"
}

; Any hotkeys defined below this will work outside of HB
HotIfWinActive
;OnExit ReturnInputs()