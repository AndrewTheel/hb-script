class SpellInfo {
	__Initialize() { ; Initialize instance variables *Important: will flag errors if omitted* TODO: perhaps these just need to be class variables
		MagicPage := ""
		YCoord := ""
		HotKeyName := ""
		SpellEffectImg := ""
		SpellEffectDuration := ""
	}

    __New(aMagicPage, aCoord, aHK, eImg := "", eDuration := "") { ; Constructor
        this.MagicPage := aMagicPage
        this.YCoord := aCoord
		this.HotKeyName := aHK
		this.SpellEffectImg := eImg
		this.SpellEffectDuration := eDuration

		Hotkey(this.HotKeyName, this.CastSpell.Bind(this)) ; Bind the hotkey so whenever it is struck it calls the CastSPell function
    }

	CastSpell(*) {
		Global SpellHorizontalPos, CastingEffectSpell

		if WinActive(WinTitle) ; This supposedly stops the hotkey from working outside of the HB client
		{
			BlockInput true
			MouseGetPos &begin_x, &begin_y ; Get the position of the mouse

			if (GetKeyState("LButton", "P")) ; if we are holding down m1, like when we are chasing someone, the cast should interrupt the run so the cast doesn't fail
			{
				Send("{LButton up}")
			}

			Send this.MagicPage ; Open Magic menu tab
			MouseClick "left", SpellHorizontalPos, this.YCoord, 1, 0 ; Click spell coords
			MouseMove begin_x, begin_y ; Move mouse back to original position
			Sleep 50
			BlockInput false

			if (this.SpellEffectDuration != "")
			{	
				CastingEffectSpell := [] ; Must set the variable as an array to start.
				CastingEffectSpell.Push(this.SpellEffectImg)
				CastingEffectSpell.Push(this.SpellEffectDuration)
			}
		}
	}
}