function Install-WinUtilCleanUserProfiles
{
    param (
        [string]$Loc,
        [bool]$install = $false
    )

    if ($install)
    {
        # Add file to system

        if (!(Test-Path -Path "C:\Windows\System32\GroupPolicy\Machine\Scripts\Shutdown"))
            {mkdir "C:\Windows\System32\GroupPolicy\Machine\Scripts\Shutdown"}

        Copy-Item "res/CleanUserProfiles.ps1" -Destination "C:\Windows\System32\GroupPolicy\Machine\Scripts\Shutdown"

        # Edit registry
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ErrorAction SilentlyContinue | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "HideShutdownScripts" -Type dword -Value 0x00000000
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts" -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown" -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0" -ErrorAction SilentlyContinue | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0" -Name "GPO-ID" -Type string -Value "LocalGPO"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0" -Name "SOM-ID" -Type string -Value "Local"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0" -Name "FileSysPath" -Type string -Value "C:\\Windows\\System32\\GroupPolicy\\Machine"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0" -Name "DisplayName" -Type string -Value "Local Group Policy"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0" -Name "GPOName" -Type string -Value "Local Group Policy"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0" -Name "PSScriptOrder" -Type dword -Value 0x00000001
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\0" -ErrorAction SilentlyContinue | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\0" -Name "Script" -Type string -Value "CleanUserProfiles.ps1"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\0" -Name "Parameters" -Type string -Value "-auto"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\0" -Name "IsPowershell" -Type dword -Value 0x00000001
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\0" -Name "ExecTime" -Type qword -Value 0x
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts" -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown" -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0" -ErrorAction SilentlyContinue | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0" -Name "GPO-ID" -Type string -Value "LocalGPO"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0" -Name "SOM-ID" -Type string -Value "Local"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0" -Name "FileSysPath" -Type string -Value "C:\\Windows\\System32\\GroupPolicy\\Machine"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0" -Name "DisplayName" -Type string -Value "Local Group Policy"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0" -Name "GPOName" -Type string -Value "Local Group Policy"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0" -Name "PSScriptOrder" -Type dword -Value 0x00000001
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0\0" -ErrorAction SilentlyContinue | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0\0" -Name "Script" -Type string -Value "CleanUserProfiles.ps1"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0\0" -Name "Parameters" -Type string -Value "-auto"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0\0" -Name "ExecTime" -Type qword -Value 0x
    }
    elseif (!$install)
    {
        rm "C:\Windows\System32\GroupPolicy\Machine\Scripts\Shutdown\CleanUserProfiles.ps1"

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "HideShutdownScripts" -Type dword -Value 0x00000001
        Remove-Item -Path "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0"
        Remove-Item -Path "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0"
    }
}
