global FarmingState := ""
global farmingActive := false  ; Initialize the farming status as inactive
global bNeedSeeds := false
global FarmedSeed := ""
global sellSpot := [CtPixel(33.3, "X"),CtPixel(33.3, "Y")]
global FarmingIndicator := ""

farmingStates := ["recall_start", 
                  "travel_farm_plot", 
                  "get_in_farm_plot", 
                  "change_tools", 
                  "sow_fields", 
                  "recall_for_shop", 
                  "move_to_shop_wp1", 
                  "move_to_shop",
                  "enter_shop",
                  "rest_and_shop",
                  "exit_shop",
                  "move_to_blacksmith_wp1",
                  "move_to_blacksmith",
                  "enter_blacksmith",
                  "repair_all"]

FarmPositions := [directions.Down, directions.LeftDown, directions.RightDown]
FarmPositionsLtR := [directions.LeftDown, directions.Down, directions.RightDown]

MessageDialogueBoxPixel := [CtPixel(0.1, "X"),CtPixel(88.75, "Y")]
MessageDialogueBoxColor := 0x8C715A

;NoItemImage := "images\node_images\NoItemImage.png"
SellListAlreadyImage := "images\node_images\SellListAlready.png"
Okay_Menu_Prompt := NodeInfo("Okay_Menu", "images\node_images\Okay_Menu_Prompt.png",,,[1,1])
Okay_Menu_Prompt.SetSearchCoords(CtPixel(23, "X"), CtPixel(63, "Y"), CtPixel(52, "X"), CtPixel(82, "Y"))

; Nodes for farming
;NodeInfo(1:NodeTitle, 2:Imagepath, 3:AltImagepath, 4:WorldCoordinates, 5:ClickOffset; 6:Value, 7:ConnectedNodes)

; Farm Navigation to Farm Plots
farmPlotIndex := 0
farmPlots := []

North_FarmWagon_WP1 := NodeInfo("North_FarmWagon_WP1",,, [90,95])
North_FarmWagon_WP2 := NodeInfo("North_FarmWagon_WP2",,, [83,82])
farmPlots.Push(NodeInfo("North_FarmWagon_Slot1",,, [75, 79],,,[North_FarmWagon_WP1, North_FarmWagon_WP2]))
farmPlots.Push(NodeInfo("North_FarmWagon_Slot2",,, [81, 79],,,[North_FarmWagon_WP1, North_FarmWagon_WP2]))
farmPlots.Push(NodeInfo("North_FarmWagon_Slot3",,, [83, 82],,,[North_FarmWagon_WP1, North_FarmWagon_WP2]))

SW_BigFarm_WP1 := NodeInfo("SW_BigFarm_WP1",,, [110,125])
farmPlots.Push(NodeInfo("SW_BigFarm_Slot1",,, [77, 113],,,[SW_BigFarm_WP1]))
farmPlots.Push(NodeInfo("SW_BigFarm_Slot2",,, [71, 108],,,[SW_BigFarm_WP1]))
farmPlots.Push(NodeInfo("SW_BigFarm_Slot3",,, [64, 105],,,[SW_BigFarm_WP1]))
farmPlots.Push(NodeInfo("SW_BigFarm_Slot4",,, [60, 102],,,[SW_BigFarm_WP1]))
farmPlots.Push(NodeInfo("SW_BigFarm_Slot5",,, [55, 98],,,[SW_BigFarm_WP1]))
farmPlots.Push(NodeInfo("SW_BigFarm_Slot6",,, [55, 93],,,[SW_BigFarm_WP1]))
farmPlots.Push(NodeInfo("SW_BigFarm_Slot7",,, [73, 93],,,[SW_BigFarm_WP1]))
farmPlots.Push(NodeInfo("SW_BigFarm_Slot8",,, [81, 94],,,[SW_BigFarm_WP1]))
farmPlots.Push(NodeInfo("SW_BigFarm_Slot9",,, [87, 97],,,[SW_BigFarm_WP1]))
farmPlots.Push(NodeInfo("SW_BigFarm_Slot10",,, [93, 110],,,[SW_BigFarm_WP1]))

