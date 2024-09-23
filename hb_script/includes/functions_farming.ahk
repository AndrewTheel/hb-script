global farmingActive := false  ; Initialize the farming status as inactive
global bNeedSeeds := false
global farmSpot := [0, 0]

FarmPositions := [directions.Down, directions.LeftDown, directions.RightDown]
FarmPositionsLtR := [directions.LeftDown, directions.Down, directions.RightDown]

StartFarming() {
    global farmingActive
    farmingActive := true

    if WinActive(WinTitle)
	{
		BlockInput "MouseMove"
        EnableShiftPickup()
        Sleep 500
        MoveToGameCoords(148, 181) ; Farm location
        Sleep 500
        SetTimer(FindFarmSpot,200)
        Sleep 1000
        GetInFarmSpot()
        Sleep 200
        CycleTool()
        Sleep 200
        SowFields()
        MoveToGameCoords(93, 179) ; Shop location

        if (farmingActive) {
            StopFarming()

            ;ToolTip "Done sowing fields, no longer farming"
            Sleep 1500
            ToolTip ""
        }
    }
}

StopFarming() {
    global farmSpot, farmingActive, stopFlag

    DisableShiftPickup()
    farmingActive := false
    stopFlag := false
    FindFarmSpot()
    SetTimer(FindFarmSpot, 0)
    farmSpot := [0, 0]
    RemoveHolds()
    ReturnInputs()
}

SowFields() {
    Static HoeIndex := 1

    Loop {
        if (farmingActive) {
            ClearEnemies() 
            PlantCrop()
            HarvestCrop()
            PickupProduce()
            GetInFarmSpot()
            CycleTool() 

            if (stopFlag) {
                StopFarming()
                Break
            }
        }
        else {
            return
        }
    } Until (bNeedSeeds)
}

CycleTool() {
    if (!farmingActive) {
        return
    }

    Static Index := 1

    if (Index > 4) { ; Setup for 4 tools
        Index := 1
    }

    funcName := "Item" . Index

    if (funcName) { ; Call the function if it exists
        %funcName%.Call()
    }

    BlockInput "MouseMove" ; Calling the equip item function will stop blocking mouse input, so we need to block it again here.

    Index++
    Sleep 250
}

MoveToFarmSpot() {
    if (!farmingActive) {
        return
    }

    if (farmSpot[1] != 0 && farmSpot[2] != 0) {
        MouseMove farmSpot[1], farmSpot[2], 0
        Sleep 10
        Send("{LButton down}")
        Sleep 10
        Send("{LButton up}")
        Sleep 10
        MouseMove CenterX, CenterY	
        Sleep 1000
    }
}

GetInFarmSpot() {
    if (!farmingActive) {
        return
    }

    attempts := 0

    Loop {
        MoveToFarmSpot()
        if (attempts == 8) { ; Can get stuck trying to move 1 up, try moving left up 1
            MoveNearby(1, "LeftUp")
        }
        if (attempts == 11) { ; Can get stuck trying to move 1 up, try letting up shift
            Send("{Shift up}")
        }
        if (attempts > 18) {
            StopFarming()
            return
        }
        attempts++
    } Until InPosition(farmSpot[1], farmSpot[2])

    ; There is a chance that we aren't in the farm spot, lets do it one more time after a bit of time
    Sleep 800
    MoveToFarmSpot()
}

InPosition(x, y) {
    ; Determine the boundaries of the square
    LeftBoundary := CenterX - XOffset
    RightBoundary := CenterX + XOffset
    TopBoundary := CenterY - YOffset
    BottomBoundary := CenterY + YOffset

    ; Check if the point (x, y) is within the boundaries
    return (x >= LeftBoundary && x <= RightBoundary && y >= TopBoundary && y <= BottomBoundary)
}

FindFarmSpot() {
    Global farmSpot

    Px := 0, Py := 0

    Static X1 := 0, Y1 := 0, X2 := 800, Y2 := 600  ; Initial search area variables
    Static Dot := gGUI.Add("Text", "x0 y0 cLime Center", "X")

    if (PixelSearch(&Px, &Py, X1, Y1, X2, Y2, 0x754924) || PixelSearch(&Px, &Py, X1, Y1, X2, Y2, 0x613531)) {
        farmSpot[1] := Px - 131
        farmSpot[2] := Py - 4

        ; Adjust search area to a 100x100 square around the found pixel
        X1 := Px - 50, Y1 := Py - 50, X2 := Px + 50, Y2 := Py + 50

        ; Ensure the search area stays within the bounds of the original area
        X1 := Max(0, X1), Y1 := Max(0, Y1), X2 := Min(800, X2), Y2 := Min(600, Y2)
    } 
    else {
        ; If not found, reset the search area back to the full screen
        X1 := 0, Y1 := 0
        X2 := 800, Y2 := 600
    }

    if (!farmingActive) {
        farmSpot[1] := 0
        farmSpot[2] := 0
    }

    Dot.Move(farmSpot[1], farmSpot[2])
}

ClearEnemies() {
    i := 0

    if (!farmingActive) {
        return
    }

    EnemyCoords := FindAdjacentEnemy()
    if (EnemyCoords) {
        ;equip weapon
        Send("{RButton down}")
        Loop {
            i++
            if (i > 20) {
                Send("{Alt down}")
            }

            if (i > 100) {
                break
            }
            Sleep 100
        } Until !CanAttackCoord(EnemyCoords[1], EnemyCoords[2])
        Send("{Alt up}")
        Send("{RButton up}")
        MouseMove CenterX, CenterY, 0
        ;equip hoe
        Sleep 1000
    }
}

