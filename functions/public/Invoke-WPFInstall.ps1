function Invoke-WPFInstall {
    param (
        [Parameter(Mandatory=$false)]
        [PSObject[]]$PackagesToInstall = $($sync.selectedApps | Foreach-Object { $sync.configs.applicationsHashtable.$_ })
    )
    <#

    .SYNOPSIS
        Installs the selected programs using winget, if one or more of the selected programs are already installed on the system, winget will try and perform an upgrade if there's a newer version to install.

    #>

    if($sync.ProcessRunning) {
        $msg = "[Invoke-WPFInstall] An Install process is currently running."
        [System.Windows.MessageBox]::Show($msg, "Winutil", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return
    }

    if ($PackagesToInstall.Count -eq 0) {
        $WarningMsg = "Please select the program(s) to install or upgrade"
        [System.Windows.MessageBox]::Show($WarningMsg, $AppTitle, [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return
    }
    $ChocoPreference = $($sync.ChocoRadioButton.IsChecked)
    $WingetPreference = $($sync.WingetRadioButton.IsChecked)
    $installHandle = Invoke-WPFRunspace -ParameterList @(("PackagesToInstall", $PackagesToInstall),("ChocoPreference", $ChocoPreference)) -DebugPreference $DebugPreference -ScriptBlock {
        param($PackagesToInstall, $ChocoPreference, $DebugPreference)
        if ($PackagesToInstall.count -eq 1) {
            $sync.form.Dispatcher.Invoke([action]{ Set-WinUtilTaskbaritem -state "Indeterminate" -value 0.01 -overlay "logo" })
        } else {
            $sync.form.Dispatcher.Invoke([action]{ Set-WinUtilTaskbaritem -state "Normal" -value 0.01 -overlay "logo" })
        }
        $packagesWinget,$packagesChoco,$packagesLocal = {
            $packagesWinget = [System.Collections.ArrayList]::new()
            $packagesChoco = [System.Collections.ArrayList]::new()
            $packagesLocal = [System.Collections.Hashtable]::new()

            foreach ($package in $PackagesToInstall) {
                if ($ChocoPreference) {
                    if ($package.choco -ne "na")
                    {
                        $null = $packagesChoco.add($package.choco)
                        Write-Host "Queueing $($package.choco) for Chocolatey install"
                    }
                    elseif($package.local -ne "na")
                    {
                        $packagesLocal.add($package.local,$package.args)
                        Write-Host "Queueing $($package.local) for Local install"
                    }
                    else
                    {
                        $packagesWinget.add($package.winget)
                        Write-Host "Queueing $($package.winget) for Winget install"
                    }
                }
                if ($WingetPreference) {
                    if ($package.winget -ne "na")
                    {
                        $packagesWinget.add($package.winget)
                        Write-Host "Queueing $($package.winget) for Winget install"
                    }
                    elseif($package.local -ne "na")
                    {
                        $packagesLocal.add($package.local,$package.args)
                        Write-Host "Queueing $($package.local) for Local install"
                    }
                    else
                    {
                        $null = $packagesChoco.add($package.choco)
                        Write-Host "Queueing $($package.choco) for Chocolatey install"
                    }
                }
                else {
                    if ($package.local -ne "na")
                    {
                        $packagesLocal.add($package.local,$package.args)
                    Write-Host "Queueing $($package.local) for Local install"
                    }
                    elseif($package.winget -ne "na")
                    {

                        $packagesWinget.add($package.winget)
                        Write-Host "Queueing $($package.winget) for Winget install"
                    }
                    else {
                    $null = $packagesChoco.add($package.choco)
                    Write-Host "Queueing $($package.choco) for Chocolatey install"
                }
            }
        }
        return $packagesWinget, $packagesChoco, $packagesLocal
        }.Invoke($PackagesToInstall)


        try {
            $sync.ProcessRunning = $true
            $errorPackages = @()

            if($packagesLocal.Count -gt 0) {
                Install-WinUtilProgramLocal -Action Install -Programs $packagesLocal
            }

            if($packagesWinget.Count -gt 0) {
                Install-WinUtilWinget
                Install-WinUtilProgramWinget -Action Install -Programs $packagesWinget

            }
            if($packagesChoco.Count -gt 0) {
                Install-WinUtilChoco
                Install-WinUtilProgramChoco -Action Install -Programs $packagesChoco
            }
            Write-Host "==========================================="
            Write-Host "--      Installs have finished          ---"
            Write-Host "==========================================="
            $sync.form.Dispatcher.Invoke([action]{ Set-WinUtilTaskbaritem -state "None" -overlay "checkmark" })
        } catch {
            Write-Host "==========================================="
            Write-Host "Error: $_"
            Write-Host "==========================================="
            $sync.form.Dispatcher.Invoke([action]{ Set-WinUtilTaskbaritem -state "Error" -overlay "warning" })
        }
        $sync.ProcessRunning = $False
    }
}