;East_BigFarm_WP1 := NodeInfo("East_BigFarm_WP1",,, [110,125])
farmPlots.Push(NodeInfo("East_BigFarm_Slot1",,, [157, 169]))
farmPlots.Push(NodeInfo("East_BigFarm_Slot2",,, [159, 186])) ;good
farmPlots.Push(NodeInfo("East_BigFarm_Slot3",,, [170, 180])) ;good
farmPlots.Push(NodeInfo("East_BigFarm_Slot4",,, [178, 168])) ;good
farmPlots.Push(NodeInfo("East_BigFarm_Slot5",,, [180, 154])) ;good
farmPlots.Push(NodeInfo("East_BigFarm_Slot6",,, [198, 151])) ;good
farmPlots.Push(NodeInfo("East_BigFarm_Slot7",,, [199, 141])) ;good
farmPlots.Push(NodeInfo("East_BigFarm_Slot8",,, [187, 141])) ;good

; Farm Navigation to Shop
ShopEntrance := NodeInfo("ShopEntrance",,, [93,178])
ShopEntrance2 := NodeInfo("ShopEntrance2",,, [89,181])
ShopEntrance3 := NodeInfo("ShopEntrance3",,, [91,180])
ShopEntrance4 := NodeInfo("ShopEntrance4",,, [90,178])
Shop_WP1 := NodeInfo("Shop_WP1",,, [118,172])

; Farm Navigation to Blacksmith
BlackSmithEntrance := NodeInfo("BlacksmithEntrance",,, [111,193])
BM_WP1 := NodeInfo("BM_WP1",,, [108,196])

; Shop Interior (for selling, buying, resting)
ShopExit := NodeInfo("ShopExit", "images\node_images\Shop_Exit.png",,,[2,17])
ShopKeeper := NodeInfo("ShopKeeper", "images\node_images\ShopKeeper.png",,,[5,11])
BuyMiscButton := NodeInfo("BuyMiscButton", "images\node_images\Buy_Misc.png",,,[2,1])
QuantitySelect := NodeInfo("QuantitySelect", "images\node_images\Quantity.png",,,[11.3,1.2])
PurchaseButton := NodeInfo("PurchaseButton", "images\node_images\Purchase_Button.png",,,[4.6,1.7])
RestButton := NodeInfo("RestButton", "images\node_images\RestButton.png",,,[2,1])
SellMaximum := NodeInfo("SellMaximum", "images\node_images\SellMaximum.png")
SellItemsButton := NodeInfo("SellButton", "images\node_images\SellItems_Button.png",,,[3.6,1])
SellDialogueBox := NodeInfo("SellQuantityBox", "images\node_images\quantityBoxImage.png")
SellConfirmButton := NodeInfo("SellConfirm", "images\node_images\Sell_Confirm_Button.png",,,[3.6,1.2])
SellListMenu := NodeInfo("SellListMenu", "images\node_images\SellListMenu.png")
InventoryMenu := NodeInfo("InventoryMenu", "images\node_images\InventoryMenu.png")
ItemsForSaleMenu := NodeInfo("ItemsForSale", "images\node_images\ItemsForSale.png",,,[2,0])

; Blacksmith Interior (for repairing)
Blacksmith := NodeInfo("Blacksmith", "images\node_images\Blacksmith.png",,,[1.9,13.5])
RepairAllButton := NodeInfo("RepairAllButton", "images\node_images\Repair_All.png",,,[2,1]) ; reused for confirmation

; Recall Landing Spot
RecallLandingSpot := NodeInfo("RecallLandingSpot",,,[125, 151])

; Seeds 
Seed_Img := "images\node_images\Seed_Img.png"
seedIndex := 0
seedList := []
seedList.Push(NodeInfo("Seed_Watermelon", "images\node_images\Seed_Watermelon.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Pumpkin", "images\node_images\Seed_Pumpkin.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Garlic", "images\node_images\Seed_Garlic.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Barley", "images\node_images\Seed_Barley.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Carrot", "images\node_images\Seed_Carrot.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Radish", "images\node_images\Seed_Radish.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Corn", "images\node_images\Seed_Corn.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Chinese", "images\node_images\Seed_Chinese.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Melon", "images\node_images\Seed_Melon.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Tomato", "images\node_images\Seed_Tomato.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Grapes", "images\node_images\Seed_Grapes.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_BlueGrapes", "images\node_images\Seed_BlueGrapes.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Mushroom", "images\node_images\Seed_Mushroom.png",,,[0,1.2], 4))
seedList.Push(NodeInfo("Seed_Ginseng", "images\node_images\Seed_Ginseng.png",,,[0,1.2], 4))

