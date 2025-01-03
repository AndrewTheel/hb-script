#Requires AutoHotkey v2.0

Persistent  ; Keeps the script running
SetWorkingDir A_InitialWorkingDir ;Forces the script to use the folder it was initially launched from as its working directory

; Set the path to your NirCmd executable
NirCmdPath := "includes\nircmd.exe"  ; Adjust this to the actual path where NirCmd is located

; Application name (Spotify) and volume adjustment
AppName := "Spotify.exe"

; Increase Spotify volume with Alt + WheelUp
!WheelUp::
{
    Run(NirCmdPath " changeappvolume " AppName " +0.075")
    return
}

; Decrease Spotify volume with Alt + WheelDown
!WheelDown::
{
    Run(NirCmdPath " changeappvolume " AppName " -0.075")  
    return
}
