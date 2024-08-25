if (bShowGUI)
{
	MyGui := Gui()
	CoordText := MyGui.Add("Text", "cLime", "XXXXX YYYYY")  ; XX & YY serve to auto-size the window.
	StatusText := MyGui.Add("Text", "cWhite", "SSSSS")  ; Script status
	HealthPotText := MyGui.Add("Text", "cWhite", "H")
	ManaPotText := MyGui.Add("Text", "cWhite", "M")

    InitializeGUI()
	SetTimer(CheckWindowState, 1000)
}

InitializeGUI()
{
	global MyGui, CoordText, StatusText, HealthPotText, ManaPotText, ScreenResolution, ScriptActiveIndicatorPos, CoordsIndicatorPos, AutoPotHealthIndicatorPos, AutoPotManaIndicatorPos  ; Access the global variables

	MyGui := Gui()
	MyGui.Opt("+AlwaysOnTop +ToolWindow -Caption Disabled E0x8000000") ;E0x8000000 makes it so you cannot click the GUI stuff (Disabled might be unnecessary)
	MyGui.BackColor := "EEAA99"
	MyGui.SetFont("s13", "Arial")

	CoordText := MyGui.Add("Text", "cLime", "XXXXX YYYYY")
	CoordText.Move(CoordsIndicatorPos[1], CoordsIndicatorPos[2])  ; Move the second text control to a different position.
	StatusText := MyGui.Add("Text", "cWhite", "Script")  ; Initialize second text control.
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
		return
	}

	Style := WinGetStyle(WinTitle)
	WinState := WinGetMinMax(WinTitle)
	WinExistFlag := WinExist(WinTitle)

    if (Style & 0x01000000)  ; WS_MAXIMIZE style ToolTip("HB Maximized")
    {
		if (RedrawCount < 3)
		{
			RedrawGUI()
			RedrawCount++
		}
    }
    else if (WinState == -1)  ; Minimized state ToolTip("HB Minimized")
    {
		RedrawCount := 0

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
