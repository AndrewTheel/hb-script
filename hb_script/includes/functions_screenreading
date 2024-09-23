
; Define an empty list of images with their corresponding values
imageList := []

; Array to store the search results (x positions)
foundImages := []

; Function to add image information (image path, value, and optional xPos) to the list
AddImage(imagePath, Value, xPos := 0) {
    NewImage := []                 ; Create a new array
    NewImage.Push(imagePath)        ; Assign image path to index 1
    NewImage.Push(Value)            ; Assign value to index 2
    NewImage.Push(xPos)             ; Assign xPos to index 3 (default is 0)
    imageList.Push(NewImage)        ; Add the new image entry to the imageList
}

; Dynamically add images starting from 0
;AddImage("images\leftpara_img.png", "(")
;AddImage("images\rightpara_img.png", ")")
AddImage("images\0_img.png", 0)
AddImage("images\1_img.png", 1)
AddImage("images\2_img.png", 2)
AddImage("images\3_img.png", 3)
AddImage("images\4_img.png", 4)
AddImage("images\5_img.png", 5)
AddImage("images\6_img.png", 6)
AddImage("images\7_img.png", 7)
AddImage("images\8_img.png", 8)
AddImage("images\9_img.png", 9)
;AddImage("images\comma_img.png", ",")

/*
NewImage := []                 ; Create a new array
NewImage.Push("")        ; Assign image path to index 1
NewImage.Push(3)            ; Assign value to index 2
NewImage.Push(0)             ; Assign xPos to index 3 (default is 0)
foundImages.Push(NewImage)        ; Add the new image entry to the imageList
*/

CoordinateIndicatorX1 := CtPixel(28, "X")
CoordinateIndicatorY1 := CtPixel(97, "Y")
CoordinateIndicatorX2 := CtPixel(50, "X")
CoordinateIndicatorY2 := CtPixel(99.3, "Y")

; Function to read coordinates using ImageSearch
ReadCoordinates() {
    Global foundImages

    foundImages := [] ;reset

    X := 0
    Y := 0
    
    xCoordInt := 0
    yCoordInt := 0

    XOffset := 0

    XStart := 0
    XEnd := 0

    PreviousX := 0

    ; Establish the location of the ( and the )
    if (ImageSearch(&X, &Y, CoordinateIndicatorX1, CoordinateIndicatorY1, CoordinateIndicatorX2, CoordinateIndicatorY2, "*TransBlack images\leftpara_img.png"))
    {
        XStart := X
    }
    if (ImageSearch(&X, &Y, CoordinateIndicatorX1, CoordinateIndicatorY1, CoordinateIndicatorX2, CoordinateIndicatorY2, "*TransBlack images\rightpara_img.png"))
    {
        XEnd := X
    }

    if (XStart != 0 && XEnd != 0)
    {
        ; Loop through the imageList
        for i, image in imageList {
            imagePath := image[1]     ; Get image path
            Value := image[2]         ; Get the value associated with the image
            XOffset := 0

            ; Loop to search for multiple instances of the image
            loop 16 {
                ; Clamp the XStart + XOffset value to ensure it doesn't exceed XEnd
                XStartClamped := Min(XStart + XOffset, XEnd)

                ; Perform ImageSearch
                if (ImageSearch(&X, &Y, XStartClamped, CoordinateIndicatorY1, XEnd, CoordinateIndicatorY2, "*TransBlack " imagePath)) {
                    ; We found an image, let's add it to foundImages with the X position
                    if (X == PreviousX) { ;ignore duplicates
                        ; do nothing
                    }
                    else {
                        FoundImage := []
                        FoundImage.Push(imagePath)   ; Image path
                        FoundImage.Push(Value)       ; Image value
                        FoundImage.Push(X)           ; X position
                        foundImages.Push(FoundImage) ; Add found image to the results
                    }
                } else {
                    break ; No more images found, break out of the loop
                }
                XOffset += 8
                PreviousX := X
            }
        }

        ; Sort the found images based on their xPos values
        if (foundImages.Length > 0) {
            BubbleSortFoundImagesByXPos(&foundImages)
        }

        ; Now we need to form a string of the values of foundImages
        coordinateString := ""
        for i, foundObj in foundImages {
            coordinateString .= foundObj.Get(2) ; Append value from foundImages
        }

 ; Calculate the middle position
middle := Floor(StrLen(coordinateString) / 2)

; Insert a comma at the middle position
coordinateString := SubStr(coordinateString, 1, middle) . "," . SubStr(coordinateString, middle + 1)
       

        ; First, make sure the comma exists in the string
        if InStr(coordinateString, ",") {
            ; Split the string based on the comma
            SplitString := StrSplit(coordinateString, ",")

            ; Ensure we have exactly two parts
            if (SplitString.Length >= 2) {
                ; Convert the strings to integers
                xCoord := SplitString[1] ; First part of the string before the comma (X value)
                yCoord := SplitString[2] ; Second part of the string after the comma (Y value)
            }

            ; Convert them to integers
            if (xCoord != "") {
                xCoordInt := Integer(xCoord)
            }
            if (yCoord != "") {
                yCoordInt := Integer(yCoord)
            }
        }
    }

/*
    msgBoxText := "Found Images:`n`n" ; Initialize the text for the MsgBox
    
    ; Loop through the foundImages array and build the MsgBox text
    for i, foundObj in foundImages {
        msgBoxText .= "Image Path: " foundObj[1] "`n"
        msgBoxText .= "Value: " foundObj[2] "`n"
        msgBoxText .= "X Position: " foundObj[3] "`n"
        msgBoxText .= "-----------------------" "`n"
    }
    
    ; Show the MsgBox with the collected text
    MsgBox msgBoxText
*/



    return [xCoordInt, yCoordInt]
}

