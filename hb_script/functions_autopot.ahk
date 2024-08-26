AutoPot() {
	Global bTryHPPotting, bTryManaPotting, StartAutoPotHealthPos, StartAutoPotManaPos, HighHealthPos, HighManaPos

	if WinActive(WinTitle)
	{
		static LowHPDuration := 0
		static LowManaDuration := 0

		ColorHPLowFSA := "0x5A5553"
		ColorManaLowFSA := "0x424142"

		;ToolTip "HP_Start: " . PixelGetColor(StartAutoPotManaPos[1], StartAutoPotManaPos[2]) . " HP_High: " . PixelGetColor(HighManaPos[1], HighManaPos[2])
		;A_Clipboard := PixelGetColor(StartAutoPotManaPos[1], StartAutoPotManaPos[2]) . " " . PixelGetColor(HighManaPos[1], HighManaPos[2])

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