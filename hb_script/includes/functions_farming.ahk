global farmingActive := false  ; Initialize the farming status as inactive
global bNeedSeeds := false
global farmSpot := [0, 0]
global sellSpot := [CtPixel(33.3, "X"),CtPixel(33.3, "Y")]

FarmPositions := [directions.Down, directions.LeftDown, directions.RightDown]
FarmPositionsLtR := [directions.LeftDown, directions.Down, directions.RightDown]

MessageDialogueBoxPixel := [CtPixel(0.1, "X"),CtPixel(88.75, "Y")]
MessageDialogueBoxColor := 0x8C715A

;NoItemImage := "images\node_images\NoItemImage.png"
SellListAlreadyImage := "images\node_images\SellListAlready.png"

; Nodes for farming
;NodeInfo(1:NodeTitle, 2:Imagepath, 3:AltImagepath, 4:WorldCoordinates, 5:ClickOffset; 6:MarkerLabel, 7:ConnectedNodes)
; Farm (outside)
FarmPlot := NodeInfo("ShopKeeper", "images\node_images\FarmWagon_Day.png", "images\node_images\FarmWagon_Night.png", [148,181], [-14.8, 3])
ShopEntrance := NodeInfo("ShopEntrance", "images\node_images\Shop_Entrance_Day.png", "images\node_images\Shop_Entrance_Night.png", [93,178], [10,24])
BlackSmithEntrance := NodeInfo("BlacksmithEntrance", "images\node_images\Blacksmith_Entrance_Day.png", "images\node_images\Blacksmith_Entrance_Night.png", [111,193], [1.3,23.7])

; Shop (for selling, buying, resting)
ShopExit := NodeInfo("ShopExit", "images\node_images\Shop_Exit.png",,,[2,24])
ShopKeeper := NodeInfo("ShopKeeper", "images\node_images\ShopKeeper.png",,,[-10,25])
BuyMiscButton := NodeInfo("BuyMiscButton", "images\node_images\Buy_Misc.png",,,[2,1])
QuantitySelect := NodeInfo("QuantitySelect", "images\node_images\Quantity.png",,,[11.3,1.2])
PurchaseButton := NodeInfo("PurchaseButton", "images\node_images\Purchase_Button.png",,,[4.6,1.7])
RestButton := NodeInfo("RestButton", "images\node_images\RestButton.png",,,[2,1])
SellItemsButton := NodeInfo("SellButton", "images\node_images\SellItems_Button.png",,,[3.6,1])
SellDialogueBox := NodeInfo("SellQuantityBox", "images\node_images\quantityBoxImage.png")
SellConfirmButton := NodeInfo("SellConfirm", "images\node_images\Sell_Confirm_Button.png",,,[3.6,1.2])
SellListMenu := NodeInfo("SellListMenu", "images\node_images\SellListMenu.png")
InventoryMenu := NodeInfo("InventoryMenu", "images\node_images\InventoryMenu.png")
ItemsForSaleMenu := NodeInfo("ItemsForSale", "images\node_images\ItemsForSale.png")

; Blacksmith (for repairing)
BlacksmithExit := NodeInfo("BlacksmithExit", "images\node_images\Blacksmith_Exit.png",,,[2,18.2])
Blacksmith := NodeInfo("Blacksmith", "images\node_images\Blacksmith.png",,,[1.9,13.5])
RepairAllButton := NodeInfo("RepairAllButton", "images\node_images\Repair_All.png",,,[2,1]) ; reused for confirmation
;RepairConfirm := NodeInfo("RepairConfirm", "images\node_images\Repair_All.png",,,[2,1])

;Produce
Watermelon := ""
Pumpkin := NodeInfo("PumpkinProduce", "images\node_images\Pumpkin_Produce.png",,,[1.5,2])
Seed_Pumpkin := NodeInfo("Seed_Pumpkin", "images\node_images\Seed_Pumpkin.png",,,[8.4,1.2])

