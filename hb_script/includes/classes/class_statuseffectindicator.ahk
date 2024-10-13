class StatusEffectIndicator {
    static instances := []

    __New(iconPath, initialTime, guiTitle) {
        this.iconPath := iconPath
        this._timeRemaining := initialTime
        this._isActive := false
        this.guiTitle := guiTitle
        this.statusWidth := 32
        this.statusHeight := 32
        this.offset := 7
        this.CreateGui()
        SetTimer(this.UpdateTimer.Bind(this), 1000)  ; Set a timer to call UpdateTimer every second
        StatusEffectIndicator.instances.Push(this)  ; Track this instance
		this.Start()
    }

	; Define IsActive property
    IsActive() {
        return this._isActive
    }
    
    CreateGui() {
        this.Gui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000 -Border")
        this.Gui.BackColor := "EEAA99"
		WinSetTransColor("EEAA99", this.Gui.Hwnd)
        this.Gui.Add("Picture", "x" this.offset " y0 w" . (this.statusWidth - 2 * this.offset) . " h" . (this.statusHeight / 2), this.iconPath)  ; Add icon with fixed size
        
        ; Add text control for timer with default text '00'
        this.StatusText := this.Gui.Add("Text", "x0 y" . (this.statusHeight / 2) . " w" . this.statusWidth " h32 Center", "0000")
        this.StatusText.SetFont("s" CalculateFontSize(1) " cYellow", "Segoe UI")  ; Set font size, color, and font
        
        ; Show the GUI to get its Hwnd and set the position
        this.ShowIndicator()
    }

    GetPosition() {
        ; Initialize the index to -1 (indicating not found)
        index := -1
        
        ; Iterate through the instances array to find the index of this instance
        for i, instance in StatusEffectIndicator.instances {
            if (instance = this) {
                index := i
                break
            }
        }

        ; Calculate the position based on the index
        ; Since AutoHotkey arrays are 1-based, adjust index by subtracting 1
        return (index - 1) * this.statusWidth
    }

    ShowIndicator() {       
        ; Show the GUI
        this.Gui.Show("x" . this.GetPosition() " y4 w" . this.statusWidth " h" . this.statusHeight " NA NoActivate")
        
        ; Ensure the window stays on top and non-interactive
        WinSetAlwaysOnTop(1, this.Gui.Hwnd)
        WinSetExStyle("+0x80000", this.Gui.Hwnd)  ; WS_EX_NOACTIVATE
    }
    
    Start() {
        this._isActive := true
    }

	Delete() {
		this._isActive := false
		this.Gui.Destroy()
		; Remove this instance from the array

		for index, instance in StatusEffectIndicator.instances {
			if (instance = this) {
				StatusEffectIndicator.instances.RemoveAt(index)
				break
			}
		}
	}
    
    UpdateTimer() {
        if (this._isActive) {
            if (this._timeRemaining > 0) {
                this._timeRemaining := this._timeRemaining - 1
                this.StatusText.Text := this._timeRemaining  ; Update the text control with the new time
                this.ShowIndicator()
            } else {
                this.Delete()
            }
        }
    }
}