Test() {
    North_FarmWagon_WP1.MoveToLocation()
}

StartFarming() {
    farmGui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000 +OwnDialogs")
    farmGui.BackColor := "9b908d" ; Makes the GUI transparent
    WinSetAlwaysOnTop(1, farmGui.Hwnd)    

    ; Create an array to hold seed names
    seedNames := []
    plotNames := []

    ; Loop through the seedList to extract seed names
    for index, seed in seedList {
        ; Extract the seed name by splitting the string
        seedName := StrSplit(seed.GetNodeTitle(), "_")[2] ; Gets the part after "Seed_"
        seedNames.Push(seedName)
    }

    for index, plot in farmPlots {
        plotNames.Push(plot.GetNodeTitle())
    }

    ; Add the UpDown control and other components to the GUI
    farmGui.Add("Text",, "Select seed to farm:")
    farmGui.Add("ListBox", "vSeedChoice Choose1 r" 5, seedNames)
    
    farmGui.Add("Text",, "Select farm plot:")
    farmGui.Add("ListBox", "vPlotChoice Choose1 r" 5, plotNames)

    farmGui.Add("Text",, "Select state:")
    farmGui.Add("ListBox", "vFarmingState Choose1 r" 5, farmingStates)

    OKButton := farmGui.Add("Button", "Default vOKButton", "OK")
    OKButton.OnEvent("Click", (*) => FarmingButtonSubmit(farmGui))

    ; Show the GUI
    farmGui.Show("Center NA NoActivate")
}

FarmingButtonSubmit(farmGui) {
    Global seedIndex, farmPlotIndex, FarmingIndicator, FarmingState

    farmPlotIndex := farmGui["PlotChoice"].Value
    seedIndex := farmGui["SeedChoice"].Value ; Retrieve the selected seed name from the ListBox
    FarmingState := farmingStates[farmGui["FarmingState"].Value]
    farmGui.Destroy()

    if (FarmingIndicator == "") {
        FarmingIndicator := gGUI.Add("Text", "x" CtPixel(0, "X") " y" CtPixel(97, "Y") " cWhite", "Farming " seedList[seedIndex].GetNodeTitle())
        FarmingIndicator.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")
    }
    else {
        FarmingIndicator.Visible := true
    }

    FarmingCycle()
}

