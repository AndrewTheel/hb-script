; ══════════════════════════════════════════════════════  Optional Systems ══════════════════════════════════════════════════════ ;

if (IniRead(ConfigFile, "Settings", "UseAutoPotting") == "true")
{
	SetTimer(AutoPot, 100)
}

if (IniRead(ConfigFile, "Settings", "UnbindKeys") == "true")
{
	UnbindKeys := HotkeyUnbindClass() ; Obj instance that unbinds a bunch of keys by setting hotkeys to do nothing
}

; ══════════════════════════════════════════════════════  Load From Config ══════════════════════════════════════════════════════ ;

LoadSpellsFromConfig() {
    ; Read the entire "Spells" section from the config file
    Section := IniRead(ConfigFile, "Spells")

    if (Section) {
        ; Process each line in the section
        Loop Parse, Section, "`n", "`r" {
            ; Skip comment lines and empty lines
            if (A_LoopField == "" || SubStr(A_LoopField, 1, 1) = ";") {
                Continue
            }

            ; Split the line into its components using the pipe (|) as the delimiter
            SplitLine := StrSplit(A_LoopField, "|")

            ; Remove empty elements caused by multiple pipes and trim each component
            CleanedLine := []
            for i, val in SplitLine {
                CleanedVal := Trim(val)
                if (CleanedVal != "") {
                    CleanedLine.Push(CleanedVal)
                }
            }

            ; Ensure the line has the expected number of components
            if (CleanedLine.Length < 4) {
                Continue ; Skip invalid lines
            }

            ; Extract components from the cleaned line
            Hk := CleanedLine[1]
            SpellName := CleanedLine[2]
            SpellCircle := CleanedLine[3]
            yCoord := CleanedLine[4]

            ; Initialize optional variables with default values
            Img := (CleanedLine.Length >= 5) ? CleanedLine[5] : ""  ; Default value for image
            Dur := (CleanedLine.Length >= 6) ? CleanedLine[6] : ""  ; Default value for duration

            ; Debugging output to show variable assignments
            ;MsgBox("Hotkey: " Hk "`nSpell Name: " SpellName "`nSpell Circle: " SpellCircle "`nY Coord: " yCoord "`nImage Path: " Img "`nDuration: " Dur)

            ; Create a new instance of the SpellInfo class with the extracted components
            SpellInstance := SpellInfo(SpellName, SpellCircle, yCoord, Hk, Img, Dur)
        }
    } else {
        MsgBox("Error: 'Spells' section not found in the configuration file.")
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
