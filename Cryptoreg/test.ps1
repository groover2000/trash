
$DurationSeconds = 8
$DelayMs = 40
$Chars = "0123456789ABCDEF"

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\08F19F05793DC7340B8C2621D83E5BE5\InstallProperties"
$ValueName = "ProductID"


Clear-Host
Write-Host "Initializing system..." -ForegroundColor Green
Start-Sleep 1

$endTime = (Get-Date).AddSeconds($DurationSeconds)

while ((Get-Date) -lt $endTime) {
    $width = [Console]::WindowWidth
    $line = ""

    for ($i = 0; $i -lt $width; $i++) {
        $line += $Chars[(Get-Random -Maximum $Chars.Length)]
    }

    Write-Host $line -ForegroundColor Green
    Start-Sleep -Milliseconds $DelayMs
}


Write-Host ""
Write-Host "Accessing registry..." -ForegroundColor Green
Start-Sleep 1

try {
    $ProductID = (Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop).$ValueName
    Write-Host ""
    Write-Host "ProductID найден:" -ForegroundColor Green -NoNewline
    Write-Host " $ProductID" -ForegroundColor White
}
catch {
    Write-Host ""
    Write-Host "ProductID не найден или нет доступа к реестру" -ForegroundColor Red
}

[void][System.Console]::ReadLine()