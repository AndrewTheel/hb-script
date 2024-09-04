class GUIManager {
    CoordText := ""
    StatusText := ""
    HealthPotText := ""
    ManaPotText := ""
    InvSlotHelpers := []

    __New() {
        this.InitializeGUI()
    }

    InitializeGUI() {
        this.CoordText := gGUI.Add("Text", "cLime Center", "XXXXXXXX YYYYYYYY")
        this.CoordText.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")
        this.CoordText.Move(CtPixel(CoordsIndicatorPos[1], "X"), CtPixel(CoordsIndicatorPos[2], "Y"))

        this.StatusText := gGUI.Add("Text", "cWhite", "Script")
        this.StatusText.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")
        this.StatusText.Move(CtPixel(ScriptActiveIndicatorPos[1], "X"), CtPixel(ScriptActiveIndicatorPos[2], "Y"))

        this.HealthPotText := gGUI.Add("Text", "cWhite", "H")
        this.HealthPotText.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")
        this.HealthPotText.Move(CtPixel(AutoPotHealthIndicatorPos[1], "X"), CtPixel(AutoPotHealthIndicatorPos[2], "Y"))

        this.ManaPotText := gGUI.Add("Text", "cWhite", "M")
        this.ManaPotText.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")
        this.ManaPotText.Move(CtPixel(AutoPotManaIndicatorPos[1], "X"), CtPixel(AutoPotManaIndicatorPos[2], "Y"))

        ;this.MyBtn := gGUI.Add("Button", "x400 y570 w30 h20", "TradeRep")
        ;this.MyBtn.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")
        ;this.MyBtn.OnEvent("Click", ToggleDebugMode)

        ; Create a text control for each coordinate in InventorySlotPos
        for index, coord in InventorySlotPos {
            if (coord.Length) {
                this.InvSlotHelpers.Push(gGUI.Add("Text", "x" coord[1] - 6 " y" coord[2] - 4 " w15 h15 Center cFuchsia", index))
            }
        }

        if (IniRead(ConfigFile, "Settings", "UseAutoPotting") != "true") {
            this.HealthPotText.Hidden(true)
            this.ManaPotText.Hidden(true)
        }
    
        SetTimer(this.UpdateOSD.Bind(this), 200)
    }

    UpdateOSD() {
        for control in this.InvSlotHelpers {
            if IsObject(control) {
                if (!bDebugMode) {
                    control.Visible := false
                }
                else {
                    control.Visible := true
                }
            }
        }
    
        MouseGetPos(&MouseX, &MouseY)
        this.CoordText.Value := Format("X: {:.2f}%, Y: {:.2f}%", CtPercent(MouseX, "X"), CtPercent(MouseY, "Y"))
        this.StatusText.SetFont(A_IsSuspended ? "cff9c9c" : "c16ff58")
        this.HealthPotText.SetFont(bTryHPPotting ? "c16ff58" : "cff9c9c")
        this.ManaPotText.SetFont(bTryManaPotting ? "c16ff58" : "cff9c9c")
    }
}