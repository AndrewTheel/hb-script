; Minimap Variables
minimapX1 := CtPixel(84, "X")       ; Top-left X coordinate of the minimap
minimapY1 := CtPixel(0, "Y")        ; Top-left Y coordinate of the minimap
minimapX2 := CtPixel(100, "X")      ; Bottom-right X coordinate of the minimap
minimapY2 := CtPixel(21.4, "Y")     ; Bottom-right Y coordinate of the minimap

minimapWidth := minimapX2 - minimapX1 ; Calculate the width and height of the minimap (in pixels)
minimapHeight := minimapY2 - minimapY1

blueDotColor := "0x0010FF"
blueDotCoords := [0,0]

gameWidth := 256 ; Map size of Farm (may need to have different sizes)
gameHeight := 256

scaleX := gameWidth / minimapWidth
scaleY := gameHeight / minimapHeight

SetTimer(UpdatePlayerCoords, 200)

; Convert game coordinates to minimap coordinates
GameToMinimap(gameX, gameY) {
    minimapX := (gameX / scaleX) + minimapX1
    minimapY := (gameY / scaleY) + minimapY1
    return [minimapX, minimapY]
}

; Function to convert minimap coordinates to game world coordinates
MinimapToGame(coords, oldcoords) {
    ; Ensure the argument passed is an array and has exactly 2 number elements
    if (!IsObject(coords) || coords.Length != 2 || !IsNumber(coords[1]) || !IsNumber(coords[2])) {
        Tooltip "Invalid minimap coordinates or array length: " coords[1] ", " coords[2]
        Sleep 2000  ; Display tooltip for 2 seconds
        Tooltip  ; Clear the tooltip after displaying
        return ["", ""]  ; Return empty values for invalid input
    }

    mx := Lerp(oldcoords[1], coords[1], 0.1)
    my := Lerp(oldcoords[2], coords[2], 0.1)

    ; Adjust for minimap bounds before scaling
    gx := (mx - minimapX1) * scaleX
    gy := (my - minimapY1) * scaleY

    return [gx, gy]  ; Return game world coordinates
}

; Convert world coordinates to screen coordinates relative to the player
; Convert world coordinates to screen coordinates relative to the player
GameToScreen(gameX, gameY) {
    ; Calculate the difference between the player position and the target world position
    offsetX := gameX - playerGameCoords[1]  ; How far the target is from the player on the X-axis
    offsetY := gameY - playerGameCoords[2]  ; How far the target is from the player on the Y-axis

    ; Convert the world offsets to screen offsets based on grid percentages and screen resolution
    screenOffsetX := offsetX * (A_ScreenWidth * SquarePercentageX / 100)
    screenOffsetY := offsetY * (A_ScreenHeight * SquarePercentageY / 100)

    ; Player is at the center of the screen, so add screen offsets to the center
    screenX := centerX + screenOffsetX
    screenY := centerY + screenOffsetY

    ; Return screen coordinates relative to player position
    return [screenX, screenY]
}

; Function to get the game coordinates of the cursor relative to the player
GetCursorGameCoords() {
    if (!IsNumber(playerGameCoords[1]) || !IsNumber(playerGameCoords[2])) {
        Tooltip "Error: Invalid player coordinates!"
        Sleep 2000  ; Display the error message for 2 seconds
        Tooltip  ; Clear the tooltip
        return ["", ""]  ; Return empty values to indicate invalid input
    }

    ; Get current cursor screen coordinates
    MouseGetPos &mouseX, &mouseY

    ; Calculate the difference between the cursor and player (center of screen)
    deltaX := mouseX - centerX
    deltaY := mouseY - centerY

    ; Convert screen percentage to grid movement
    gridX := deltaX / (A_ScreenWidth * SquarePercentageX / 100)
    gridY := deltaY / (A_ScreenHeight * SquarePercentageY / 100)

    ; Adjust the player's game coordinates based on the calculated grid movement
    cursorGameCoords := [playerGameCoords[1] + gridX, playerGameCoords[2] + gridY]

    return cursorGameCoords  ; Return the game coordinates of the cursor
}

DebugCursorCoords() {
    ; Ensure that blueDotCoords array is valid and contains valid X and Y values
    if (IsObject(blueDotCoords) && blueDotCoords.Length = 2 && blueDotCoords[1] != "" && blueDotCoords[2] != "") {
        gameCoords := GetCursorGameCoords()
        Tooltip "Game coordinates: " gameCoords[1] ", " gameCoords[2]
    } else {
        Tooltip  ; Clear the tooltip if the blue dot coordinates are invalid
    }
}

UpdatePlayerCoords() {
    global blueDotCoords, playerGameCoords

    local tempX, tempY

    if !WinActive(WinTitle) {
        return
    }

    ; Search for the blue dot's color within the minimap
    if PixelSearch(&tempX, &tempY, minimapX1, minimapY1, minimapX2, minimapY2, blueDotColor) {
        blueDotCoords[1] := tempX - 0.5
        blueDotCoords[2] := tempY - 0.5  ; Adjust Y to center the dot if necessary

        ; Convert minimap coordinates to game coordinates
        oldBlueDotCoords := blueDotCoords
        playerGameCoords := MinimapToGame(blueDotCoords, oldBlueDotCoords)
    }
    ; Show no error, because sometimes we won't have minimap ex- The Shop
}