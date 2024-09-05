Global RepCoolDownTime := 3600000
Global RepMessageInterval := 600000
Global TopLeftPos := []
Global TopRightPos := []
Global BottomLeftPos := []
Global BottomRightPos := []
Global PeaceModeTR_Pixel := []
Global PeaceModeBL_Pixel := []

TopLeftPos.Push(CtPixel(38.7, "X"))
TopLeftPos.Push(CtPixel(52.1, "Y"))

TopRightPos.Push(CtPixel(69.7, "X"))
TopRightPos.Push(CtPixel(52.1, "Y"))

BottomLeftPos.Push(CtPixel(38.7, "X"))
BottomLeftPos.Push(CtPixel(64.9, "Y"))

BottomRightPos.Push(CtPixel(69.7, "X"))
BottomRightPos.Push(CtPixel(64.9, "Y"))

PeaceModeBL_Pixel.Push(CtPixel(57, "X"))
PeaceModeBL_Pixel.Push(CtPixel(97.2, "Y"))

PeaceModeTR_Pixel.Push(CtPixel(58.3, "X"))
PeaceModeTR_Pixel.Push(CtPixel(94.3, "Y"))

; Example color codes to match
Global ExpectedColors := ["0x7B7352", "0x8C7329", "0x7B7352", "0x9C8439"]
Global PeaceModeColors := ["0x272727", "0x3D3D3D"]
   
CheckPixelColors() { ; Function to check if the specified pixels match the given colors
    ActualColors := []
    ActualColors.Push(PixelGetColor(TopLeftPos[1], TopLeftPos[2])) ; Get the actual colors from the specified positions
    ActualColors.Push(PixelGetColor(TopRightPos[1], TopRightPos[2]))
    ActualColors.Push(PixelGetColor(BottomLeftPos[1], BottomLeftPos[2]))
    ActualColors.Push(PixelGetColor(BottomRightPos[1], BottomRightPos[2]))

    ; Check if all colors match
    for index, color in ExpectedColors {
        if (color != ActualColors[index]) {
            return false
        }
    }
    return true
}

ActivateAutoTradeRep(*) {
    Global bAutoTradeRepping

    bAutoTradeRepping := true   
    SwitchToPeaceMode() ;Make sure we are in peace mode
    Sleep 2000
    SetTimer(AutoTradeRep, 1000)
}

SwitchToPeaceMode()
{
    Actual_BLColor := PixelGetColor(PeaceModeBL_Pixel[1], PeaceModeBL_Pixel[2])
    Actual_TRColor := PixelGetColor(PeaceModeTR_Pixel[1], PeaceModeTR_Pixel[2])

    ; If both colors do not match, then click the peace mode button to switch to it
    if (Actual_BLColor != PeaceModeColors[1] && Actual_TRColor != PeaceModeColors[2]) {
        BlockInput "MouseMove"
        MouseGetPos &begin_x, &begin_y ; Get the position of the mouse
        Sleep 10
        MouseMove CtPixel(58, "X"), CtPixel(96, "Y"), 0
        Sleep 5
        Send("{LButton down}")
        Sleep 10
        Send("{LButton up}")
        MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
        BlockInput "MouseMoveOff"        
    }
}

AutoTradeRep(*) {
    Global stopFlag, bAutoTradeRepping

    Static LastRepElapsedTime := RepCoolDownTime
    Static LastRepMessageElapsedTime := RepMessageInterval

    if (stopFlag) {
        bAutoTradeRepping := false
        stopFlag := false
        SetTimer(AutoTradeRep, 0)
        return
    }

    LastRepElapsedTime += 1000

    if (LastRepElapsedTime < RepCoolDownTime) {
        ;ToolTip "Waiting: rep cool down: " LastRepElapsedTime
        return ; Return if we are still on rep cooldown
    }
    else { ; Ready to rep
        if (LastRepMessageElapsedTime > RepMessageInterval) {
            ; We can send a trade rep request
            SendTextMessage("%Trade Rep")
            LastRepMessageElapsedTime := 0
        }
        else {
            LastRepMessageElapsedTime += 1000
        }

        ; Lets check to see if we have a trade request dialog we should accept
        if (CheckPixelColors()) {
            ; Click accept
            BlockInput "MouseMove"
			MouseGetPos &begin_x, &begin_y ; Get the position of the mouse
			MouseMove CtPixel(45, "X"), CtPixel(63, "Y"), 0
			Sleep 5
			Send("{LButton down}")
			Sleep 10
			Send("{LButton up}")
			MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
			BlockInput "MouseMoveOff"

            LastRepMessageElapsedTime := RepMessageInterval
            LastRepElapsedTime := 0
            RepButtonInst.StartTiming()
        }
    }
}

/*
+C:: ; alt+c useful for debugging
{
    ;A_Clipboard := PixelGetColor(TopLeftPos[1], TopLeftPos[2]) " " PixelGetColor(TopRightPos[1], TopRightPos[2]) " " PixelGetColor(BottomLeftPos[1], BottomLeftPos[2]) " " PixelGetColor(BottomRightPos[1], BottomRightPos[2]) 
    A_Clipboard := PixelGetColor(PeaceModeBL_Pixel[1], PeaceModeBL_Pixel[2]) " " PixelGetColor(PeaceModeTR_Pixel[1], PeaceModeTR_Pixel[2])
}
*/