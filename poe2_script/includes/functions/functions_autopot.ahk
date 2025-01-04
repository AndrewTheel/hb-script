ES_WarningLvl_Pixel := [210, 1174]
ES_WarningLvl_Clr := "0x867d73"

Snd_HeartbeatStress := "sounds\heartbeat_stress_01.wav"

ES_AutoLifePot_Pixel := [297, 1285]
ES_AutoLifePot_Clr := "0x2c292d"

ES_PotIsFresh_Pixel := [341, 1349]
ES_PotIsFresh_Clr := "0xc91d16"

ES_PotOnWarning := IniRead(ConfigFile, "Settings", "ES_PotOnWarningFreshFlask")

Timed_ESHeartBeatWarning()
{
    if WinFocused() {
        if IsColorInRange(ES_WarningLvl_Pixel[1], ES_WarningLvl_Pixel[2], ES_WarningLvl_Clr, 15)
        {
            SoundPlay Snd_HeartbeatStress

            if (ES_PotOnWarning && IsColorInRange(ES_PotIsFresh_Pixel[1], ES_PotIsFresh_Pixel[2], ES_PotIsFresh_Clr, 15)) {
                Send "{1}"
            }

            SetTimer(Timed_ESHeartBeatWarning, -1000)
            return
        }
    }

    SetTimer(Timed_ESHeartBeatWarning, -200)
}

Timed_ESAutoLifePot()
{
    if WinFocused() {
        if IsColorInRange(ES_AutoLifePot_Pixel[1], ES_AutoLifePot_Pixel[2], ES_AutoLifePot_Clr, 15)
        {
            Send "{1}"
            SetTimer(Timed_ESAutoLifePot, -1000)
            return
        }
    }

    SetTimer(Timed_ESAutoLifePot, -200)
}