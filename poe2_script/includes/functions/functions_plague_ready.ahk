ImgCheck_TL := [2049, 1366]
ImgCheck_BR := [2105, 1381]

;ReadyColor := "0xffffff"
Img_Plague100 := "images\screen_checking\plague_100.png"

Snd_PlagueReady := "sounds\shotgun_rack_01.wav"
Snd_PlagueBlast := "sounds\plague_blast.wav"

bPlagueReady := false

;Define your key for plague bearer below
~R::
{
    global bPlagueReady

    if !WinFocused() {
        return
    }

    if (bPlagueReady) {
        Sleep 600
        if !ImageSearch(&X, &Y, ImgCheck_TL[1], ImgCheck_TL[2], ImgCheck_BR[1], ImgCheck_BR[2], "*TransBlack " Img_Plague100)
        {
            SoundPlay Snd_PlagueBlast
        }
    }
}

Timed_CheckPlagueReady()
{
    global bPlagueReady

    if WinFocused() {
        if ImageSearch(&X, &Y, ImgCheck_TL[1], ImgCheck_TL[2], ImgCheck_BR[1], ImgCheck_BR[2], "*TransBlack " Img_Plague100)
        {
            if (!bPlagueReady) {
                SoundPlay Snd_PlagueReady
                SetTimer(Timed_CheckPlagueReady, -377)
                bPlagueReady := true
                return
            }            
        }
        else {
            bPlagueReady := false
        }
    }

    SetTimer(Timed_CheckPlagueReady, -200)
}