StartFarming() {
    global farmingActive
    farmingActive := true

    if WinActive(WinTitle)
	{
		BlockInput "MouseMove"
        EnableShiftPickup()

        Loop {
            Sleep 500
            FarmPlot.MoveToLocation()
            Sleep 500
            SetTimer(FindFarmSpot,200)
            Sleep 1000
            GetInFarmSpot()
            Sleep 200
            CycleTool()
            Sleep 200
            SowFields()
            ShopEntrance.MoveToLocation()
            Sleep 500
            if (!EnterShop()) {
                break
            }
            Sleep 2000
            RestAndShop()
            Sleep 2000
            if (!ExitShop()) {
                break
            }
            Sleep 200

            BlackSmithEntrance.MoveToLocation()
            Sleep 500
            if (!EnterBlackSmith()) {
                break
            }
            Sleep 1000
            RepairAll()
            Sleep 1000
            if (!ExitBlackSmith()) {
                break
            }
        }

        Sleep 5000

        if (farmingActive) {
            StopFarming()
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

EnterShop() {
    Loop 10 {
        ShopEntrance.Click()
        Sleep 500
        MouseMove CenterX, CenterY
        if (ShopKeeper.IsOnScreen()) {
            return true
        }
        Sleep 100
    }
    return false
}

ExitShop() {
    Loop 10 {
        ShopExit.Click()
        Sleep 500
        MouseMove CenterX, CenterY
        if (ShopEntrance.IsOnScreen()) {
            return true
        }
        Sleep 100
    }
    return false
}

EnterBlackSmith() {
    Loop 10 {
        BlackSmithEntrance.Click()
        Sleep 500
        MouseMove CenterX, CenterY
        if (Blacksmith.IsOnScreen()) {
            return true
        }
        Sleep 100
    }
    return false
}

ExitBlackSmith() {
    Loop 10 {
        BlackSmithExit.Click()
        Sleep 500
        MouseMove CenterX, CenterY
        if (BlackSmithEntrance.IsOnScreen()) {
            return true
        }
        Sleep 100
    }
    return false
}

RepairAll() {
    Loop 10 {
        if (Blacksmith.IsOnScreen()) {
            Blacksmith.Click()
            Sleep 200
            RepairAllButton.Click()
            Sleep 200
            MouseMove CenterX, CenterY ; After clicking repair all the mouse lands on the repair confirmation changing it's color, so lets move our mouse away to make sure we find the right button
            Sleep 200
            if (RepairAllButton.IsOnScreen()) {
                RepairAllButton.Click() ; there is a confirmation button that is also "repair" this node can therefore be repurposed
            }
            return
        }
        Sleep 1000
    }
    StopFarming() ; We never made it into shop
}

RestAndShop() {
    Loop 10 {
        if (ShopKeeper.IsOnScreen()) {
            ShopKeeper.Click()
            Sleep 200
            RestButton.Click()
            Sleep 200

            ; Then lets sell produce
            ShopKeeper.Click()
            Sleep 200
            SellItemsButton.Click()
            Sleep 200
            SellProduce()
            Sleep 100
            if (InventoryMenu.IsOnScreen()) {
                OpenBag() ; closes the opened inventory menu
            }
            Sleep 100
            ShopKeeper.Click()
            Sleep 200
            BuyMiscButton.Click()
            Sleep 200
            BuySeeds()
            Sleep 200
            if (ItemsForSaleMenu.IsOnScreen()) {
                ItemsForSaleMenu.Click("right")
            }
            Sleep 100
            OpenBag()
            Sleep 100
            MoveSeedsToPosition()
            if (InventoryMenu.IsOnScreen()) {
                OpenBag() ; closes the opened inventory menu
            }
            return
        }
        Sleep 1000
    }
    StopFarming() ; We never made it into shop
}

MoveSeedsToPosition() {
    Send("{Shift down}")
    MouseClickDrag "L", DefaultItemLandingPos[1], DefaultItemLandingPos[2], InventorySlotPos[12][1], InventorySlotPos[12][2], 3
    Send("{Shift up}")
    Sleep 50
}

BuySeeds() {
    Loop 10 {
        if (Seed_Pumpkin.IsOnScreen()) {
            Seed_Pumpkin.Click()
            break
        }
    }
    Sleep 200
    QuantitySelect.Click(, 4)
    Sleep 200
    PurchaseButton.Click()
}

SellProduce() {
    PreSellSpotX := DefaultItemLandingPos[1] - CtPixel(7, "X")
    X1 := CtPixel(1, "X"), Y1 := CtPixel(75, "Y"), X2 := CtPixel(22, "X"), Y2 := CtPixel(91, "Y")

    Loop 18 {
        MouseClick "left", DefaultItemLandingPos[1], DefaultItemLandingPos[2], 2       
        Sleep 50
        if (ImageSearch(&X, &Y, X1, Y1, X2, Y2, "*TransBlack " SellListAlreadyImage)) {
            MouseClickDrag "L", DefaultItemLandingPos[1], DefaultItemLandingPos[2], PreSellSpotX, DefaultItemLandingPos[2], 2
            Sleep 50
        }

        if (SellDialogueBox.IsOnScreen() || PixelGetColor(MessageDialogueBoxPixel[1], MessageDialogueBoxPixel[2]) == MessageDialogueBoxColor) {
            Send("{Enter}")
        }
    }

    Loop 5 {
        if (SellConfirmButton.IsOnScreen()) {
            SellConfirmButton.Click()
            return
        }
        Sleep 100
    }

    if (SellListMenu.IsOnScreen()) {
        MouseClick "right", sellSpot[1], sellSpot[2], 1 ;rightclick area to close
    }
}

SowFields() {
    Global bNeedSeeds

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

    bNeedSeeds := false
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

    Static X1 := 0, Y1 := 0, X2 := ScreenResolution[1], Y2 := ScreenResolution[2]  ; Initial search area variables
    ;Static Dot := gGUI.Add("Text", "x0 y0 cLime Center", "X")

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

    ;Dot.Move(farmSpot[1], farmSpot[2])
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

    Static X1 := x - 20, Y1 := y - 20, X2 := x + 20, Y2 := y + 20  ; Initial search area variables

    Px := 0, Py := 0

    if (PixelSearch(&Px, &Py, X1, Y1, X2, Y2, 0xC8C8C8)) { ; || PixelSearch(&Px, &Py, X1, Y1, X2, Y2, 0xFFC894)) {
        return true
    }
    else {
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
            Send "{Click " InventorySlotPos[12][1] " " InventorySlotPos[12][2] " 3}" ; Double click on the seed location
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
    Sleep 150
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
