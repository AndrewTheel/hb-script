; Setup variables for pixels in center of each adjacent square
CenterX := ScreenResolution[1] / 2
CenterY := ScreenResolution[2] / 2

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

; Function to shuffle an array
RandomizeArray(&arr) {
	for i, _ in arr {
        rndIndex := Random(1, arr.Length) ; Generate a random index between 1 and the length of the array
        ; Swap the current element with the random one
        temp := arr[i]
        arr[i] := arr[rndIndex]
        arr[rndIndex] := temp
    }
}

Chance(percentage) {
    return Random(1, 100) <= percentage
}

CheckPixelMovement(x, y)
{
	pixelColor := PixelGetColor(x, y)
	Sleep(1)
	pixelColor2 := PixelGetColor(x, y)

	if (pixelColor != pixelColor2)
	{
		return true ; movement detected
	}

	return false ; no movement detected at pixel
}

FindAdjacentMovement()
{
	; Calculate pixel offsets for each direction
	XOffset := CtPixel(SquarePercentageX, "X")
	YOffset := CtPixel(SquarePercentageY, "Y")

	; Create offset arrays (AHK arrays start from index 1)
	XOffsets := [-XOffset, 0, XOffset]
	YOffsets := [-YOffset, 0, YOffset]

	; Define coordinates for each direction using valid object literal syntax
	directions := Object()
	directions.RightDown := [CenterX + XOffsets[3], CenterY + YOffsets[3]]
	directions.LeftDown := [CenterX + XOffsets[1], CenterY + YOffsets[3]]
	directions.LeftUp := [CenterX + XOffsets[1], CenterY + YOffsets[1]]
	directions.RightUp := [CenterX + XOffsets[3], CenterY + YOffsets[1]]
	directions.Up := [CenterX + XOffsets[2], CenterY + (YOffsets[1] * 2)]
	directions.Down := [CenterX + XOffsets[2], CenterY + YOffsets[3]]
	directions.Left := [CenterX + XOffsets[1], CenterY + YOffsets[2]]
	directions.Right := [CenterX + XOffsets[3], CenterY + YOffsets[2]]

	AdjacentSquares := [directions.RightDown, directions.LeftDown, directions.LeftUp, directions.RightUp, directions.Up, directions.Down, directions.Left, directions.Right] ; Don't include UpCoords as the player character is always moving
	Coords := [0, 0]

	; Shuffle the AdjacentSquares array to randomize iteration order
	RandomizeArray(&AdjacentSquares) ; Pass by reference

	; Check each adjacent square for pixel changes
	for square in AdjacentSquares {
		pixelColor := PixelGetColor(square[1], square[2])
		Sleep(1)
		pixelColor2 := PixelGetColor(square[1], square[2])

		if (pixelColor != pixelColor2) {
			Coords := [square[1], square[2]] ;Movement detected, return with coords
			return Coords
		}
	}

	return false
}

RandomAdjacent()
{
	; Calculate pixel offsets for each direction
	XOffset := CtPixel(SquarePercentageX, "X")
	YOffset := CtPixel(SquarePercentageY, "Y")

	; Create offset arrays (AHK arrays start from index 1)
	XOffsets := [-XOffset, 0, XOffset]
	YOffsets := [-YOffset, 0, YOffset]

	; Define coordinates for each direction using valid object literal syntax
	directions := Object()
	directions.RightDown := [CenterX + XOffsets[3], CenterY + YOffsets[3]]
	directions.LeftDown := [CenterX + XOffsets[1], CenterY + YOffsets[3]]
	directions.LeftUp := [CenterX + XOffsets[1], CenterY + YOffsets[1]]
	directions.RightUp := [CenterX + XOffsets[3], CenterY + YOffsets[1]]
	directions.Up := [CenterX + XOffsets[2], CenterY + YOffsets[1]]
	directions.Down := [CenterX + XOffsets[2], CenterY + YOffsets[3]]
	directions.Left := [CenterX + XOffsets[1], CenterY + YOffsets[2]]
	directions.Right := [CenterX + XOffsets[3], CenterY + YOffsets[2]]

	AdjacentSquares := [directions.RightDown, directions.LeftDown, directions.LeftUp, directions.RightUp, directions.Up, directions.Down, directions.Left, directions.Right] ; Don't include UpCoords as the player character is always moving

	; Get a random index within the array bounds
    RandomIndex := Random(1, AdjacentSquares.Length)
    return AdjacentSquares[RandomIndex]
}