FarmingCycle() {
    global farmingActive, FarmingState, farmPlotIndex
    farmingActive := true

    if (!WinActive(WinTitle)) {
        return
    }

    if (farmPlotIndex == 0 || seedIndex == 0) {
        Tooltip "Error in plot or seed index"
        return
    }

    BlockInput "MouseMove"
    EnableShiftPickup()
    Sleep 200

    Loop {
        if stopFlag {
            break
        }

        if (Okay_Menu_Prompt.IsOnScreen()) {
            Okay_Menu_Prompt.Click() ; Click okay if a menu has popped up on the screen (like crusade)
        }

        Sleep 200

        switch FarmingState {
            case farmingStates[1]:
                if (!FarmingRecall()) {
                    Tooltip "Error in 'recall_start': trying to recall"
                    Send "{Escape}"
                }
                FarmingState := farmingStates[2]

            case farmingStates[2]:
                farmPlots[farmPlotIndex].MoveToLocation()
                FarmingState := farmingStates[3]

            case farmingStates[3]:
                GetInFarmSpot()
                FarmingState := farmingStates[4]
            
            case farmingStates[4]:
                CycleTool()
                FarmingState := farmingStates[5]

            case farmingStates[5]:
                SowFields()
                FarmingState := farmingStates[6]

            case farmingStates[6]:
                if (!FarmingRecall()) {
                    Tooltip "Error in 'recall_for_shop': trying to recall"
                    Send "{Escape}"
                }
                FarmingState := farmingStates[7]
            
            case farmingStates[7]:
                Shop_WP1.MoveToLocation()
                FarmingState := farmingStates[8]

            case farmingStates[8]:
                ShopEntrance.MoveToLocation()
                FarmingState := farmingStates[9]

            case farmingStates[9]:
                if (!EnterShop()) {
                    Tooltip "Error in farming trying to enter shop"
                    Send "{Escape}"
                }
                FarmingState := farmingStates[10]

            case farmingStates[10]:
                RestAndShop()
                FarmingState := farmingStates[11]

            case farmingStates[11]:
                if (!ExitShop()) {
                    Tooltip "Error in farming trying to exit shop"
                    Send "{Escape}"
                }
                FarmingState := farmingStates[12]

            case farmingStates[12]:
                BM_WP1.MoveToLocation()
                FarmingState := farmingStates[13]

            case farmingStates[13]:
                BlackSmithEntrance.MoveToLocation()
                FarmingState := farmingStates[14]

            case farmingStates[14]:
                if (!EnterBlackSmith()) {
                    Tooltip "Error in farming entering blacksmith"
                    Send "{Escape}"
                }
                FarmingState := farmingStates[15]

            case farmingStates[15]:
                RepairAll()
                farmPlotIndex := Random(1, farmPlots.Length) ; randomize the plot we goto
                FarmingState := farmingStates[1]
        }
    }

    Sleep 500

    if (farmingActive) {
        StopFarming()
        Sleep 500
    }
}

StopFarming() {
    global farmingActive, stopFlag, FarmingIndicator

    DisableShiftPickup()
    farmingActive := false
    stopFlag := false
    FarmingIndicator.Visible := false
    RemoveHolds()
    ReturnInputs()
}

EnterShop() {
    ShopEntrances := [ShopEntrance, ShopEntrance2, ShopEntrance3, ShopEntrance4]  ; Array of shop entrances

    Loop 5 {
        for each, entrance in ShopEntrances {
            entrance.Click()
            Sleep 500
            MouseMove(CenterX, CenterY)
            if (ShopKeeper.IsOnScreen()) {
                return true
            }
            Sleep 100
        }
    }
    return false
}

ExitShop() {
    Loop 10 {
        ShopExit.Click()
        Sleep 500
        MouseMove CenterX, CenterY
        if (ShopEntrance.IsCoordsNearby(playerGameCoords[1], playerGameCoords[2])) {
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

RepairAll() {
    Loop 10 {
        if (Blacksmith.IsOnScreen()) {
            Blacksmith.Click()
            Sleep 200
            RepairAllButton.Click()
            Sleep 200
            MouseMove 0, 0, 0 ; After clicking repair all the mouse lands on the repair confirmation changing it's color, so lets move our mouse away to make sure we find the right button
            Sleep 200
            if (RepairAllButton.IsOnScreen()) {
                RepairAllButton.Click() ; there is a confirmation button that is also "repair" this node can therefore be repurposed
            }
            return
        }
        Sleep 500
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
            SellProduce()
            Sleep 100
            ShopKeeper.Click()
            Sleep 200
            BuyMiscButton.Click()
            Sleep 200
            BuySeeds()
            Sleep 100
            MouseMove 0, 0, 0
            Sleep 100
            Loop 10 {
                if (ItemsForSaleMenu.Click("right")) {
                    break
                }
                Sleep 1000
            }
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
    X1 := DefaultItemLandingPos[1] - 10, Y1 := DefaultItemLandingPos[2] - 10, X2 := DefaultItemLandingPos[1] + 10, Y2 := DefaultItemLandingPos[2] + 10

    if (ImageSearch(&X, &Y, X1, Y1, X2, Y2, "*TransBlack " Seed_Img)) {
        Send("{Shift down}")
        MouseClickDrag "L", DefaultItemLandingPos[1], DefaultItemLandingPos[2], InventorySlotPos[12][1], InventorySlotPos[12][2], 3
        Send("{Shift up}")
        Sleep 300
    }
}

BuySeeds() {
    MouseMove 0, 0, 0

    if (seedIndex == 0) {
        Tooltip "No seed index assigned"
        return
    }

    ; scroll down until we see our seed
    Loop {
        Send("{WheelDown}")
        Sleep 500
    } Until (seedList[seedIndex].IsOnScreen())

    Sleep 100
    seedList[seedIndex].Click()
    Sleep 100
    MouseMove 0, 0, 0
    Sleep 200
    QuantitySelect.Click(, seedList[seedIndex].Value)
    Sleep 200
    PurchaseButton.Click()
}

SellProduce() {
    Loop {
        ShopKeeper.Click()
        Sleep 200
        SellItemsButton.Click()
        Sleep 200
    } Until (SellItemsOnDefaultSlot())

    if (SellListMenu.IsOnScreen()) {
        MouseClick "right", sellSpot[1], sellSpot[2], 1 ;rightclick area to close
    }
}

SellItemsOnDefaultSlot() {
    local bHitMaximumItems := false

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

        if (!bHitMaximumItems && SellMaximum.IsOnScreen()) {
            bHitMaximumItems := true
        }
    }

    Loop 5 {
        if (SellConfirmButton.IsOnScreen()) {
            SellConfirmButton.Click()
            break
        }
        Sleep 100
    }

    if (InventoryMenu.IsOnScreen()) {
        OpenBag() ; closes the opened inventory menu
    }

    return !bHitMaximumItems
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
                Break
            }
        }
        else {
            return
        }
    } Until (bNeedSeeds)

    bNeedSeeds := false
}

