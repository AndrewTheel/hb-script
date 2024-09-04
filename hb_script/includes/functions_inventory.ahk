EatFood(*) {
	BlockInput true
	Send "{F6}"
	Sleep 10
	MouseClick "left", CtPixel(93.0, "X"), CtPixel(55.2, "Y"), 2
	Sleep 10
	Send "{F6}"
	BlockInput false
}

EquipShield1(*) {
    Item10()
}

EquipWeapon1(*) {
    Item9()
}

EquipWeapon2(*) {
    Item8()
}

Item1(*) {
    BlockInput true
    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}{Click " InventorySlotPos[1][1] " " InventorySlotPos[1][2] "}{Ctrl up}"
    Sleep 10
    Send "{click right}"
    BlockInput false
}

Item2(*) {
    BlockInput true
    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}{Click " InventorySlotPos[2][1] " " InventorySlotPos[2][2] "}{Ctrl up}"
    Sleep 10
    Send "{click right}"
    BlockInput false
}

Item3(*) {
    BlockInput true
    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}{Click " InventorySlotPos[3][1] " " InventorySlotPos[3][2] "}{Ctrl up}"
    Sleep 10
    Send "{click right}"
    BlockInput false
}

Item4(*) {
    BlockInput true
    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}{Click " InventorySlotPos[4][1] " " InventorySlotPos[4][2] "}{Ctrl up}"
    Sleep 10
    Send "{click right}"
    BlockInput false
}

Item5(*) {
    BlockInput true
    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}{Click " InventorySlotPos[5][1] " " InventorySlotPos[5][2] "}{Ctrl up}"
    Sleep 10
    Send "{click right}"
    BlockInput false
}

Item6(*) {
    BlockInput true
    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}{Click " InventorySlotPos[6][1] " " InventorySlotPos[6][2] "}{Ctrl up}"
    Sleep 10
    Send "{click right}"
    BlockInput false
}

Item7(*) {
    BlockInput true
    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}{Click " InventorySlotPos[7][1] " " InventorySlotPos[7][2] "}{Ctrl up}"
    Sleep 10
    Send "{click right}"
    BlockInput false
}

Item8(*) {
    BlockInput true
    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}{Click " InventorySlotPos[8][1] " " InventorySlotPos[8][2] "}{Ctrl up}"
    Sleep 10
    Send "{click right}"
    BlockInput false
}

Item9(*) {
    BlockInput true
    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}{Click " InventorySlotPos[9][1] " " InventorySlotPos[9][2] "}{Ctrl up}"
    Sleep 10
    Send "{click right}"
    BlockInput false
}

Item10(*) {
    BlockInput true
    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}{Click " InventorySlotPos[10][1] " " InventorySlotPos[10][2] "}{Ctrl up}"
    Sleep 10
    Send "{click right}"
    BlockInput false
}