CriticalStrikeNearby()
{
	Static distance := 2

	TempGui := Gui()
	TempGui.Opt("+AlwaysOnTop +ToolWindow -Caption Disabled E0x8000000") ;E0x8000000 makes it so you cannot click the GUI stuff (Disabled might be unnecessary)
	TempGui.BackColor := "EEAA99"

    ; Initialize an empty array for the coordinates
    coords := []

    ; Calculate the pixel offset for the given distance
    XOffset := CtPixel(SquarePercentageX * distance, "X")
    YOffset := CtPixel(SquarePercentageY * distance, "Y")

    ; Top and Bottom sides
    x := -distance
    while (x <= distance) {
        coords.Push([CenterX + CtPixel(SquarePercentageX * x, "X"), CenterY - YOffset]) ; Top side
        coords.Push([CenterX + CtPixel(SquarePercentageX * x, "X"), CenterY + YOffset]) ; Bottom side
        x++
    }

    ; Left and Right sides
    y := -(distance - 1)
    while (y <= (distance - 1)) {
        coords.Push([CenterX - XOffset, CenterY + CtPixel(SquarePercentageY * y, "Y")]) ; Left side
        coords.Push([CenterX + XOffset, CenterY + CtPixel(SquarePercentageY * y, "Y")]) ; Right side
        y++
    }

    ; Create a text control for each coordinate in coords
    for coord in coords {
        TempGui.Add("Text", "x" coord[1] " y" coord[2] " w15 h15 Center cFuchsia", " .")
    }

	WinSetTransColor(TempGui.BackColor " 200", TempGui)
    TempGui.Show("x0 y0 w" ScreenResolution[1] " h" ScreenResolution[2] " NA NoActivate") ; Show the GUI without activating it

    ; Check each square for pixel changes
    for coord in coords {
        pixelColor := PixelGetColor(coord[1], coord[2])
        Sleep(1)
        pixelColor2 := PixelGetColor(coord[1], coord[2])

        if (pixelColor != pixelColor2) {
            ; Move the mouse and critical strike location (by hold alt + rmb)
			MouseMove coord[1], coord[2], 0
			Sleep 10
			Send("{Alt down}")
			Sleep 10
			Send("{Alt up}")
            Sleep 1000

			TempGui.Destroy()
			distance := 2
            return
        }
    }

	TempGui.Destroy()

	if (distance < 4)
	{
		distance++
		CriticalStrikeNearby()
	}
	else
	{
		distance := 2
	}
}

 ; 1 = 8
 ; 2 = 16
 ; 3 = 24 squares 
 ; 4 = 32 squares
 ; 5 = 40
 ; 6 = 48

