$regexp = @{

    KeyValue = "^\s*([^:]+)\s*:\s*(.*)$"
}

$text = Get-Content .\ld.txt -Raw 

$st = [Regex]::Match($text, 
    "(?ms)^Logical Device number.*?(?=--)").Value -split "`r?`n"

$arr = @{}

foreach($string in $st){
    
    if($string -match $regexp['KeyValue']){

        $key = $Matches[1] -replace "\s"
        $value = $Matches[2]

        $arr[$key] = $value
    }
}

[PSCustomObject]@{
    "size_mb"        = [int]($arr["Size"] -replace "[^\d]")
    "name"           = $arr["LogicalDevicename"]
    "raid_level"     = [int]$arr["RAIDlevel"]
    "status"         = $arr["StatusofLogicalDevice"]
    "failed_stripes" = $arr['Failedstripes'] -eq "Yes"
    "write_cache"    = $arr["Write-cachestatus"] -eq "On"
    "hot_spare"      = $arr["ProtectedbyHot-Spare"] -eq "Yes"
    "read_cache"     = $arr["Read-cachestatus"] -eq "On"
} | ConvertTo-Json
