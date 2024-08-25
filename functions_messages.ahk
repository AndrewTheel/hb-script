SendTextMessage(str := "") {
	BlockInput true
	Send "{enter}"
	SendText(str)
	Sleep 20
	Send "{enter}"
	BlockInput false
}

PFMMessage(*) => SendTextMessage("pfm")
APFMMessage(*) => SendTextMessage("amp")
BerserkMessage(*) => SendTextMessage("zerk")
InvisMessage(*) => SendTextMessage("invis")
EnemiesMessage(*)  => SendTextMessage("Ares Nearby!")