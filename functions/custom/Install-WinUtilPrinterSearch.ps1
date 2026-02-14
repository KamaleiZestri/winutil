
function Install-WinUtilPrinterSearch
{
    param ([bool]$install = $false)

    function SchoolLookup
    {
        <#
        .SYNOPSIS
        Based on 3 digit schoolcode, lookup what search is required for the printer.
        #>
        param([string]$schoolCode = "")

        switch ($schoolCode)
        {
            # TODO make this seperate file loaded into here
            "001" {return "phs"}
            "002" {return "srhs"}
            "003" {return "shhs"}
            "004" {return "dhs_"}
            "007" {return "tege"}
            "013" {return "pmhs"}
            "014" {return "summ"}
            "016" {return "cths"}
            "018" {return "dhs9"}
            "041" {return "bevh"}
            "042" {return "jksn"}
            "043" {return "pkvw"}
            "044" {return "qis"}
            "045" {return "sanj"}
            "046" {return "shis"}
            "047" {return "sout"}
            "048" {return "mill"}
            "049" {return "thom"}
            "051" {return "bond"}
            "101" {return "bail"}
            "102" {return "fish"}
            "103" {return "free"}
            "104" {return "gard"}
            "105" {return "garf"}
            "106" {return "geno"}
            "107" {return "goldena"}
            "108" {return "pear"}
            "109" {return "jess"}
            "110" {return "krus"}
            "111" {return "mead"}
            "112" {return "park"}
            "113" {return "pome"}
            "114" {return "redb"}
            "115" {return "rich"}
            "116" {return "lfsmith"}
            "117" {return "maes"}
            "118" {return "shes"}
            "119" {return "ssha"}
            "120" {return "will"}
            "122" {return "mcma"}
            "123" {return "stuc"}
            "124" {return "atki"}
            "125" {return "jens"}
            "126" {return "burn"}
            "127" {return "fraz"}
            "128" {return "teag"}
            "129" {return "moor"}
            "130" {return "youn"}
            "131" {return "spar"}
            "132" {return "turn"}
            "133" {return "mora"}
            "134" {return "matt"}
            "135" {return "morr"}
            "136" {return "deza"}
            "137" {return "bush"}
            "138" {return "sbes"}
            "139" {return "loma"}
            "140" {return "meli"}
            "141" {return "mils"}
            "142" {return "rick"}
            "143" {return "shaw"}
            "144" {return "kell"}
            "145" {return "kend"}
            "146" {return "sull"}
            "147" {return "robe"}
            "148" {return "hanc"}
            "855" {return "admin"}

            default {return ""}
        }
    }

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

    $searchText = SchoolLookup($schoolCode)

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