FindAndMove(bVariableRunWalk := false, MaxDistance := 6)
{
	Static distance := 2

	TempGui := Gui()
	TempGui.Opt("+AlwaysOnTop +ToolWindow -Caption Disabled E0x8000000") ;E0x8000000 makes it so you cannot click the GUI stuff (Disabled might be unnecessary)
	TempGui.BackColor := "EEAA99"

    ; Initialize an empty array for the coordinates
    coords := []

    ; Calculate the pixel offset for the given distance
    XOffset := CtPixel(SquarePercentageX * distance, "X")
    YOffset := CtPixel(SquarePercentageY * distance, "Y")

    ; Top and Bottom sides
    x := -distance
    while (x <= distance) {
        coords.Push([CenterX + CtPixel(SquarePercentageX * x, "X"), CenterY - YOffset]) ; Top side
        coords.Push([CenterX + CtPixel(SquarePercentageX * x, "X"), CenterY + YOffset]) ; Bottom side
        x++
    }

    ; Left and Right sides
    y := -(distance - 1)
    while (y <= (distance - 1)) {
        coords.Push([CenterX - XOffset, CenterY + CtPixel(SquarePercentageY * y, "Y")]) ; Left side
        coords.Push([CenterX + XOffset, CenterY + CtPixel(SquarePercentageY * y, "Y")]) ; Right side
        y++
    }

    ; Create a text control for each coordinate in coords
    for coord in coords {
        TempGui.Add("Text", "x" coord[1] " y" coord[2] " w15 h15 Center cFuchsia", " .")
    }

	WinSetTransColor(TempGui.BackColor " 200", TempGui)
    TempGui.Show("x0 y0 w" ScreenResolution[1] " h" ScreenResolution[2] " NA NoActivate") ; Show the GUI without activating it

    ; Check each square for pixel changes
    for coord in coords {
        pixelColor := PixelGetColor(coord[1], coord[2])
        Sleep(1)
        pixelColor2 := PixelGetColor(coord[1], coord[2])

        if (pixelColor != pixelColor2) {
            ; Move the mouse and click at the detected coordinate
			MouseMove coord[1], coord[2], 0
			Sleep 10
			Send("{LButton down}")
			Sleep 10
			Send("{LButton up}")
            Sleep 200
            MouseMove CenterX, CenterY
            Loop distance {
				if (bVariableRunWalk && Chance(50)) {
					Send "{Shift down}"
					Sleep 300  ; Small delay to simulate holding Shift
					Send "{Shift up}"
				}
				else {
					Sleep 300
				}
			}

			TempGui.Destroy()
			distance := 2
            return
        }
    }

	TempGui.Destroy()

	if (distance < MaxDistance)
	{
		distance++
		FindAndMove(, MaxDistance)
	}
	else
	{
		distance := 2
	}
}

MoveNearby(distance := 3, direction := "any") {
    Static i := 0
    Static UnmovedSquares := []

	; Calculate pixel offsets for each direction
	XOffset := CtPixel(SquarePercentageX * distance, "X")
	YOffset := CtPixel(SquarePercentageY * distance, "Y")

	; Create offset arrays (AHK arrays start from index 1)
	XOffsets := [-XOffset, 0, XOffset]
	YOffsets := [-YOffset, 0, YOffset]

	; Define coordinates for each direction using valid object literal syntax
	directions := Object()
	directions.RightDown := [CenterX + XOffsets[3], CenterY + YOffsets[3]]
	directions.LeftDown := [CenterX + XOffsets[1], CenterY + YOffsets[3]]
	directions.LeftUp := [CenterX + XOffsets[1], CenterY + YOffsets[1]]
	directions.RightUp := [CenterX + XOffsets[3], CenterY + YOffsets[1]]
	directions.Up := [CenterX + XOffsets[2], CenterY + YOffsets[1]]
	directions.Down := [CenterX + XOffsets[2], CenterY + YOffsets[3]]
	directions.Left := [CenterX + XOffsets[1], CenterY + YOffsets[2]]
	directions.Right := [CenterX + XOffsets[3], CenterY + YOffsets[2]]

	Coords := []
	bShouldMove := false

    ; Handle 'any' direction by randomizing adjacent squares
    if (direction == "any") {
        if (i == 0) {
            UnmovedSquares := [directions.RightDown, directions.LeftDown, directions.LeftUp, directions.RightUp, directions.Up, directions.Down, directions.Left, directions.Right]
            RandomizeArray(&UnmovedSquares) ; Shuffle the array to randomize the order
        }
        ; Get the next coordinate and remove it from UnmovedSquares
		if (UnmovedSquares.Length > 0)
		{
			Coords := UnmovedSquares.Pop()
			bShouldMove := true
		}
    } else {
        ; Handle specific direction
        Coords := directions.%direction%
		bShouldMove := true
    }

    ; Perform mouse actions
	if (bShouldMove)
	{
		MouseMove Coords[1], Coords[2], 0
		Sleep 10
		Send("{LButton down}")
		Sleep 10
		Send("{LButton up}")
		Sleep 10
		MouseMove CenterX, CenterY	
		Sleep 300 * distance
	}

    ; Reset the counter when all squares have been moved to
    if (direction == "any" && UnmovedSquares.Length == 0) {
        i := 0
    } else if (direction == "any") {
        i++
    }
}

