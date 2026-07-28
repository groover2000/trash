
#$raw = Get-Content .\pd.json  | ConvertFrom-Json

$raw =  storcli64 /call/eall/sall show all J | ConvertFrom-Json

$result = @()

foreach($controller in $raw.Controllers."Response Data")
{

    foreach($property in $controller.PSObject.Properties){
        
        $name = $property.Name

        if($name -notlike "*Detailed Information"){

            continue
        }


        $detail = $property.Value

        #Write-Host $detail
        
        if($name -match "/e(\d+)/s(\d+)"){

            $eid = $Matches[1]
            $slot = $Matches[2]
        }

        $state = $detail.PSObject.Properties | 
            Where-Object { 
                $_.Name -like "* State"
            } |
            Select-Object -ExpandProperty Value

        
        $attr = $detail.PSObject.Properties | 
            Where-Object { 
                $_.Name -like "* Device attributes"
            } |
            Select-Object -ExpandProperty Value

        # Write-Host $state
        $result += [PSCustomObject]@{

            ControllerId = $raw.Controllers."Command Status".Controller
            Model = $attr."Model Number"
            Serial  = $attr.SN.Trim()
            WWN = $attr."WWN"
            Size = $attr."Raw size"
            
            
            DiskID = "$eid`:$slot"
            EnclosureId = [int]$eid
            Slot = [int]$slot

            MediaErrors = $state."Media Error Count"
            OtherErrors = $state."Other Error Count"
            PredictiveFailures = $state."Predictive Failure Count"
            SmartAlert = $state."S.M.A.R.T alert flagged by drive" -eq "No"? 0 : 1
            Temp = $state."Drive Temperature" -replace "C.*"

        }
    }
    
}

$result | ConvertTo-Json -Depth 3
