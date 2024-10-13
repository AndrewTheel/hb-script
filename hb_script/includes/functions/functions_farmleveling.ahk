global fLevelingState := ""
global fLevelingActive := false  ; Initialize the farming status as inactive
global fLevelingIndicator := ""

/*
OrcPit1
OrcPit2

OrcColorSkin_Day
OrcColorSkin_Night
OrcColorShine_Day
OrcColorShine_Night

*/

; Goals
; 1 pickup and turn in quest
; requirements: need to detect on hUD screen when objective is completed, need images for NPC dialogue to retrieve quest
; loop:
; recall
; run to orc pit
; chase down orcs (don't just be stationary)
; stay within boundaries or return to boundaries if detected outside!
; kill orcs until quest complete
; run away (a bit) and recall
; run to NPC, claim quest reward
; get new quest version
; run to shop, rest, sell
; run to blacksmith, repair
; repeat



StartFarmLeveling() {


}

FarmLevelingCycle() {
    global fLevelingActive, fLevelingState, stopFlag

    fLevelingActive := true
    BlockInput "MouseMove"
    EnableShiftPickup()
    Sleep 500

    if (!WinActive(WinTitle)) {
            return
        }

    Loop {
        if stopFlag {
            break
        }

        Sleep 200

        switch fLevelingState {
            case "recall_start":
                FarmingRecall()
                fLevelingState := "travel_farm_plot"

            case "head_to_orc_pit":

                fLevelingState := "kill_orcs"

            case "kill_orcs":

                fLevelingState := "retreat_recall"

            case "retreat_recall":

                fLevelingState := "turn_in_quest"

            case "turn_in_quest":

                fLevelingState := "turn_in_quest"
        }
    }

}

ScreenSquares := []

Loop GridSquaresX {
    x := A_Index - 1
    Loop GridSquaresY {
        y := A_Index - 1
        squareCenterX := (x * squareWidth) + (squareWidth / 2)
        squareCenterY := (y * squareHeight) + (squareHeight / 2)


        distFromCenter := Sqrt((squareCenterX - centerX) * 2 + (squareCenterY - centerY) * 2)

        ScreenSquares.Push([squareCenterX, squareCenterY, distFromCenter])
    }

}
/*
; Resolution
screenWidth := 800
screenHeight := 600

; Grid dimensions
cols := 25
rows := 17

; Calculate square sizes
squareWidth := screenWidth // cols
squareHeight := screenHeight // rows

; Center of the screen
centerX := screenWidth // 2
centerY := screenHeight // 2

; Define the four target colors (example: in hex format)
colors := [0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00] ; red, green, blue, yellow

; Store the square coordinates and their distances from center
squares := []

; Step 1: Fill squares array with center coordinates of each square and their distance from center
Loop rows
{
    y := A_Index - 1 ; 0-based index for rows
    Loop cols
    {
        x := A_Index - 1 ; 0-based index for columns
        squareCenterX := (x * squareWidth) + (squareWidth // 2)
        squareCenterY := (y * squareHeight) + (squareHeight // 2)

        ; Calculate distance from the screen center
        distFromCenter := Sqrt((squareCenterX - centerX) ** 2 + (squareCenterY - centerY) ** 2)

        ; Add the square details to the array: [x, y, distance]
        squares.Push([squareCenterX, squareCenterY, distFromCenter])
    }
}

; Step 2: Sort squares by proximity to the center
squares.Sort(Func("CompareDistance"))

CompareDistance(a, b) {
    return a[3] - b[3] ; Sort by distance
}

; Step 3: Search for the colors in each square
For square in squares
{
    x := square[1]
    y := square[2]

    ; Perform a PixelSearch in this square's area
    Loop 2 ; Search for 2 colors (match condition)
    {
        color := colors[A_Index]

        ; PixelSearch at the center of each square or a smaller area within the square
        if PixelSearch(px, py, x - (squareWidth // 2), y - (squareHeight // 2), x + (squareWidth // 2), y + (squareHeight // 2), color, 0, Fast)
        {
            ; If the pixel search finds a match, store the result
            matches++
            if matches >= 2
            {
                ; Return the coordinates when two color matches are found
                MsgBox "Match found at X:" x " Y:" y
                return
            }
        }
    }
}

MsgBox "No match found."

*/