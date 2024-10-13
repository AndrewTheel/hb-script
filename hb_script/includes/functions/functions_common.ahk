Lerp(Start, End, Alpha) {
    return Start + (End - Start) * Alpha
}

; Function to shuffle an array
RandomizeArray(&arr) {
	for i, _ in arr {
        rndIndex := Random(1, arr.Length) ; Generate a random index between 1 and the length of the array
        ; Swap the current element with the random one
        temp := arr[i]
        arr[i] := arr[rndIndex]
        arr[rndIndex] := temp
    }
}

CalculateFontSize(percentOfHeight) {
    ScreenHeight := ScreenResolution[2] + 0  ; Get the screen height
    return Round((percentOfHeight / 100) * ScreenHeight)  ; Calculate font size as a percentage of height
}

CtPixel(percent, axis) {
    ScreenResolutionX := ScreenResolution[1] + 0  ; Cast to number
    ScreenResolutionY := ScreenResolution[2] + 0  ; Cast to number

    if (axis = "X") {
        return Round((percent / 100) * ScreenResolutionX)
    } else if (axis = "Y") {
        return Round((percent / 100) * ScreenResolutionY)
    }
}

CtPercent(pixel, axis) {
    ScreenResolutionX := ScreenResolution[1] + 0  ; Cast to number
    ScreenResolutionY := ScreenResolution[2] + 0  ; Cast to number

    if (axis = "X") {
        return (pixel / ScreenResolutionX) * 100
    } else if (axis = "Y") {
        return (pixel / ScreenResolutionY) * 100
    }
}

; CctPixels function: Converts percentage coordinates to pixel coordinates
CctPixels(x, y) {
    pixelX := CtPixel(x, "X")  ; Convert x percentage to pixels
    pixelY := CtPixel(y, "Y")  ; Convert y percentage to pixels
    return [pixelX, pixelY]    ; Return array with both pixel values
}

; add this function to the beginning of functions that will often be used in combat
RemoveHolds(*) {
    Send("{Ctrl up}")
    Send("{Alt up}")
    Send("{Shift up}")
}

PretendCorpse(*) {
	RemoveHolds()

	BlockInput true
	MouseClick "right"
	Sleep 10
	MouseClick "right"
	Sleep 10
	Send "{F8}"
	Sleep 10
	MouseClick "left", CtPixel(67, "X"), CtPixel(48, "Y")
	Sleep 10
	Send "{F8}"
	BlockInput false
}

TakeInvisPot(*) {
	BlockInput true
	Send "{F6}"
	Sleep 10
	MouseClick "left", CtPixel(90, "X"), CtPixel(55.2, "Y"), 2
	Sleep 10
	Send "{F6}"
	BlockInput false
}