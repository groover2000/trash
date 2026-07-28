

$text = (& "C:\scripts\raid\MegaCliKl.exe" -PDList -aALL
 ) -join "`n"

#$text = Get-Content .\pdtest.txt -Raw

$disks = [Regex]::Matches($text, 
    '(?ms)^Enclosure Device ID:.*?(?=Enclosure Device|\Z)'
    )

$result = foreach($disk in $disks)
{
    $pd = @{}
    
    $lines = $disk -split "`n"

    foreach($line in $lines)
    {
        if($line -match '^\s*([^:]+)\s*:\s*(.*)$'){

            $key = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            $pd[$key] = $value

        }
    }

    $rawState = ($pd['Firmware state'] -replace ',.*').Trim()

    $state = switch -Regex ($rawState)
        {
            '^Online'               { 0 }
            '^Hotspare'             { 1 }
            '^Rebuild'              { 2 }
            '^Failed'               { 3 }
            '^Offline'              { 4 }
            '^Unconfigured\(good\)' { 5 }
            '^Unconfigured\(bad\)'  { 6 }
            '^Foreign'              { 7 }
            '^Missing'              { 8 }
            default                 { 9 }
        }

    [PSCustomObject]@{
    Slot        = $pd['Slot Number']
    DiskGroup   = ($pd["Drive's postion"] -match 'DiskGroup:\s*(\d+)') ? $Matches[1] : $null
    State       = $state
    Model       = $pd['Inquiry Data']
    Size        = $pd['Raw Size']
    MediaType   = $pd['Media Type']
    Bus         = $pd['PD Type']
    Temp        = [int]($pd['Drive Temperature'] -replace "C.*")
    MediaErrors = [int]$pd['Media Error Count']
    OtherErrors = [int]$pd['Other Error Count']
    Predictive  = [int]$pd['Predictive Failure Count']
    SmartAlert  = [int]($pd['Drive has flagged a S.M.A.R.T alert'] -eq "Yes")
}
}

$result | ConvertTo-Json