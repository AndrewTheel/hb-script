SendTextMessage(str := "") {
	BlockInput true
	Send "{enter}"
	Sleep 10
	SendText(str)
	Sleep 10
	Send "{enter}"
	BlockInput false
}

APFMMessage(*) => SendTextMessage("000")
BerserkMessage(*) => SendTextMessage("zerk")
InvisMessage(*) => SendTextMessage("invis plz")
EnemiesMessage(*)  => SendTextMessage("Ares care!")
HasteMessage(*)  => SendTextMessage("haste plz")
CheckRepMessage(*) => SendTextMessage("/checkrep")