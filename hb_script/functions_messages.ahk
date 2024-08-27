SendTextMessage(str := "") {
	BlockInput true
	Send "{enter}"
	Sleep 5
	SendText(str)
	Sleep 10
	Send "{enter}"
	BlockInput false
}

PFMMessage(*) => SendTextMessage("pfm")
APFMMessage(*) => SendTextMessage("amp")
BerserkMessage(*) => SendTextMessage("zerk")
InvisMessage(*) => SendTextMessage("invis")
EnemiesMessage(*)  => SendTextMessage("Ares Nearby!")