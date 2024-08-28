SendTextMessage(str := "") {
	BlockInput true
	Send "{enter}"
	Sleep 10
	SendText(str)
	Sleep 10
	Send "{enter}"
	BlockInput false
}

PFMMessage(*) => SendTextMessage("pfm")
APFMMessage(*) => SendTextMessage("000")
BerserkMessage(*) => SendTextMessage("zerk")
InvisMessage(*) => SendTextMessage("invis")
EnemiesMessage(*)  => SendTextMessage("Ares Nearby!")
HasteMessage(*)  => SendTextMessage("haste")
CheckRepMessage(*) => SendTextMessage("/checkrep")