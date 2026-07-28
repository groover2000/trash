[xml]$xml = Get-Content ".\Drives.xml"

$volumes = foreach ($drive in $xml.Drives.Drive) {
    
    $fullpath = $drive.Properties.path.TrimStart("\").Split("\")
    $groups = @(
        foreach ($group in $drive.Filters.FilterGroup) {
            ($group.name -split '\\')[-1]
        }

    )
    [PSCustomObject]@{
        Path   = $fullpath[1..($fullpath.Count - 1)] -join "/"
        Groups = $groups
    }
}

$yaml = @()

$yaml += "pam_mount_volumes:"

foreach ($volume in $volumes) {
    $yaml += "  - path: $($volume.path)"
    $yaml += "    groups:"

    foreach ($group in $volume.groups) {
        $yaml += "      - $group"
    }
}

$yaml | Set-Content -Path ".\pam_mount.yml" -Encoding UTF8
    