StoneGolemPit()
{
	MoveNearby(distance := 6, direction := "Right")
	CastBerserk()
	MoveNearby(distance := 6, direction := "Left")
}

CastInvis(*)
{
	Global Effects

	Send "^{4}" ; Open Magic menu tab
	Sleep 10
	MouseMove CtPixel(SpellHorizontalPos, "X"), CtPixel(41.73, "Y"), 0
	Sleep 5
	Send("{LButton down}")
	Sleep 10
	Send("{LButton up}")
	MouseMove CenterX, CenterY
	Sleep 1800
	Send("{LButton down}")
	Sleep 10
	Send("{LButton up}")
	Sleep 500

	Effects.Push(StatusEffectIndicator("images\Invis.png", 60, ""))
}


CastPFM(*)
{
	Global Effects

	Send "^{4}" ; Open Magic menu tab
	Sleep 10
	MouseMove CtPixel(SpellHorizontalPos, "X"), CtPixel(44.72, "Y"), 0
	Sleep 5
	Send("{LButton down}")
	Sleep 10
	Send("{LButton up}")
	MouseMove CenterX, CenterY
	Sleep 1800
	Send("{LButton down}")
	Sleep 10
	Send("{LButton up}")
	Sleep 500

	Effects.Push(StatusEffectIndicator("images\PFM.png", 60, ""))
}

CastBerserk(*)
{
	Global Effects

	Send "^{6}" ; Open Magic menu tab
	Sleep 10
	MouseMove CtPixel(SpellHorizontalPos, "X"), CtPixel(35.7638, "Y"), 0
	Sleep 5
	Send("{LButton down}")
	Sleep 10
	Send("{LButton up}")
	MouseMove CenterX, CenterY
	Sleep 1800
	Send("{LButton down}")
	Sleep 10
	Send("{LButton up}")
	Sleep 500

	Effects.Push(StatusEffectIndicator("images\Berserk.png", 60, ""))
}

RandomBehavior(x1 := 100, x2 := 50, x3 := 25, x4:= 0) {
    ; Define the odds for each case
    odds := [x1, x2, x3, x4]
	;odds := [100, 50, 25, 5]

    ; Calculate the total odds
    totalOdds := 0
    for each, odd in odds
        totalOdds += odd

    ; Generate a random number between 1 and totalOdds
    rand := Random(1, totalOdds)

    ; Determine which case to execute based on the random number
    cumulativeOdds := 0
    for index, odd in odds {
        cumulativeOdds += odd
        if (rand <= cumulativeOdds) {
            Switch index {
                Case 1:
					Send("{RButton down}")
					AttackInCircles()
					Send("{RButton up}")
                    return
                Case 2:
                    RunInCircles()
                    return
                Case 3:
                    LookBackAndForth()
                    return
                Case 4:
                    GoInvisibleAndWait()
                    return
            }
        }
    }
}

; Function to run in circles
RunInCircles(bAlwaysRun := true) {
	if (bAlwaysRun) {
		Send("^{R}")
	}

    MoveNearby(4, "RightDown")
	MoveNearby(4, "RightUp")
	MoveNearby(5, "LeftUp")
	MoveNearby(5, "LeftDown")

	if (bAlwaysRun) {
		Send("^{R}")
	}
}

