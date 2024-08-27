AutoPot() {
	Global bTryHPPotting, bTryManaPotting

	Static bCalculatedPixelLocations := false
	Static LowHPPos := [0, 0]
	Static MidHPPos := [0, 0]
	Static HighHPPos := [0, 0]

	Static LowManaPos := [0, 0]
	Static MidManaPos := [0, 0]
	Static HighManaPos := [0, 0]

	if (!bCalculatedPixelLocations) ; avoid calc these so often
	{
		LowHPPos[1] := CtPixel(13.5, "X")
		LowHPPos[2] := CtPixel(94.1, "Y")

		MidHPPos[1] := CtPixel(13.0 + (12.5 * (AutoPotLifeAtPercent * 0.01)), "X") ; 12.5 is roughly the horizontal % of screen the healthbar takes up, 13% is where it starts, 25.5% is where it ends
		MidHPPos[2] := CtPixel(93.3, "Y") ;93.3 may need tweaking depending on res (we can't use the middle value as "poisoned" status can get in the way!)

		HighHPPos[1] := CtPixel(25.0, "X")
		HighHPPos[2] := CtPixel(94.1, "Y")

		;mana

		LowManaPos[1] := CtPixel(13.5, "X")
		LowManaPos[2] := CtPixel(97.8, "Y")

		MidManaPos[1] := CtPixel(13.0 + (12.5 * (AutoPotManaAtPercent * 0.01)), "X") ; 12.5 is roughly the horizontal % of screen the healthbar takes up, 13% is where it starts, 25.5% is where it ends
		MidManaPos[2] := CtPixel(97.8, "Y") ;93.3 may need tweaking depending on res

		HighManaPos[1] := CtPixel(25.0, "X")
		HighManaPos[2] := CtPixel(97.8, "Y")

		bCalculatedPixelLocations := true
	}

	if WinActive(WinTitle)
	{
		static LowHPDuration := 0
		static LowManaDuration := 0

		LifeRed := "0xd83c2b"
		ManaBlue := "0x3e45d8"
		EmptyGrey := "0x5e5b58"
		
		;ToolTip "HP_Start: " . PixelGetColor(StartAutoPotManaPos[1], StartAutoPotManaPos[2]) . " HP_High: " . PixelGetColor(HighManaPos[1], HighManaPos[2])
		;A_Clipboard := PixelGetColor(StartAutoPotManaPos[1], StartAutoPotManaPos[2]) . " " . PixelGetColor(HighManaPos[1], HighManaPos[2])

		; Check to make sure the low HP area is actually red (this can help prevent the system from randomly drinking pots, esp after minimize)
		if IsColorInRange(LowHPPos[1], LowHPPos[2], LifeRed, 35) 
		{	; Now make sure we are not on full health && we don't have health at desired %
			if IsColorInRange(HighHPPos[1], HighHPPos[2], EmptyGrey, 35) && !IsColorInRange(MidHPPos[1], MidHPPos[2], LifeRed, 35)
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
		}
		else
		{
			LowHPDuration := 0
			bTryHPPotting := true
		}

		; Check low Mana
		if IsColorInRange(LowManaPos[1], LowManaPos[2], ManaBlue, 35) 
		{	; Now make sure we are not on full mana && we don't have mana at desired %
			if IsColorInRange(HighManaPos[1], HighManaPos[2], EmptyGrey, 35) && !IsColorInRange(MidManaPos[1], MidManaPos[2], ManaBlue, 35)
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