FarmingRecall() {
    local Attempts := 0
    local MaxAttempts := 10

    RecallSpell := SpellInfo("Recall", "^{2}", "41.8055", "!F1")
    Item8()

    Loop {
        RecallSpell.CastSpell()
        BlockInput "MouseMove"
        MouseMove CenterX, CenterY
        Sleep 1800
        MouseClick("L", CenterX, CenterY)
        Sleep 500

        if (RecallLandingSpot.IsCoordsNearby(playerGameCoords[1], playerGameCoords[2])) {
            return true
        }
        else {
            ClearEnemies()
        }

        if (Attempts > MaxAttempts) {
            break
        }
        Attempts++
    } 

    return false
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

GetInFarmSpot() {
    local attempts := 0

    if (!farmingActive || farmPlotIndex == 0) {
        return false
    }  

    Loop {
        MouseMove CenterX, CenterY
        MouseClick "right" ; stop moving
        Sleep 50
 
        if (farmPlots[farmPlotIndex].Click()) {
            return true
        }

        if (attempts == 8) { ; Can get stuck trying to move 1 up, try moving left up 1
            MoveNearby(1, "LeftUp")
        }
        if (attempts == 11) { ; Can get stuck trying to move 1 up, try letting up shift
            Send("{Shift up}")
        }
        if (attempts > 18) {
            break
        }
        attempts++
        Sleep 2000
    } 

    return false
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
    if (!farmingActive || farmPlotIndex == 0) {
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
        Sleep Random(100,250)
        if (CheckSeedsRemaining()) {
            Send "{Click " InventorySlotPos[12][1] " " InventorySlotPos[12][2] " 3}" ; Double click on the seed location
            Send "{Click " square[1] " " square[2] "}" ; Click on crop location
        }
    }

    if (!farmPlots[farmPlotIndex].IsCenterOnWorldLocation()) { ; Sometimes the player accidently moves, lets make sure we are in the desire location again
        GetInFarmSpot()
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

DoesSummonExist(x, y)
{
    X1 := CenterX, Y1 := CenterY
    X2 := CenterX + (2 * XOffset)
    Y2 := CenterY + (2 * YOffset)

    return PixelSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, 0x00d700)
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
    global bNeedSeeds

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
                    return
                }
            }
            Send("{RButton up}")
            Sleep 100
        }
        else if (DoesSummonExist(square[1], square[2])) { ;Some assholes summon creatures to stop the bot, lets detect if this has occurred and change course
            bNeedSeeds := true
            return
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