AttackInCircles(_Speed := 25, _SpeedVariance := 20) {
	; Calculate pixel offsets for each direction
	XOffset := CtPixel(SquarePercentageX, "X")
	YOffset := CtPixel(SquarePercentageY, "Y")

	; Create offset arrays (AHK arrays start from index 1)
	XOffsets := [-XOffset, 0, XOffset]
	YOffsets := [-YOffset, 0, YOffset]

	; Define coordinates for each direction using valid object literal syntax
	directions := Object()
	directions.RightDown := [CenterX + XOffsets[3], CenterY + YOffsets[3]]
	directions.LeftDown := [CenterX + XOffsets[1], CenterY + YOffsets[3]]
	directions.LeftUp := [CenterX + XOffsets[1], CenterY + YOffsets[1]]
	directions.RightUp := [CenterX + XOffsets[3], CenterY + YOffsets[1]]
	directions.Up := [CenterX + XOffsets[2], CenterY + YOffsets[1]]
	directions.Down := [CenterX + XOffsets[2], CenterY + YOffsets[3]]
	directions.Left := [CenterX + XOffsets[1], CenterY + YOffsets[2]]
	directions.Right := [CenterX + XOffsets[3], CenterY + YOffsets[2]]

	AdjacentSquares := [directions.RightDown, directions.Right, directions.RightUp, directions.Up, directions.LeftUp, directions.Left, directions.LeftDown, directions.Down]
	
	Loop Random(1,3) {
		for square in AdjacentSquares {
			MouseMove square[1], square[2], 0
			Sleep Max(0, _Speed + Random(-_SpeedVariance, _SpeedVariance))
		}
	}

	MouseMove CenterX, CenterY
	Sleep 100
}

LookBackAndForth() {
    Sleep 10
	Send("{RButton down}")
	
	Loop Random(1,5)
	{
		MouseMove CtPixel((50 - SquarePercentageX), "X"), CtPixel(50, "Y")
		Sleep 10
		MouseMove CtPixel((50 + SquarePercentageX), "X"), CtPixel(50, "Y")
		Sleep 10
	}

	Send("{RButton up}")
	Sleep 10
}

; Function to go invisible and wait for an interval
GoInvisibleAndWait() {
}
  
StoneGolemLeveling(*)
{
	global stopFlag 

	MouseSpeed := 10
	LastIdleTime := A_TickCount
	ElapsedTime_IdleTime := 0
	
	StartTime_MoveTime := A_TickCount  ; Capture the start time in milliseconds
	Interval_MoveTime := 10000

	StartTime_EatFood := A_TickCount  ; Capture the start time in milliseconds
	Interval_EatFood := 300000

	StartTime_RandomBehavior := A_TickCount  ; Capture the start time in milliseconds
	Interval_RandomBehavior := 15000

	StartTime_StoneGolemPit := A_TickCount
	Interval_StoneGolemPit := 55000

	dz_offset := 2 ; this value will end up creating a *2 sized square zone to check

	if WinActive(WinTitle) ; This supposedly stops the hotkey from working outside of the HB client
	{
		BlockInput "MouseMove"
		MouseMove CenterX, CenterY  ;Move mouse to center screen
		SendTextMessage("/shiftpickup")
		Send("{RButton down}")

		Loop {
			ElapsedTime_EatFood := A_TickCount - StartTime_EatFood
			ElapsedTime_RandomBehavior := A_TickCount - StartTime_RandomBehavior
			ElapsedTime_StoneGolemPit := A_TickCount - StartTime_StoneGolemPit

			if (ElapsedTime_StoneGolemPit >= Interval_StoneGolemPit)
			{
				Send("{RButton up}")
				StoneGolemPit()
				Send("{RButton down}")
				StartTime_StoneGolemPit := A_TickCount
			}
			else
			{
				MovementCoords := FindAdjacentMovement()
				if (MovementCoords)
				{
					MouseMove MovementCoords[1], MovementCoords[2], MouseSpeed

					Loop {
						Sleep 100
					} Until !CheckPixelMovement(MovementCoords[1], MovementCoords[2])
				}
				else
				{
					MouseMove CenterX, CenterY

					ElapsedTime_IdleTime := A_TickCount - LastIdleTime

					if (ElapsedTime_EatFood >= Interval_EatFood)
					{
						Send("{RButton up}")
						EatFood()
						Sleep 100
						MouseMove CenterX, CenterY
						Sleep 100
						Send("{RButton down}")
						StartTime_EatFood := A_TickCount
					}
					else if (ElapsedTime_RandomBehavior >= Interval_RandomBehavior)
					{
						Send("{RButton up}")
						RandomBehavior(100, 0, 0, 0)
						Send("{RButton down}")
						Interval_RandomBehavior := Random(5000,15000)
						StartTime_RandomBehavior := A_TickCount
					}
					
				}
			}	
		
			if (stopFlag) {
				stopFlag := false
				Break
			}
		}

		SendTextMessage("/shiftpickup")
		Send("{RButton up}")
		BlockInput "MouseMoveOff"
	}
}

