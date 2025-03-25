function Invoke-WPFUnInstall {
    param(
        [Parameter(Mandatory=$false)]
        [PSObject[]]$PackagesToUninstall = $($sync.selectedApps | Foreach-Object { $sync.configs.applicationsHashtable.$_ })
    )
    <#

    .SYNOPSIS
        Uninstalls the selected programs
    #>

    if($sync.ProcessRunning) {
        $msg = "[Invoke-WPFUnInstall] Install process is currently running"
        [System.Windows.MessageBox]::Show($msg, "Winutil", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return
    }

    if ($PackagesToUninstall.Count -eq 0) {
        $WarningMsg = "Please select the program(s) to uninstall"
        [System.Windows.MessageBox]::Show($WarningMsg, $AppTitle, [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return
    }

    $ButtonType = [System.Windows.MessageBoxButton]::YesNo
    $MessageboxTitle = "Are you sure?"
    $Messageboxbody = ("This will uninstall the following applications: `n $($PackagesToUninstall | Select-Object Name, Description| Out-String)")
    $MessageIcon = [System.Windows.MessageBoxImage]::Information

    $confirm = [System.Windows.MessageBox]::Show($Messageboxbody, $MessageboxTitle, $ButtonType, $MessageIcon)

    if($confirm -eq "No") {return}
    $ChocoPreference = $($sync.ChocoRadioButton.IsChecked)
    $WingetPreference - ($sync.WingetRadioButton.IsChecked)

    Invoke-WPFRunspace -ArgumentList @(("PackagesToUninstall", $PackagesToUninstall),("ChocoPreference", $ChocoPreference)) -DebugPreference $DebugPreference -ScriptBlock {
        param($PackagesToUninstall, $ChocoPreference, $DebugPreference)
        if ($PackagesToUninstall.count -eq 1) {
            $sync.form.Dispatcher.Invoke([action]{ Set-WinUtilTaskbaritem -state "Indeterminate" -value 0.01 -overlay "logo" })
        } else {
            $sync.form.Dispatcher.Invoke([action]{ Set-WinUtilTaskbaritem -state "Normal" -value 0.01 -overlay "logo" })
        }
        $packagesWinget, $packagesChoco, $packagesLocal = {
            $packagesWinget = [System.Collections.ArrayList]::new()
            $packagesChoco = [System.Collections.ArrayList]::new()
            $packagesLocal = [System.Collections.Hashtable]::new()

        foreach ($package in $PackagesToUninstall) {
            if ($ChocoPreference) {
                if ($package.choco -eq "na") {
                    $packagesWinget.add($package.winget)
                    Write-Host "Queueing $($package.winget) for Winget uninstall"
                } else {
                    $null = $packagesChoco.add($package.choco)
                    Write-Host "Queueing $($package.choco) for Chocolatey uninstall"
                }
                elseif ($WingetPreference) {
                    if ($package.winget -ne "na") {
                        $packagesWinget.add($package.winget)
                        Write-Host "Queueing $($package.winget) for Winget uninstall"
                    }
                    elseif ($package.local -ne "na") {
                        $null = $packagesLocal.add($package.local,$package.args)
                        Write-Host "Queueing $($package.local) for Local uninstall"
                    }
                    else {
                        $null = $packagesChoco.add($package.choco)
                        Write-Host "Queueing $($package.choco) for Chocolatey uninstall"
                    }
                }
                else {
                    if ($package.local -ne "na") {
                        $null = $packagesLocal.add($package.local,$package.args)
                        Write-Host "Queueing $($package.local) for Local uninstall"
                    }
                    elseif ($package.winget -ne "na") {

                        $packagesWinget.add($package.winget)
                        Write-Host "Queueing $($package.winget) for Winget uninstall"
                    }
                    else {
                        $null = $packagesChoco.add($package.choco)
                        Write-Host "Queueing $($package.choco) for Chocolatey uninstall"
                    }
                }
            }
        }
        return $packagesWinget, $packagesChoco, $packagesLocal
        }.Invoke($PackagesToInstall)

        try {
            $sync.ProcessRunning = $true

            # Install all selected programs in new window
            if($packagesLocal.Count -gt 0)
            {
                Install-WinUtilProgramLocal -Action Uninstall -Programs $packagesLocal
            }
            if($packagesWinget.Count -gt 0) {
                Install-WinUtilProgramWinget -Action Uninstall -Programs $packagesWinget
            }
            if($packagesChoco.Count -gt 0) {
                Install-WinUtilProgramChoco -Action Uninstall -Programs $packagesChoco
            }

            Write-Host "==========================================="
            Write-Host "--       Uninstalls have finished       ---"
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
