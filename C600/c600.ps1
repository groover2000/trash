
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


$regexp = @{

    # Начало RAID Volume
    VolumeInfo = "^--VOLUME INFORMATION--$"
    # Начало дисков в томе
    DisksInfo = "^--DISKS IN VOLUME:\s*.+?\s--$"
    # Парсер ключ значение
    KeyValue = "^\s*([^:]+)\s*:\s*(.*)$"
}


$currentVolume = $null
$currentDisk = $null
$mode = ""


$text = Get-Content .\c600.txt 
#$text = & "IntelVROCCli.exe" -I -v

$result = @()

foreach($line in $text)
{
    if($line -eq "") { continue }

    if($line -match $regexp['VolumeInfo'])
    {
        
        $mode = "Volume"

        if($currentVolume){

            if($currentDisk){
                $currentDisk["Volume"] = $currentVolume["Name"]
                $currentVolume["Disks"] += [PSCustomObject]$currentDisk
                $currentDisk = $null
            }
            $result += [PSCustomObject]$currentVolume
        }
        
        $currentVolume = @{
            Disks = @()
        }
        continue
    }

    if($line -match $regexp['DisksInfo'])
    {
        $mode = "Disk"        
        continue
    }

    if($line -match $regexp['KeyValue'])
    {
        $key = $Matches[1].Trim()
        $value = $Matches[2].Trim()

        if($mode -eq "Volume"){

            $currentVolume[$key] = $value 
        }
        
        if($mode -eq "Disk"){

            if($key -eq "ID"){         # Разбивка нескольких дисков 

                if($currentDisk){            

                    $currentDisk["Volume"] = $currentVolume["Name"]
                    $currentVolume['Disks'] += [PSCustomObject]$currentDisk
                }

                $currentDisk = @{}
            }

            $currentDisk[$key] = $value

        }

    }
}

if($currentDisk){
    
    $currentDisk["Volume"] = $currentVolume["Name"]
    $currentVolume["Disks"] += [PSCustomObject]$currentDisk
}

if($currentVolume){
    
    $result += [PSCustomObject]$currentVolume

}

$result | ConvertTo-Json -Depth 3 -AsArray #-Compress




