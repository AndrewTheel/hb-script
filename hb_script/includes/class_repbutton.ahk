class RepButton {
    __New(RepCoolDownTime) {
        this.X := CtPixel(91.7968, "X")
        this.Y := CtPixel(93.75, "Y")
        this.statusWidth := 50
        this.statusHeight := 25
        this._repCountDown := 1
        this._isReady := true
        this._CoolDownTime := RepCoolDownTime

        this.readyicon := "images\RepReady.png"
        this.usedicon := "images\RepUsed.png"

        this.InitializeGUI()
        SetTimer(this.UpdateButton.Bind(this), 1000)  ; Set a timer to call UpdateTimer every second
    }

	; Define IsActive property
    IsActive() {
        return this._isReady
    }
    
    InitializeGUI() {
        ; Add the first picture for the 'ready' icon
        this.PictureReady := gGUI.Add("Picture", "x" this.X " y" this.Y " w" this.statusWidth " h" this.statusHeight, this.readyicon)
        this.PictureReady.Visible := true  ; Initially show this picture
        
        ; Add the second picture for the 'used' icon
        this.PictureUsed := gGUI.Add("Picture", "x" this.X " y" this.Y " w" this.statusWidth " h" this.statusHeight, this.usedicon)
        this.PictureUsed.Visible := false  ; Initially hide this picture
               
        ; Add text control for timer with default text '00'
        this.StatusText := gGUI.Add("Text", "x" this.X " y" this.Y + this.statusHeight " w" . this.statusWidth . " h24 Center", "00")
        this.StatusText.SetFont("s" CalculateFontSize(1) " cYellow", "Arial")  ; Set font size, color, and font
        this.StatusText.Visible := false

        ; Add a click event for the button
        BoundFunc := ObjBindMethod(this, "ButtonClick")
        this.PictureReady.OnEvent("Click", BoundFunc)
        this.PictureUsed.OnEvent("Click", BoundFunc)
    }
    
    StartTiming() {
        this._isReady := false
        this.PictureReady.Visible := false ; Hide the 'ready' icon
        this.PictureUsed.Visible := true  ; Show the 'used' icon
        this.StatusText.Visible := true
        ;WinSetTransColor("EEAA99 200", gGUI.Hwnd)
        this._repCountDown := this._CoolDownTime * 60 ; Set the cooldown period here
        this.StatusText.Text := this._repCountDown
    }

    UpdateButton() {      
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