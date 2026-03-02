function Invoke-RestartPrintSpooler
{
    Write-Host "Deleting printer spool."

    Stop-Service -Name Spooler
    Remove-Item -Path "$env:SystemRoot\\System32\\spool\\PRINTERS\\*.*\"
    Start-Service -Name Spooler

    Write-Host "Printer spool deleted."
}
