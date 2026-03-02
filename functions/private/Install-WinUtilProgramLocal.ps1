function Install-WinUtilProgramLocal
{
      <#
    .SYNOPSIS
    Attempt to install the provided programs.

    .PARAMETER Programs
    A list of programs to process

       .PARAMETER action
    The action to perform on the programs, can be either 'Install' or 'Uninstall'
    #>

    param(
        [Parameter(Mandatory, Position=0)]$Programs,

        [Parameter(Mandatory, Position=1)]
        [ValidateSet("Install", "Uninstall")]
        [String]$Action
    )

    Function Invoke-MSI
    {
         <#
        .SYNOPSIS
        Actually runs the MSI for installing the program

        .PARAMETER program
        The full path to the program that should be installed

        .PARAMETER arguments
        Extra arguments to include when running the installer.
        #>
        param (
            [string]$program,
            [string]$arguments
        )

        if ($Action -eq "Install")
        {
            $fullArgs = "/quiet /norestart $arguments /i $program"
        }
        else
        {
            $fullArgs = "/quiet /norestart /x $program"
        }

        $processParams =
        @{
            FilePath = "msiexec"
            ArgumentList = $fullArgs
            Wait = $true
            PassThru = $true
            NoNewWindow = $true
        }

        return (Start-Process @processParams).ExitCode
    }
    Function Invoke-Exe
    {
        <#
        .SYNOPSIS
        Actually runs the MSI for installing the program

        .PARAMETER program
        The full path to the program that should be installed

        .PARAMETER arguments
        Extra arguments to include when running the installer.
        #>

         <#
        .SYNOPSIS
        Actually runs the MSI for installing the program

        .PARAMETER program
        The full path to the program that should be installed

        .PARAMETER arguments
        Extra arguments to include when running the installer.
        #>
        param (
            [string]$program,
            [string]$arguments
        )

        $processParams =
        @{
            FilePath = $program
            ArgumentList = $arguments
            Wait = $true
            PassThru = $true
            NoNewWindow = $true
        }



        return (Start-Process @processParams).ExitCode
    }
    Function Invoke-Install
    {
        <#
        .SYNOPSIS
        Contains the Install Logic and return code handling from winget

        .PARAMETER program
        The full path to the program that should be installed

        .PARAMETER arguments
        Extra arguments to include when running the installer.
        #>
        param (
            [string]$program,
            [string]$arguments
        )
            $extension = $program.Split(".")[-1];
            # TODO actually check status for error during install
            if($extension -eq "msi")
            {
                $status = Invoke-MSI $program $arguments
            }
            elseif ($extension -eq "exe")
            {
                $status = Invoke-EXE $program $arguments
            }
            else
            {
                Write-Host "$($program) has an unknown extension."
                return $false
            }

            Write-Host "$($program) installed successfully."
            return $true
    }

    Function Invoke-Uninstall
    {
        <#
        .SYNOPSIS
        Contains the Uninstall Logic and return code handling

        .PARAMETER program
        The full path to the program that should be uninstalled
        #>

        param (
            [string]$program
        )

        $extension = $program.Split(".")[-1];
        # TODO actually check status for error during uninstall
        if($extension -eq "msi")
        {
            $status = Invoke-MSI $program
        }
        elseif ($extension -eq "exe")
        {
            # TODO maybe attempt winget uninstall?
            Write-Host "Cannot uninstall '$program' because it is a .exe file."
            return $false
        }
        else
        {
            Write-Host "$($program) has an unknown extension."
            return $false
        }

        Write-Host "$($program) uninstalled successfully."
        return $true
    }

    $count = $Programs.Count
    $failedPackages = @()

    Write-Host "==========================================="
    Write-Host "--    Configuring local packages       ---"
    Write-Host "==========================================="

   for ($i = 0; $i -lt $count; $i++)
   {
        $Program = $Programs[$i]
        $result = $false
        Set-WinUtilProgressBar -label "$Action $($program[0])" -percent ($i / $count * 100)
        Invoke-WPFUIThread -ScriptBlock { Set-WinUtilTaskbaritem -value ($i / $count)}

        $result = switch ($Action) {
            "Install" {Invoke-Install -program $program[0] -arguments $program[1]}
            "Uninstall" {Invoke-Uninstall -program $program[0]}
            default {throw "[Install-WinUtilProgramLocal] Invalid action: $Action"}
        }

        if (-not $result) {
            $failedPackages += $Program
        }
    }

    Set-WinUtilProgressBar -label "$($Action)ation done" -percent 100
    return $failedPackages
}
