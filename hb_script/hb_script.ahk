#Requires AutoHotkey v2.0

; AHK settings
CoordMode "Mouse", "Client" ; Client / Window / Screen (Client might be best)
CoordMode "ToolTip", "Client"
SendMode "Event"

#Include Gdip_All.ahk
#Include global_variables.ahk

; AHK initiatives
WinWaitActive WinTitle ;Script waits until HB window is active/front
HotIfWinActive WinTitle ;Attempt to make Hotkeys only work inside the HB window
SetWorkingDir A_InitialWorkingDir ;Forces the script to use the folder it was initially launched from as its working directory

#Include load_from_ini.ahk
#Include class_commandinfo.ahk
#Include class_hotkeyunbind.ahk
#Include class_optionsmenumanager.ahk
#Include class_spellinfo.ahk
#Include class_statuseffectindicator.ahk
#Include class_repbutton.ahk
#Include functions_autopot.ahk
#Include functions_leveling.ahk
#Include functions_messages.ahk
#Include functions_detection.ahk
#Include gui_main.ahk

#SuspendExempt
!K::ExitApp ; Kill the app (useful if mouse gets locked or program is not responding)

*F1:: ; F1 should only be used to suspend or unsuspend the script, the * designates this (aka it prevents the HB F1 help menu from popping up)
{
	if A_IsSuspended
		Suspend false
	else
		Suspend true
}

~Escape::
{
	global stopFlag

	stopFlag := true
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
    OptionsMenu(["1. PretendCorpse", "2. MagicLeveling", "3. SlimeLeveling"],
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

; needs work
EatFood(*) {
	BlockInput true
	Send "{F6}"
	Sleep 10
	Send "{Click, 450, 385, 2}"
	Sleep 10
	Send "{F6}"
	BlockInput false
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
OnExit ReturnInputs()