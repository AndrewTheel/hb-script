; Define a global array to hold all marker GUIs
global markers := []

; Function to create a GUI element at specific game coordinates
CreateMarker(markerId, gameX, gameY, markerText := "X") {
    global markers

    ; Convert game coordinates to screen coordinates
    screenCoords := GameToScreen(gameX, gameY)
    screenX := screenCoords[1]
    screenY := screenCoords[2]

    ; Create a new GUI instance, non-interactable and always-on-top
    markerGui := GUI("+AlwaysOnTop +ToolWindow -Caption E0x8000000 +Disabled")
    markerGui.BackColor := "EEAA99" ; Makes the GUI transparent
	WinSetTransColor("EEAA99", markerGui.Hwnd)
    WinSetAlwaysOnTop(1, markerGui.Hwnd)
    ;WinSetExStyle("+0x80000", markerGui.Hwnd)  ; WS_EX_NOACTIVATE

    ; Add the marker text to the GUI
    markerControl := markerGui.Add("Text", "x0 y0 cLime Center", markerText)
    ;markerControl := markerGui.Add("Text", "x" . screenX . " y" . screenY . " cLime BackgroundTrans", markerText)


    ; Show the GUI without stealing focus
    markerGui.Show("NA NoActivate")

        ; Create a new object for the marker and assign its properties
    marker := {}
    marker.Gui := markerGui
    marker.Control := markerControl
    marker.GameX := gameX
    marker.GameY := gameY

    ; Store the object in the global markers array
    markers.Push(marker)

    return marker
}

; Function to update all marker positions based on their game coordinates
UpdateMarkers() {
    global markers

    for markerId, marker in markers {
        marker.Gui.GetPos(&OldScreenX, &OldScreenY)

        ; Get the updated screen position based on current game coordinates
        screenCoords := GameToScreen(marker.GameX, marker.GameY)
        screenX := Lerp(OldScreenX, screenCoords[1], 0.8)
        screenY := Lerp(OldscreenY, screenCoords[2], 0.8)

        ; Check if the marker is within the screen bounds
        if IsOnScreen(screenX, screenY) {
            ; Move the GUI window to the new screen position
            marker.Gui.Move(screenX, screenY)

            ; Optional: Move the control inside the GUI (if needed)
            marker.Control.Move(0, 0)  ; Moves control inside the GUI to the top-left corner

            marker.Gui.Show("NA NoActivate")  ; Show the marker if it's on-screen
            WinSetAlwaysOnTop(1, marker.Gui.Hwnd)                           
        } else {
            marker.Gui.Hide()  ; Hide the marker if it's off-screen
        }
    }
}

; Function to check if a position is within the minimap bounds
IsOnScreen(screenX, screenY) {
    global minimapX1, minimapY1, minimapX2, minimapY2

    return true ; (screenX >= minimapX1 && screenX <= minimapX2 && screenY >= minimapY1 && screenY <= minimapY2)
}

; Example usage: Create 3 markers
CreateMarker(1, 148, 181, "Farm")
CreateMarker(2, 89, 178, "Shop")
CreateMarker(3, 112, 192, "Blacksmith")

; Set a timer to update the marker positions every 250 ms
SetTimer(UpdateMarkers, 250)

; Define an empty list of images with their corresponding values
imageList := []

AddImage(imagePath, NavX, NavY) {
    NewImage := []                 ; Create a new array
    NewImage.Push(imagePath)        ; Assign image path to index 1
    NewImage.Push(NavX)             ; Assign xPos to index 3 (default is 0)
    NewImage.Push(NavY)             ; Assign xPos to index 3 (default is 0)
    imageList.Push(NewImage)        ; Add the new image entry to the imageList
}

AddImage("images\BlackSmith.png", 112, 192)

CheckForBlackSmith() {
    if (ImageSearch(&X, &Y, 0, 0, 800, 600, "*TransBlack images\BlackSmith.png"))
    {
        Tooltip "Found!"
        Sleep 1000
        Tooltip "" 
    }
}

SetTimer(CheckForBlackSmith, 100)