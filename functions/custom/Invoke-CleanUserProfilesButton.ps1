function Invoke-CleanUserProfilesButton
{
    #TODO inline this program? make it both a function and writable string to install?
    Start-Process  -FilePath "$winutildir/CleanUserProfiles.bat"
}
