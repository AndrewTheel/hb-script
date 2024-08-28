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

FindMovement()
{
	CenterX := ScreenResolution[1] / 2
	CenterY := ScreenResolution[2] / 2

	XOffset := CtPixel(SquarePercentageX, "X")
	YOffset := CtPixel(SquarePercentageY, "Y")

	XOffsets := [-XOffset, 0, XOffset]
	YOffsets := [-YOffset, 0, YOffset]
	
	RightDownCoords := [CenterX + XOffsets[3], CenterY + YOffsets[3]]
	LeftDownCoords := [CenterX + XOffsets[1], CenterY + YOffsets[3]]
	LeftUpCoords := [CenterX + XOffsets[1], CenterY + YOffsets[1]]
	RightUpCoords := [CenterX + XOffsets[3], CenterY + YOffsets[1]]
	UpCoords := [CenterX + XOffsets[2], CenterY + YOffsets[1]]
	DownCoords := [CenterX + XOffsets[2], CenterY + YOffsets[3]]
	LeftCoords := [CenterX + XOffsets[1], CenterY + YOffsets[2]]
	RightCoords := [CenterX + XOffsets[3], CenterY + YOffsets[2]]

	AdjacentSquares := [RightDownCoords, LeftDownCoords, LeftUpCoords, RightUpCoords, DownCoords, LeftCoords, RightCoords] ; Don't include UpCoords as the player character is always moving

	Coords := [0, 0]

	for square in AdjacentSquares {
		pixelColor := PixelGetColor(square[1], square[2])

		sleepTime := Random(1, 50) ; Generate a random sleep time between 10 and 1000 milliseconds
		Sleep(sleepTime) ; Sleep for the randomly generated time

		pixelColor2 := PixelGetColor(square[1], square[2])

		if (pixelColor != pixelColor2)
		{
			Coords := [square[1], square[2]] ;Movement detected, return with coords
		}
	}

	if (Random(1, 20) = 1)  ; 1/20 chance
	{
		Coords := UpCoords
	}

	if (Coords[1] != 0)
	{
		return Coords
	}
	else
	{
		return false
	}
}

PickupAdjacentItems()
{
	; might need to unhold RButton down
	; what about monsters blocking movement?
	; what about useless items such as small pots?
	; lots of issues that will break this functionality

	; move to an adjacent square (maybe top left?)
	; pickup
	; then down 1
	; pickup
	; then down 1
	; pickup
	; then right 1
	; pickup
	; then right 1
	; pickup
	; then up 1
	; pickup
	; then up 1
	; pickup
	; then left 1
	; pickup
}

SlimeLeveling(*)
{
	global stopFlag 

	CenterX := ScreenResolution[1] / 2
	CenterY := ScreenResolution[2] / 2
	MouseSpeed := 10

	StartTime_PickUp := A_TickCount  ; Capture the start time in milliseconds
	Interval_PickUp := 60000    ; 60 seconds in milliseconds

	StartTime_EatFood := A_TickCount  ; Capture the start time in milliseconds
	Interval_EatFood := 900000    ; 60 seconds in milliseconds

	dz_offset := 2 ; this value will end up creating a *2 sized square zone to check

	if WinActive(WinTitle) ; This supposedly stops the hotkey from working outside of the HB client
	{
		BlockInput "MouseMove"
		MouseMove CenterX, CenterY  ;Move mouse to center screen
		Send("{RButton down}")

		Loop {
			MovementCoords := FindMovement()
		
    		ElapsedTime_PickUp := A_TickCount - StartTime_PickUp
			ElapsedTime_EatFood := A_TickCount - StartTime_EatFood

			if (MovementCoords)
			{
				MouseMove MovementCoords[1], MovementCoords[2], MouseSpeed
			}

			if (ElapsedTime_PickUp >= Interval_PickUp) ; time to pickup items
			{
				PickupAdjacentItems()
				StartTime_PickUp := A_TickCount  ; Capture the start time in milliseconds
			}
			else if (ElapsedTime_EatFood >= Interval_EatFood)
			{
				Send("{RButton up}")
				EatFood()
				Sleep 100
				MouseMove CenterX, CenterY
				Sleep 100
				StartTime_EatFood := A_TickCount
				Send("{RButton down}")
			}
			else 
			{
				MouseMove CenterX, CenterY
			}

			if (stopFlag) {
				stopFlag := false
				Break
			}
		}

		Send("{RButton up}")
		BlockInput "MouseMoveOff"
	}
}