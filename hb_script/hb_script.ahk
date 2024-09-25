#Requires AutoHotkey v2.0

; AHK settings
CoordMode "Mouse", "Screen" ; Client / Window / Screen (Client might be best)
CoordMode "ToolTip", "Screen"
SendMode "Event"

#Include includes\global_variables.ahk

; AHK initiatives
WinWaitActive WinTitle ;Script waits until HB window is active/front
HotIfWinActive WinTitle ;Attempt to make Hotkeys only work inside the HB window
SetWorkingDir A_InitialWorkingDir ;Forces the script to use the folder it was initially launched from as its working directory

#Include includes\load_from_ini.ahk
#Include includes\functions_common.ahk
#Include includes\class_GUIManager.ahk
#Include includes\class_commandinfo.ahk
#Include includes\class_hotkeyunbind.ahk
#Include includes\class_optionsmenumanager.ahk
#Include includes\class_spellinfo.ahk
#Include includes\class_statuseffectindicator.ahk
#Include includes\class_repbutton.ahk
#Include includes\class_nodeinfo.ahk
#Include includes\functions_minimap.ahk
#Include includes\functions_inventory.ahk
#Include includes\functions_autopot.ahk
#Include includes\functions_leveling.ahk
#Include includes\functions_farming.ahk
#Include includes\functions_messages.ahk
#Include includes\functions_traderep.ahk

; GUI (cannot reside in global_variables as thes require all includes)
Global HUD := GUIManager()
Global RepButtonInst := RepButton(60) ; in minutes

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

CheckWindowState() {
	static bMinimizedTipOpen := false

	if !WinExist(WinTitle) {
		return
	}

	Style := WinGetStyle(WinTitle)
	WinState := WinGetMinMax(WinTitle)

	if (Style & 0x01000000)  ; WS_MAXIMIZE style
	{
		bMinimizedTipOpen := false
		gGUI.Show("x0 y0 w" ScreenResolution[1] " h" ScreenResolution[2] " NA NoActivate")
		WinSetAlwaysOnTop(1, gGUI.Hwnd)          
	} 
	else if (WinState == -1)  ; Minimized state
	{
		gGUI.Hide()

		if (activeMenuManager != "") {
			activeMenuManager.DestroyOptionsGUI()
		}	

		if (!bMinimizedTipOpen) {
			; Display a prompt dialog box
			MsgBoxResult := MsgBox("Do you want to close the script?",, "YesNo")

			; Check the user's response
			if (MsgBoxResult = "Yes")
				ExitApp()
			else if (MsgBoxResult = "No")
				bMinimizedTipOpen := true
		}
		else {
			ToolTip "HB Script is still running!"
		}	
	} 
	else {
		WinMaximize(WinTitle)
	}
}

SetTimer(CheckWindowState, 1000)

CalculateFontSize(percentOfHeight) {
    ScreenHeight := ScreenResolution[2] + 0  ; Get the screen height
    return Round((percentOfHeight / 100) * ScreenHeight)  ; Calculate font size as a percentage of height
}

ToggleDebugMode(*)
{
	Global bDebugMode

	bDebugMode := !bDebugMode
}

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
	MouseClick "left", CtPixel(67, "X"), CtPixel(48, "Y")
	Sleep 10
	Send "{F8}"
	BlockInput false
}

TakeInvisPot(*) {
	BlockInput true
	Send "{F6}"
	Sleep 10
	MouseClick "left", CtPixel(90, "X"), CtPixel(55.2, "Y"), 2
	Sleep 10
	Send "{F6}"
	BlockInput false
}

; ══════════════════════════════════════════════════════  Hotkeys and Game Actions ══════════════════════════════════════════════════════ ;

ToggleMap(*) => Send("^m")
OpenBag(*) => Send("{f6}")
ToggleRunWalk(*) => Send("^r")
OpenOptions(*) => Send("{F12}")

ShiftPickup(bTurnOn := true) {
    x := CtPixel(40.4, "X")
    y := CtPixel(36.4, "Y")
    hS := 8
    X1 := x - hS, Y1 := y - hS, X2 := x + hS, Y2 := y + hS  ; Initial search area variables
    Px := 0, Py := 0
    targetColor := 0xC8C8C8  ; The checked color (enabled)

    BlockInput true
    Send("{F12}")
    Sleep(10)
    MouseClick "left", CtPixel(71, "X"), CtPixel(22, "Y"), 2
    Sleep(10)

	; If the pixel isn't the target color, perform the click action
	if (PixelSearch(&Px, &Py, X1, Y1, X2, Y2, targetColor) != bTurnOn) {
		MouseClick "left", x, y, 1
	}

    Send("{F12}")
    Sleep(10)
    BlockInput false
}

EnableShiftPickup() {
    ShiftPickup(true)
}

DisableShiftPickup() {
    ShiftPickup(false)
}

RequestMenu(*) {
    OptionsMenu(["1. AMP", "2. Zerk", "3. Invis", "4. Enemies!"],
                ["APFMMessage", "BerserkMessage", "InvisMessage", "EnemiesMessage"])
}

LevelingMenu(*) {
    OptionsMenu(["1. PretendCorpse", "2. MagicLeveling", "3. Basic Leveling", "4. Farming", "5. Test"],
                ["PretendCorpseLeveling", "ToggleMagicLeveling", "BeginBasicLeveling", "StartFarming", "Test"])
}

UncommonCommands(*) {
    OptionsMenu(["1. Toggle Debug", "2. Eat Food", "3. Sell Items"],
                ["ToggleDebugMode", "EatFood", "SellStackedItems"])
}

ReputationMenu(*) {
	OptionsMenu(["1. TradeRep", "2. Rep Player", "3. AFK Rep"],
				["traderep", "rep+ menu", "ActivateAutoTradeRep"])
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

/*
!C:: ; useful for debugging
{
	;WinMaximize(WinTitle)
	;pA_Clipboard := PixelGetColor(150, 571) . " " . PixelGetColor(163, 592)
}
*/

ReturnInputs(*)
{
	BlockInput false
	BlockInput "MouseMoveOff"
}

; Any hotkeys defined below this will work outside of HB
HotIfWinActive
;OnExit ReturnInputs()