class NodeInfo {
	; Member variables
    NodeTitle := ""
	Imagepath := ""
    AltImagepath := "" ; Useful for night variants
    WorldCoordinates := [0,0] ; In cases where we don't use an image we can apply world coordintes (useful for traveling)
	Location := [0,0] ; World location of the Image found
    ClickOffset := [0,0] ; If applicable, the offset from the location, useful for when we need to click an area offset from the image (converted to pixels in constructor)
    Value := ""
    
    ConnectedNodes := [] ; Array of NodeTitles that this node can navigate to

    ; Constructor
    __New(NodeTitle := "", Imagepath := "", AltImagepath := "", WorldCoordinates := [0, 0], ClickOffset := [0, 0], Value := "", ConnectedNodes := []) {
        ; Initialize member variables
        this.NodeTitle := NodeTitle
        this.Imagepath := Imagepath
        this.AltImagepath := AltImagepath
        this.WorldCoordinates := WorldCoordinates
        this.ClickOffset := [CtPixel(ClickOffset[1], "X"), CtPixel(ClickOffset[2], "Y")]
        this.Value := Value
        this.ConnectedNodes := ConnectedNodes
    }

    IsOnScreen() {
        if (this.Imagepath != "" && (ImageSearch(&X, &Y, 0, 0, ScreenResolution[1], ScreenResolution[2], "*TransBlack " this.Imagepath) || (this.AltImagepath != "" && ImageSearch(&X, &Y, 0, 0, ScreenResolution[1], ScreenResolution[2], "*TransBlack " this.AltImagepath))) ) {
            return true       
        }
        return false
    }

    GetNodeTitle() {
        return this.NodeTitle
    }

    GetScreenLocation() {
        ; Initialize variables to store found X and Y coordinates
        X := 0
        Y := 0

        ; Check if the main image is found
        if (this.Imagepath != "" && ImageSearch(&X, &Y, 0, 0, ScreenResolution[1], ScreenResolution[2], "*TransBlack " this.Imagepath) != false) {
            ; If the main image is found, return X and Y
            return [X, Y]
        }
        ; If the main image is not found, check for the alternative image
        else if (this.AltImagepath != "" && ImageSearch(&X, &Y, 0, 0, ScreenResolution[1], ScreenResolution[2], "*TransBlack " this.AltImagepath) != false) {
            ; If the alternative image is found, return X and Y
            return [X, Y]
        }

        ; Return false if no image is found
        return false
    }

    PositionIsCenter() {
        ; Determine the boundaries of the square
        LeftBoundary := CenterX - XOffset
        RightBoundary := CenterX + XOffset
        TopBoundary := CenterY - YOffset
        BottomBoundary := CenterY + YOffset

        ; Check if the point (x, y) is within the boundaries
        return (this.Location[1] + this.ClickOffset[1] >= LeftBoundary && this.Location[1] + this.ClickOffset[1] <= RightBoundary && this.Location[2] + this.ClickOffset[2] >= TopBoundary && this.Location[2] + this.ClickOffset[2] <= BottomBoundary)
    }    

    Click(button := "left", clickTimes := 1, bUseOffset := true) {
        ; Loop to attempt finding the image for a maximum of 5 tries
        Loop 5 {
            X := 0
            Y := 0

            ; Check for the primary image and, if necessary, the alternative image
            if (this.Imagepath != "" && ImageSearch(&X, &Y, 0, 0, ScreenResolution[1], ScreenResolution[2], "*TransBlack " this.Imagepath)
                || (this.AltImagepath != "" && ImageSearch(&X, &Y, 0, 0, ScreenResolution[1], ScreenResolution[2], "*TransBlack " this.AltImagepath))) {
                
                this.Location := [X, Y]

                ; Apply offset if bUseOffset is true, otherwise click the exact location
                offsetX := bUseOffset ? this.ClickOffset[1] : 0
                offsetY := bUseOffset ? this.ClickOffset[2] : 0

                ; Handle click
                Sleep 20
                MouseClick(button, this.Location[1] + offsetX, this.Location[2] + offsetY, clickTimes)
                Sleep 100
                return true
            } 
            else {
                ; Wait before retrying
                Sleep 1000
            }
        }

        ; Return false if image was not found after 10 attempts
        return false
    }

