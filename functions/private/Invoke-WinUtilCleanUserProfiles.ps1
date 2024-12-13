function Invoke-WinUtilCleanUserProfiles
{
     <#

        .DESCRIPTION
        This function delete multiple user profiles.

        .EXAMPLE

        CleanUserProfiles -auto -exceptusers "administrator John Jim"

    #>
    param
    (
        [string]$exceptusers,
        [switch]$dry = $false,
        [switch]$auto = $false
    )


    $exceptions = @("Administrator",
        "defaultuser0",
        "NetworkService",
        "LocalService",
        "systemprofile"
    )

    # TODO maybe have except pattern via regex as well?
    if (!([string]::IsNullOrWhiteSpace($exceptusers)))
    {
        $exceptions = $($exceptions;$exceptusers.split(" "))
    }

    $userProfiles = Get-CimInstance -Class Win32_UserProfile

    $currentProfile = query session | select-string console | foreach { -split $_ } | select -index 1
    $exceptions += $currentProfile

    Write-Host "Currently logged in as '$currentProfile' `n"

    # Ask users for exception profiles if not provided in command
    if ([string]::IsNullOrWhiteSpace($exceptusers) -and !$auto)
    {
        $profileList = @()
        $profileExceptionList = @()

        Write-Host "Current User Profiles on device(excluding current): "

        for ($i=0; $i -lt $userProfiles.length; $i++)
        {
            $userProfile = $userProfiles[$i].LocalPath.split('\')[-1];

            if (!($exceptions -contains $userProfile))
            {
                $profileList += $userProfile
                Write-Host "$i - $userProfile"
            }
        }

        $response = Read-Host "Write the number of each item to EXCLUDE (be sure to seperate with spaces)"

        if (!([string]::IsNullOrWhiteSpace($response)))
        {
            $responseList = $response.split(" ")

            for($i=0; $i -lt $responseList.length; $i++)
            {
                $userProfile = $profileList[$responseList[$i]]
                $profileExceptionList += $userProfile
            }

            $exceptions = $($exceptions;$profileExceptionList);
        }
    }

    #PISD SPICE. aka check for teacher profiles; dont delete those on auto
    $autoInclusions = @("Mill_LRC")

    if ($auto)
    {
        for ($i=0; $i -lt $userProfiles.length; $i++)
        {
            $userProfile = $userProfiles[$i].LocalPath.split('\')[-1];

            if ($userProfile.substring(2) -as [int] -eq $null -and $autoInclusions -notcontains $userProfile)
            {
                $exceptions += $userProfile
                # TODO might have to handle this one differently for display purposes
                $profileExceptionList += $userProfile
            }
        }
    }
    #END PISD SPICE

    Write-Host "###############################"
    Write-Host "The following profiles will be DELETED:"
    for ($i=0; $i -lt $userProfiles.length; $i++)
    {
        $userProfile = $userProfiles[$i].LocalPath.split('\')[-1];

        if (!($exceptions -contains $userProfile))
        {
            Write-Host "$i. $userProfile"
        }
    }

    Write-Host "The following profiles will be KEPT:"
    for($i=0; $i -lt $profileExceptionList.length; $i++)
    {
        $userProfile = $profileExceptionList[$i]
        Write-Host "$i. $userProfile"
    }

    Write-Host "###############################"

    if(!$auto)
    {
        $continue = Read-Host "Continue? (type any letter to cancel. Just Enter to proceed)"

        if(!([string]::IsNullOrWhiteSpace($continue)))
        {
            break
        }
    }

    # Delete every user profile not in $exceptions
    for ($i=0; $i -lt $userProfiles.length; $i++)
    {
        $userProfile = $userProfiles[$i].LocalPath.split('\')[-1];

        if (!($exceptions -contains $userProfile))
        {
            Write-Host "Now deleting profile of '$userProfile'..."
            if(!$dry)
            {
                Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq $userProfile } | Remove-CimInstance
            }
            Write-Host "Profile of '$userProfile' has been deleted."
        }
    }

    Write-Host "Done! Excess profiles have been deleted!"
}
