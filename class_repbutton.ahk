class RepButton {
    static statusWidth := 128
    static statusHeight := 64

    __New(RepCoolDownTime) {
        this._repCountDown := 1
        this._isReady := true
        this._CoolDownTime := RepCoolDownTime

        this.readyicon := "images\RepReady.png"
        this.usedicon := "images\RepUsed.png"

        this.CreateGui()
        SetTimer(this.UpdateButton.Bind(this), 1000)  ; Set a timer to call UpdateTimer every second
    }

	; Define IsActive property
    IsActive() {
        return this._isReady
    }
    
    CreateGui() {
        this.Gui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000 -Border")
        this.Gui.BackColor := "EEAA99"
		WinSetTransColor("EEAA99", this.Gui.Hwnd)

        ; Add the first picture for the 'ready' icon
        this.PictureReady := this.Gui.Add("Picture", "x0 y0 w" RepButton.statusWidth " h" RepButton.statusHeight, this.readyicon)
        this.PictureReady.Visible := true  ; Initially show this picture
        
        ; Add the second picture for the 'used' icon
        this.PictureUsed := this.Gui.Add("Picture", "x0 y0 w" RepButton.statusWidth " h" RepButton.statusHeight, this.usedicon)
        this.PictureUsed.Visible := false  ; Initially hide this picture
               
        ; Add text control for timer with default text '00'
        this.StatusText := this.Gui.Add("Text", "x0 y" . RepButton.statusHeight . " w" . RepButton.statusWidth . " h24 Center", "00")
        this.StatusText.SetFont("s12 cYellow", "Arial")  ; Set font size, color, and font
        this.StatusText.Visible := false

        ; Show the GUI to get its Hwnd and set the position
        this.ShowIndicator()

        ; Add a click event for the button
        BoundFunc := ObjBindMethod(this, "ButtonClick")
        this.PictureReady.OnEvent("Click", BoundFunc)
        this.PictureUsed.OnEvent("Click", BoundFunc)
    }

    ShowIndicator() {       
        ; Show the GUI
        this.Gui.Show("x2350 y1350 w" . RepButton.statusWidth + 500 . " h" . RepButton.statusHeight + 500 . " NA NoActivate")
      
        ; Ensure the window stays on top
        WinSetAlwaysOnTop(1, this.Gui.Hwnd)
        WinSetExStyle("+0x80000", this.Gui.Hwnd)  ; WS_EX_NOACTIVATE
    }
    
    StartTiming() {
        this._isReady := false
        this.PictureReady.Visible := false ; Hide the 'ready' icon
        this.PictureUsed.Visible := true  ; Show the 'used' icon
        this.StatusText.Visible := true
        WinSetTransColor("EEAA99 200", this.Gui.Hwnd)
        this._repCountDown := this._CoolDownTime * 60 ; Set the cooldown period here
        this.StatusText.Text := this._repCountDown
    }

    UpdateButton() {
        static bAlt := true

        ; Refocus the GUI
        this.ShowIndicator()
        
        if (!this._isReady) { ; If not ready to click
            this._repCountDown := this._repCountDown - 1
            this.StatusText.Text := this.FormatDuration(this._repCountDown)  ; Update the text control with the new time
            if (this._repCountDown <= 0) {
                this._repCountDown := 0
                this._isReady := true
                this.StatusText.Visible := false
                this.PictureReady.Visible := true ; Hide the 'ready' icon
                this.PictureUsed.Visible := false ; Show the 'used' icon
            }
        }
        else {        
            if (bAlt) {
                WinSetTransColor("EEAA99 175", this.Gui.Hwnd)     
            }
            else {
                WinSetTransColor("EEAA99 255", this.Gui.Hwnd)        
            }

            bAlt := !bAlt
        }
    }

    FormatDuration(seconds) {
        hours := seconds // 3600
        minutes := (seconds - hours * 3600) // 60
        remainingSeconds := Mod(seconds, 60)

        ; Format hours, minutes, and seconds to always show two digits
        formattedHours := Format("{:02}", hours)
        formattedMinutes := Format("{:02}", minutes)
        formattedSeconds := Format("{:02}", remainingSeconds)

        return formattedHours . ":" . formattedMinutes . ":" . formattedSeconds
    }
    
    ButtonClick(*) {
        if (this._isReady) {
            this.StartTiming()  ; Start cooldown
        }
    }
}

RepButtonInst := RepButton(60) ; in minutes