; Custom bubble sort function for foundImages based on the xPos (index 3)
BubbleSortFoundImagesByXPos(&arr) {
    n := arr.Length
    while (n > 1) {
        newn := 0
        for j, _ in arr {
            if (j >= n) {
                break
            }
            ; Compare the xPos of two adjacent elements
            if arr[j][3] > arr[j + 1][3] {
                ; Swap the elements
                temp := arr[j]
                arr[j] := arr[j + 1]
                arr[j + 1] := temp
                newn := j
            }
        }
        n := newn
    }
}


GetCoordinates() {
    Global GameCoords

    Static bCoordsUpdateTime := 0
    Static Xpos := 0, Ypos := 0

    MapCoords := playerGameCoords
    Coords := ReadCoordinates() ; Assuming ReadCoordinates returns [X, Y]
    
    DeltaX := Abs(Coords[1] - Xpos)
    DeltaY := Abs(Coords[2] - Ypos)

    if (DeltaX < 5) {
        Xpos := Coords[1]
        bCoordsUpdateTime := A_TickCount
    }

    if (DeltaY < 5) {
        Ypos := Coords[2]
        bCoordsUpdateTime := A_TickCount
    }

    /*
    ; Update both Xpos and Ypos if more than 5000 ms have passed
    if (A_TickCount - bCoordsUpdateTime > 15000) {
        Xpos := Coords[1]
        Ypos := Coords[2]
    }
    */

    DeltaX := Abs(MapCoords[1] - Xpos)
    DeltaY := Abs(MapCoords[2] - Ypos)

    ; If the X change is greater than 2 pixels, update the Xpos
    if (DeltaX > 1) {
        Xpos := MapCoords[1]
        bCoordsUpdateTime := A_TickCount
    }

    ; If the Y change is greater than 2 pixels, update the Ypos
    if (DeltaY > 1) {
        Ypos := MapCoords[2]
        bCoordsUpdateTime := A_TickCount
    }

    GameCoords[1] := Xpos
    GameCoords[2] := Ypos

    ; Display the coordinates in a tooltip
    Tooltip "X: " . Xpos . " Y: " . Ypos
}

SetTimer(GetCoordinates, 10)