    MoveToLocation() {
        ; Convert the game coordinates to minimap coordinates
        targetCoords := GameToMinimap(this.WorldCoordinates[1], this.WorldCoordinates[2])
        targetX := targetCoords[1]
        targetY := targetCoords[2]

        ; Initialize variables for tracking progress
        prevBlueDotX := ""
        prevBlueDotY := ""
        noProgressCounter := 0  ; Counts how many times no significant progress is made
        maxNoProgress := 3      ; Max allowed iterations without progress before triggering random movement
        noProgresssCounterForFail := 0

        loop {
            if stopFlag {
                break
            }

            ; Ensure that blueDotCoords array is valid and contains valid X and Y values
            if (!IsObject(blueDotCoords) || blueDotCoords.Length != 2 || blueDotCoords[1] == "" || blueDotCoords[2] == "") {
                Tooltip "Error: Blue dot coordinates not found!"
                Sleep(1000)
                Tooltip ""  ; Clear the tooltip after displaying
                break
            }

            ; Extract X and Y coordinates from blueDotCoords
            blueDotX := blueDotCoords[1]
            blueDotY := blueDotCoords[2]

            ; Calculate the difference between the current blue dot position and the target
            deltaX := targetX - blueDotX
            deltaY := targetY - blueDotY

            ; Stop when the blue dot is close enough to the target (within 2 coords)
            if (Abs(deltaX) < 2 && Abs(deltaY) < 2) {
                break
            }

            ; Check if progress is being made
            if (prevBlueDotX != "" && prevBlueDotY != "") {
                if (Abs(prevBlueDotX - blueDotX) < 1 && Abs(prevBlueDotY - blueDotY) < 1) {
                    noProgressCounter++
                } else {
                    noProgressCounter := 0  ; Reset counter if progress is made
                }

                ; If no progress for too long, trigger random movement
                if (noProgressCounter >= maxNoProgress) {
                    this.MoveDirection("Random", 3)
                    prevBlueDotX := blueDotX
                    prevBlueDotY := blueDotY   
                    noProgressCounter := 0  ; Reset after random movement
                    Sleep 2000
                    noProgresssCounterForFail++

                    if (noProgresssCounterForFail > 5) {
                        Tooltip "Failed to move to location: " this.GetNodeTitle() 
                        Send "{LButton up}"
                        Send "{Escape}"
                        return
                    }

                    continue
                }
            }

            ; Update previous blue dot position
            prevBlueDotX := blueDotX
            prevBlueDotY := blueDotY           

            ; Normalize deltaX and deltaY to a range
            distanceX := Min(Abs(deltaX), 3)
            distanceY := Min(Abs(deltaY), 3)

            ; Prioritize straight movement if one delta is much larger than the other
            if (Abs(deltaX) > Abs(deltaY) * 2) {
                ; Prioritize horizontal movement
                if (deltaX > 0) {
                    this.MoveDirection("Right", distanceX)
                } else if (deltaX < 0) {
                    this.MoveDirection("Left", distanceX)
                }
            } else if (Abs(deltaY) > Abs(deltaX) * 2) {
                ; Prioritize vertical movement
                if (deltaY > 0) {
                    this.MoveDirection("Down", distanceY)
                } else if (deltaY < 0) {
                    this.MoveDirection("Up", distanceY)
                }
            } 
            ; Use diagonal movement if both deltaX and deltaY are close in value
            else {
                if (deltaX > 0 && deltaY > 0) {
                    this.MoveDirection("RightDown", Min(distanceX, distanceY))  ; Use the smaller of the two distances
                } else if (deltaX > 0 && deltaY < 0) {
                    this.MoveDirection("RightUp", Min(distanceX, distanceY))
                } else if (deltaX < 0 && deltaY > 0) {
                    this.MoveDirection("LeftDown", Min(distanceX, distanceY))
                } else if (deltaX < 0 && deltaY < 0) {
                    this.MoveDirection("LeftUp", Min(distanceX, distanceY))
                }
            }

            Sleep 200
            Send("{LButton down}")
        }

        Send("{LButton up}")
        Sleep 100
    }

    MoveDirection(direction, distance := 2) {
        ; Calculate pixel offsets for each direction based on the distance
        XOffset := CtPixel(SquarePercentageX * distance, "X")
        YOffset := CtPixel(SquarePercentageY * distance, "Y")

        ; Create offset arrays
        XOffsets := [-XOffset, 0, XOffset]
        YOffsets := [-YOffset, 0, YOffset]

        ; Define coordinates for each direction
        directions := Object()
        directions.RightDown := [CenterX + XOffsets[3], CenterY + YOffsets[3]]
        directions.LeftDown := [CenterX + XOffsets[1], CenterY + YOffsets[3]]
        directions.LeftUp := [CenterX + XOffsets[1], CenterY + YOffsets[1]]
        directions.RightUp := [CenterX + XOffsets[3], CenterY + YOffsets[1]]
        directions.Up := [CenterX + XOffsets[2], CenterY + YOffsets[1]]
        directions.Down := [CenterX + XOffsets[2], CenterY + YOffsets[3]]
        directions.Left := [CenterX + XOffsets[1], CenterY + YOffsets[2]]
        directions.Right := [CenterX + XOffsets[3], CenterY + YOffsets[2]]

        directions.Random := [CenterX + XOffsets[Random(1, 3)], CenterY + YOffsets[Random(1, 3)]]

        Coords := directions.%direction% ; Get coordinates for the specified direction
        MouseMove Coords[1], Coords[2], 0 ; Move the mouse to the calculated coordinates
    }
}