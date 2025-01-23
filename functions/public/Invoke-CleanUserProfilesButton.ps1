function Invoke-CleanseUserProfilesButton
{
    Start-Process  -FilePath "$PSScriptRoot/res/CleanUserProfiles.bat"
}