CheckSeedsRemaining() {
    Global bNeedSeeds

    if (!farmingActive) {
        return
    }    

    x := InventorySlotPos[12][1]
    y := InventorySlotPos[12][2]

    Static X1 := x - 15, Y1 := y - 15, X2 := x + 15, Y2 := y + 15  ; Initial search area variables

    Px := 0, Py := 0

    Tx1 := gGUI.Add("Text", "x0 y0 cWhite Center", "╔")
    Tx2 := gGUI.Add("Text", "x0 y0 cWhite Center", "╗")
    Ty1 := gGUI.Add("Text", "x0 y0 cWhite Center", "╚")
    Ty2 := gGUI.Add("Text", "x0 y0 cWhite Center", "╝")

    Tx1.Move(X1, Y1)
    Tx2.Move(X2, Y1)
    Ty1.Move(X1, Y2)
    Ty2.Move(X2, Y2)

    if (PixelSearch(&Px, &Py, X1, Y1, X2, Y2, 0xE8976C) || PixelSearch(&Px, &Py, X1, Y1, X2, Y2, 0xFFC894)) {
        return true
    }
    else {
        Tooltip "No more seeds found!!!"
        bNeedSeeds := true
        return false
    }      
}

PlantCrop() {
    if (!farmingActive) {
        return
    }

    for square in FarmPositions { ; Check the 3 crop positions to make sure they are clear of enemies
        Sleep 250
        if (CanAttackCoord(square[1], square[2])) {
            ClearEnemies()
            break
        }
    }
    OpenBag()
    Sleep 100
    for square in FarmPositions {
        Sleep Random(300,850)
        if (CheckSeedsRemaining()) {
            Send "{Click " InventorySlotPos[12][1] " " InventorySlotPos[12][2] " 4}" ; Double click on the seed location
            Send "{Click " square[1] " " square[2] "}" ; Click on crop location
        }

        if (!InPosition(farmSpot[1], farmSpot[2])) { ; Sometimes the player accidently moves, lets make sure we are in the desire location again
            GetInFarmSpot()
        }
    }
    OpenBag() ; Close bag
}

DoesCropExist(x, y)
{
	OffsetColor := PixelGetColor(x + 2, y + 24, "RGB")

	if (OffsetColor == "0x0000D7") {
		return true
	}
	return false
}

DoesProduceExist(x, y)
{
	Offsets := [PixelGetColor(x + 12, y + 10, "RGB"), PixelGetColor(x + 12, y + 11, "RGB"), PixelGetColor(x + 13, y + 10, "RGB"), PixelGetColor(x + 13, y + 11, "RGB")]

    ;A_Clipboard := PixelGetColor(x + 12, y + 10, "RGB") " " PixelGetColor(x + 12, y + 11, "RGB") " " PixelGetColor(x + 13, y + 10, "RGB") " " PixelGetColor(x + 13, y + 11, "RGB")

	if (Offsets[1] == "0x47445D" && Offsets[2] == "0xADAAB5" && Offsets[3] == "0x515168" && Offsets[4] == "0x524A52") {
		return true
	}
	return false
}

HarvestCrop() {
    if (!farmingActive) {
        return
    }

    TimePassed := 0

    for square in FarmPositions {
        MouseMove square[1], square[2], 0
        Sleep 150

        if (DoesCropExist(square[1], square[2]))
        {
            Send("{RButton down}")
            while (DoesCropExist(square[1], square[2])) {
                if (TimePassed > 15000) { ;we might have a broken tool, try cycling
                    TimePassed := 0
                    Send("{RButton up}")
                    Sleep 10
                    CycleTool()
                    Send("{RButton down}")
                    Sleep 1000
                }
                Sleep 100
                TimePassed += 100

                if (stopFlag) {
                    Send("{RButton up}")
                    StopFarming()
                    return
                }
            }
            Send("{RButton up}")
            Sleep 100
        }
    }
}

PickUp() {
    Sleep 100
    Send("{Shift down}")
    Send("{RButton down}")
    Sleep 200
    Send("{RButton up}")
    Send("{Shift up}")
    Sleep 500
}

PickupProduce() {
    if (!farmingActive) {
        return
    }

    ProduceFoundArray := [0,0,0]
    MovedTimes := 0

    MouseMove CenterX, CenterY ; Pick up produce under feet
    PickUp()

    ClearEnemies()

    ; Check crop positions and record which ones have produce to pickup
    for index, square in FarmPositionsLtR {
        Sleep 100
        MouseMove square[1], square[2], 0
        Sleep 100

        if (DoesProduceExist(square[1], square[2])) {
            ProduceFoundArray[A_Index] := 1
        }
    }

    for i, value in ProduceFoundArray {
        if (value = 1) {  
            if (MovedTimes == 0) { ; Will move to the left most produce position
                MoveToPosition(FarmPositionsLtR[i][1], FarmPositionsLtR[i][2])
                PickUp()
            }
            else if (i > 0 && ProduceFoundArray[i - 1] == 1) { ; This will run if the previous position had produce
                MoveNearby(1, "Right")
                PickUp()
            }
            else if (i > 0 && ProduceFoundArray[i - 1] == 0) { ; This should only run when the middle is empty, but left and right are produce
                MoveNearby(2, "Right")
                PickUp()
            }

            MovedTimes++
        }
    }

    ; After picking up all produce, return to the original center position
    MouseMove CenterX, CenterY, 0
    Sleep 100
}
