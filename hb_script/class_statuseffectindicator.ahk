class StatusEffectIndicator {
    static statusWidth := 32
    static statusHeight := 32
    static offset := 32
    static instances := []

    __New(iconPath, initialTime, guiTitle) {
        this.iconPath := iconPath
        this._timeRemaining := initialTime
        this._isActive := false
        this.guiTitle := guiTitle
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
        this.Gui.Add("Picture", "x0 y0 w" . (StatusEffectIndicator.statusWidth) . " h" . (StatusEffectIndicator.statusHeight / 2), this.iconPath)  ; Add icon with fixed size
        
        ; Add text control for timer with default text '00'
        this.StatusText := this.Gui.Add("Text", "x0 y" . (StatusEffectIndicator.statusHeight / 2) . " w" . StatusEffectIndicator.statusWidth " h32 Center", "0000")
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
        return (index - 1) * StatusEffectIndicator.offset
    }

    ShowIndicator() {       
        ; Show the GUI
        this.Gui.Show("x" . this.GetPosition() " y0 w" . StatusEffectIndicator.statusWidth " h" . StatusEffectIndicator.statusHeight " NA NoActivate")
        
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