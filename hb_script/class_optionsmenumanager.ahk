class OptionsMenuManager {
    ; Member variables
    optionsGui := ""  ; Initialize as empty string
	optionMenuLabels := Array()
    optionFunctionNames := Array()

    __New(optionNames, functionNames) { ; Constructor
        ; Validate parameters
        if (optionNames.Length != functionNames.Length || optionNames.Length > 9) {
            MsgBox("Error: optionMenuLabels and optionFunctionNames must have the same number of elements. And not exceed 9")
            return
        }

		for index, optionName in optionNames {
            this.optionMenuLabels.Push(optionName)
            this.optionFunctionNames.Push(functionNames[index])
        }
    }

	; Function to show the dialog
    showOptionsDialog() {
        if (this.optionsGui == "")
        {
            this.optionsGui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000", "Select an Option")
            this.optionsGui.BackColor := 0xCCFFFFFF

			for index, optionName in this.optionMenuLabels
            {
				BoundFunc := ObjBindMethod(this, "CallFunction", index)
				btn := this.optionsGui.AddButton("w250 h25 Left", optionName).OnEvent("Click", BoundFunc)
            }

            WinSetTransColor(this.optionsGui.BackColor " 150", this.optionsGui)

            MouseGetPos &xPos, &yPos ; Get the position of the mouse
            this.optionsGui.Show("x" xPos + 35 " y" yPos + 35 " NA NoActivate")
        }
        else
        {
            this.DestroyOptionsGUI()
        }
    }

    ; Method to destroy this GUI
    DestroyOptionsGUI() {
		global activeMenuManager

        if IsObject(this.optionsGui)
        {
            this.optionsGui.Destroy()
            this.optionsGui := ""
            Sleep 50
        }

		activeMenuManager := ""
    }

	; Method to call the function by index with validation
    CallFunction(index, *) {
        ; Validate index
        if (index < 1 || index > this.optionFunctionNames.Length || !WinActive(WinTitle))
		{
            return
        }

        funcName := this.optionFunctionNames[index]

        this.DestroyOptionsGUI()  

        ; Try to call the function and handle any errors
        try {
            %funcName%.Call()
        } catch as e {
            MsgBox("Error: Failed to execute function '" funcName "'.`n" e.Message)
        }
    }

    ; Method to get the callback function for an option
    GetOptionCallback(n) {
        return this.optionFunctionNames[n]
    }
}