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

CalculateFontSize(percentOfHeight) {
    ScreenHeight := ScreenResolution[2] + 0  ; Get the screen height
    return Round((percentOfHeight / 100) * ScreenHeight)  ; Calculate font size as a percentage of height
}
	
InitializeGUI()
{
	global MyGui, CoordText, StatusText, HealthPotText, ManaPotText, ScreenResolution, ScriptActiveIndicatorPos, CoordsIndicatorPos, AutoPotHealthIndicatorPos, AutoPotManaIndicatorPos  ; Access the global variables

	MyGui := Gui()
	MyGui.Opt("+AlwaysOnTop +ToolWindow -Caption Disabled E0x8000000") ;E0x8000000 makes it so you cannot click the GUI stuff (Disabled might be unnecessary)
	MyGui.BackColor := "EEAA99"
	MyGui.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")

	CoordText := MyGui.Add("Text", "cLime Center", "XXXXXXXX YYYYYYYY")
	CoordText.Move(CtPixel(CoordsIndicatorPos[1], "X"), CtPixel(CoordsIndicatorPos[2], "Y"))  ; Move the second text control to a different position.
	StatusText := MyGui.Add("Text", "cWhite", "Script")  ; Initialize second text control.
    StatusText.Move(CtPixel(ScriptActiveIndicatorPos[1], "X"), CtPixel(ScriptActiveIndicatorPos[2], "Y"))  ; Move the second text control to a different position.
	HealthPotText := MyGui.Add("Text", "cWhite", "H")
    HealthPotText.Move(CtPixel(AutoPotHealthIndicatorPos[1], "X"), CtPixel(AutoPotHealthIndicatorPos[2], "Y"))
	ManaPotText := MyGui.Add("Text", "cWhite", "M")
    ManaPotText.Move(CtPixel(AutoPotManaIndicatorPos[1], "X"), CtPixel(AutoPotManaIndicatorPos[2], "Y"))

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
	
	; Get current mouse position in Pixels
	MouseGetPos(&MouseX, &MouseY)

	; Format the coordinates as a percentage string with two decimal places
	CoordText.Value := Format("X: {:.2f}%, Y: {:.2f}%", CtPercent(MouseX, "X"), CtPercent(MouseY, "Y"))

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
    else ;ToolTip("HB Normal/Windowed")
    {
		RedrawCount := 0
		WinMaximize(WinTitle)
    }
}
