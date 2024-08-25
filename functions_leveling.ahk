
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