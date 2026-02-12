
function Install-WinUtilPrinterSearch
{
    param ([bool]$install = $false)

    function StringToHexString
    {
        <#
        .SYNOPSIS
        Converts a given string into its Printer QDS-style hex-equivalent string for "printerNameValue"
        .DESCRIPTION
        The format is "hex-encoded character, 00 pad" for each character and a checksum at the end.
        The checksum only uses the last two digits of the value and is also hex encoded.
        #>
        param([string]$string)

        $output = ""
        $checksum = 0

        foreach($char in $string.GetEnumerator())
        {
            $ascii = [byte][char]$char
            $hexChar = '{0:x}' -f [int][char]$char

            $output += $hexChar + "00"
            $checksum += $ascii
        }

        #cut checksum to its last two digits
        if ($checksum -gt 8192) {$checksum-=8192}
        if ($checksum -gt 4096) {$checksum-=4096}
        if ($checksum -gt 2048) {$checksum-=2048}
        if ($checksum -gt 1024) {$checksum-=1024}
        if ($checksum -gt 512) {$checksum-=512}
        if ($checksum -gt 256) {$checksum-=256}

        $hexChecksum = '{0:x}' -f [int]$checksum

        # no, i dont know why it needs this padding
        return $output + "0000" + $hexChecksum
    }

    function GetEncodedLength
    {
        <#
        .SYNOPSIS
        Returns the  Printer QDS-style hex-equivalent string for "printerNameLength"
        .DESCRIPTION
        It is just a two-digit version of the string's length, doubled with 6 zero padding in between.
        #>
        param([string]$string)

        $len = $string.Length +1

        if ($len -le 10)
        {$len = "0$len"}

        $output = [string]$len + "000000" + [string]$len

        return $output
    }


    if (!$install)
    {

        rm "C:\Users\Default\Desktop\Add Printers.qds"
        return
    }

    $hostname = hostname
    $schoolCode = $hostname.Substring(0,3)

    $searchText = ""

    $hexText = StringToHexString($searchText)
    $hexLength = GetEncodedLength($searchText)


    # write output string
    $fileText=
@"
[CommonQuery]
Handler=5EE6238AC231D011891C00A024AB2DBBC1
Form=70F077B5E27ED011913F00AA00C16E65DB
[DsQuery]
ViewMode=0413000017
EnableFilter=0000000000
[Microsoft.Printers.MoreChoices]
LocationLength=0100000001
LocationValue=000000
color=0000000000
duplex=0000000000
stapling=0000000000
resolution=0000000000
speed=0100000001
sizeLength=0100000001
sizeValue=000000
[Microsoft.Printers]
printerNameLength=$hexLength
printerNameValue=$hexText
[Microsoft.PropertyWell]
Items=0000000000
"@

    Write-Output $fileText | Out-File "C:\Users\Default\Desktop\Add Printers.qds"
}
