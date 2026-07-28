function Get-StorCliJson {
    param(
        [string]$CliArgs
    )

    #$raw = Get-Content $CliArgs

    $raw = storcli64 $CliArgs 
    return $raw | ConvertFrom-Json
}

$json = Get-StorCliJson "/call show J"
#$json = Get-StorCliJson ".\show.json"
# $json = Get-StorCliJson ".\test_all.json"

$result =@()

foreach($controller in $json.Controllers)
{
    $response = $controller."Response Data"

    $controllerObject = [PSCustomObject]@{
        
        ControllerId = $controller."Command Status".Controller
        Model = $response."Product Name"
        Serial = $response."Serial Number"
        CacheVaultState = $response."Cachevault_Info".State
        CacheVaultTemp = [int]($response."Cachevault_Info".Temp -replace "[^\d]")

        
        VD = @()
        PD = @()
    }

    foreach($vd in $response."VD LIST"){

        $controllerObject.VD += [PSCustomObject]@{

            ControllerId = $controller."Command Status".Controller
            Id = $vd."DG/VD"
            Type = $vd.TYPE
            State = $vd.State
            Size = $vd.Size
        }
    }

    foreach($pd in $response."PD LIST"){

        $controllerObject.PD += [PSCustomObject]@{
            
            ControllerId = $controller."Command Status".Controller
            DiskId = $pd."EID:Slt"
            EnclosureId = ($pd."EID:Slt" -split ":")[0]
            Slot = ($pd."EID:Slt" -split ":")[1]
            State = $pd.State
            Size = $pd.Size
            Model = $pd.Model
        }
    }

    $result += $controllerObject
    
}

$result | ConvertTo-Json -Depth 3 -AsArray



