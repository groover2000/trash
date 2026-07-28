
$text = (& "C:\scripts\raid\MegaCliKl.exe" -LDInfo -Lall -aALL
 ) -join "`n"


#$text = Get-Content .\LD.txt -Raw
# Регулярка находит начало строки Virtual Drive 
# до такого же Drive через lookahead или абсолютного конца строки
$vDrives = [Regex]::Matches($text,
'(?ms)^Virtual Drive:.*?(?=^Virtual Drive:|\Z)'
)



$result = foreach($block in $vDrives)
{
    $vd = @{}

    $lines = $block.Value -split "`n"

    foreach($line in $lines)
    {
        if($line -match '^\s*([^:]+)\s*:\s*(.*)$'){
            $key = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            $vd[$key] = $value
        }
    }
    
    $vdId = $null
    $targetId = $null

    if($vd["Virtual Drive"] -match '^(\d+)\s+\(Target Id:\s+(\d+)\)')
    {
        $vdId = [int]$Matches[1]
        $targetId = [int]$Matches[2]
    }

    [PSCustomObject]@{
        vd = $vdId
        targetId = $targetId
        state = $vd["State"]
        size = $vd["Size"]
        raid = $vd["RAID Level"]
        badblocks = [int]($vd["Bad Blocks Exist"] -eq "Yes")
        cachePolicy = $vd["Current Cache Policy"]
    } 
}
$result | ConvertTo-Json #-Depth 3 -Compress
