; ══════════════════════════════════════════════════════  Optional Systems ══════════════════════════════════════════════════════ ;

if (IniRead(ConfigFile, "Settings", "CheckForMinimize") == "true")
{
	CheckForMinimize()
}

if (IniRead(ConfigFile, "Settings", "UseAutoPotting") == "true")
{
	SetTimer(AutoPot, 100)
}

if (IniRead(ConfigFile, "Settings", "DebugMode") == "true")
{
	bDebugMode := true
}

if (IniRead(ConfigFile, "Settings", "ShowGUI") == "true")
{
	bShowGUI := true
}

if (IniRead(ConfigFile, "Settings", "UnbindKeys") == "true")
{
	UnbindKeys := HotkeyUnbindClass() ; Obj instance that unbinds a bunch of keys by setting hotkeys to do nothing
}

; ══════════════════════════════════════════════════════  Load From Config ══════════════════════════════════════════════════════ ;

LoadSpellsFromConfig() {
	Section := IniRead(ConfigFile, "Spells")

	if (Section)
	{
		Loop Parse, Section, "`n", "`r"
		{
			; Split the line into its components using comma as delimiter
			SplitLine := StrSplit(A_LoopField, ",")

			; Extract individual components (1 is unused as it only helps the user know what they are reassigning)
			SpellCircle := SplitLine[2]
			Coord := SplitLine[3]
			Hk := SplitLine[4]

			; Initialize optional variables with default values
			Img := ""  ; Default value for image
			Dur := ""  ; Default value for duration

			; Check if Img and Dur exist in SplitLine
			if (SplitLine.Length >= 5) {
				Img := SplitLine[5]
			}
			if (SplitLine.Length >= 6) {
				Dur := SplitLine[6]
			}

			; Create a new instance of the SpellInfo class with the extracted components
			SpellInstance := SpellInfo(SpellCircle, Coord, Hk, Img, Dur)
		}
	}
}

LoadCommandsFromConfig(SectionName) {
	Section := IniRead(ConfigFile, SectionName)

	if (Section)
	{
		Loop Parse, Section, "`n", "`r"
		{
			; Split the line into its components using comma as delimiter
			SplitLine := StrSplit(A_LoopField, ",")

			; Extract individual components (1 is unused as it only helps the user know what they are reassigning)
			Command := SplitLine[2]
			Key := SplitLine[3]

			CommandInstance := CommandInfo(Key, Command)
		}
	}
}

LoadSpellsFromConfig()
LoadCommandsFromConfig("Script")
LoadCommandsFromConfig("Character")
LoadCommandsFromConfig("Leveling")
LoadCommandsFromConfig("Messages")
LoadCommandsFromConfig("Inventory")
LoadCommandsFromConfig("Other")
