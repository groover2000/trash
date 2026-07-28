$regexp = @{

    Devices  = "(?ms)^\s*Device #.*?(?=\s*Device #|\Z)"
    KeyValue = "^\s*(.+?)\s+:\s+(.*)$"
}

$text = Get-Content .\pd.txt -Raw

$dev = [Regex]::Matches($text, $regexp["Devices"])

$arr = @()

foreach($string in $dev){
    
    $lines = $string -split "`r?`n"

    $disk = @{}
    $isDisk = $false

    foreach($line in $lines){

        if($line -match "Device is a Hard Drive")
        {
            $isDisk = $true
        }
        if($line -match "^\s*Device #(\d+)"){
            $disk["id"] = $Matches[1]
        }
        elseif($line -match $regexp['KeyValue']){


            $key = $Matches[1].Trim()
            $value = $Matches[2]

            $disk[$key] = $value
        }   
    }

    if($isDisk){
        $arr += [PSCustomObject]$disk
    }
    

}
[PSCustomObject]$arr | ConvertTo-Json
