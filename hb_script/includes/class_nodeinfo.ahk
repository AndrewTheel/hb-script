class NodeInfo {
	; Member variables
    NodeTitle := ""
	Imagepath := ""
    WorldCoordinates := [0,0] ; In cases where we don't use an image we can apply world coordintes (useful for travel only checkpoints)
	Location := [0,0] ; World location of the Image found
    ClickOffset := [0,0] ; If applicable, the offset from the location, useful for when we need to click an area offset from the image (converted to pixels in constructor)
    MarkerLabel := ""
    
    ConnectedNodes := [] ; Array of NodeTitles that this node can navigate to

    ; Constructor
    __New(NodeTitle := "", Imagepath := "", WorldCoordinates := [0, 0], Location := [0, 0], ClickOffset := [0, 0], MarkerLabel := "", ConnectedNodes := []) {
        ; Initialize member variables
        this.NodeTitle := NodeTitle
        this.Imagepath := Imagepath
        this.WorldCoordinates := WorldCoordinates
        this.Location := Location
        this.ClickOffset := [CtPixel(ClickOffset[1], "X"), CtPixel(ClickOffset[2], "Y")]
        this.MarkerLabel := MarkerLabel
        this.ConnectedNodes := ConnectedNodes
    }

    IsOnScreen() {
        return this.Location != [0, 0]
    }

    IsMarker() {
        return this.MarkerLabel != ""
    }

    SearchScreenUpdate() {
        X := 0, Y := 0

        if (ImageSearch(&X, &Y, 0, 0, ScreenResolution[1], ScreenResolution[2], "*TransBlack " this.Imagepath))
        {
            this.Location := [X, Y]         
        }
    }

    StartImageSearchTimer() {
        SetTimer(this.SearchScreenUpdate.Bind(this), 500)
    }

    StopImageSearchTimer() {
        SetTimer(this.SearchScreenUpdate.Bind(this), 0)
    }

    Click(times := 1) {
        if (ImageSearch(&X, &Y, 0, 0, ScreenResolution[1], ScreenResolution[2], "*TransBlack " this.Imagepath)) {
            this.Location := [X, Y]
            Send "{Click " this.Location[1] + this.ClickOffset[1] " " this.Location[2] + this.ClickOffset[2] "}"
        }
    }
}

ShopKeeper := NodeInfo("ShopKeeper", "images\ShopKeeper.png",,,[-10,25])
RestButton := NodeInfo("RestButton", "images\RestButton.png",,,[2,1])


SetTimer(CheckOnScreen, 250)

CheckOnScreen() {
    Sleep 300
    ShopKeeper.Click()
    Sleep 1000
    RestButton.Click()
}