PublicPitLeveling(*)
{
	global stopFlag 

	Static bAlt := false

	MouseSpeed := 10
	LastIdleTime := A_TickCount
	ElapsedTime_IdleTime := 0
	
	StartTime_BerserkTime := A_TickCount
	Interval_BerserkTime := 60000

	StartTime_EatFood := A_TickCount  ; Capture the start time in milliseconds
	Interval_EatFood := 300000

	StartTime_RandomBehavior := A_TickCount  ; Capture the start time in milliseconds
	Interval_RandomBehavior := 15000

	StartTime_StoneGolemPit := A_TickCount
	Interval_StoneGolemPit := 55000

	dz_offset := 2 ; this value will end up creating a *2 sized square zone to check

	if WinActive(WinTitle) ; This supposedly stops the hotkey from working outside of the HB client
	{
		BlockInput "MouseMove"
		MouseMove CenterX, CenterY  ;Move mouse to center screen
		Send("{RButton down}")

		SendTextMessage("/shiftpickup")

		Loop {
			ElapsedTime_EatFood := A_TickCount - StartTime_EatFood
			ElapsedTime_BerserkTime := A_TickCount - StartTime_BerserkTime
			ElapsedTime_RandomBehavior := A_TickCount - StartTime_RandomBehavior
			ElapsedTime_StoneGolemPit := A_TickCount - StartTime_StoneGolemPit

			MovementCoords := FindAdjacentMovement()
			if (MovementCoords)
			{
				MouseMove MovementCoords[1], MovementCoords[2], MouseSpeed

				if (Chance(8)) {
					Send("{Alt down}")
					Sleep 10
					Send("{Alt up}")
					Continue
				}

				Loop {
					Sleep 200
				} Until !CheckPixelMovement(MovementCoords[1], MovementCoords[2])
			}
			else
			{
				MouseMove CenterX, CenterY

				ElapsedTime_IdleTime := A_TickCount - LastIdleTime

				if (Chance(60)) {
					MovementCoords := RandomAdjacent()
					MouseMove MovementCoords[1], MovementCoords[2]
					Continue
				}

				if (Chance(10)) {
					Send("^{R}")
					Continue
				}

				if (Chance(25)) {
					FindAndMove(true, 3)
					Continue
				}

				if (Chance(20)) {
					AttackInCircles()
					Continue
				}

				if (ElapsedTime_IdleTime > 20000)
				{
					if (Chance(50)) {
						CriticalStrikeNearby()
						Continue
					}

					Send("{RButton up}")
					FindAndMove(true)
					Send("{RButton down}")

					LastIdleTime := A_TickCount
				}
				else if (ElapsedTime_EatFood >= Interval_EatFood)
				{
					Send("{RButton up}")
					EatFood()
					Sleep 100
					MouseMove CenterX, CenterY
					Sleep 100
					Send("{RButton down}")
					StartTime_EatFood := A_TickCount
				}
				else if (ElapsedTime_BerserkTime >= Interval_BerserkTime)
				{
					Send("{RButton up}")
					if (bAlt) {
						MoveNearby(distance := 3, direction := "Right")
					}
					else {
						MoveNearby(distance := 3, direction := "Left")
					}
					bAlt := !bAlt
					CastBerserk()
					Send("{RButton down}")
					Interval_BerserkTime := Random(61000,120000)
					StartTime_BerserkTime := A_TickCount
				}
				else if (ElapsedTime_RandomBehavior >= Interval_RandomBehavior)
				{
					Send("{RButton up}")
					RandomBehavior(70, 30, 80, 0)
					Send("{RButton down}")
					Interval_RandomBehavior := Random(8000,25000)
					StartTime_RandomBehavior := A_TickCount
				}
			}
		
			if (stopFlag) {
				stopFlag := false
				Break
			}
		}

		SendTextMessage("/shiftpickup")
		Send("{RButton up}")
		BlockInput "MouseMoveOff"
	}
}