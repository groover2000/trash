
$DurationSeconds = 10
$Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$SleepMs = 50

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\08F19F05793DC7340B8C2621D83E5BE5\InstallProperties"
$ValueName = "ProductID"

Clear-Host
[Console]::CursorVisible = $false

$width  = [Console]::WindowWidth
$height = [Console]::WindowHeight


$drops = @()
for ($i = 0; $i -lt $width; $i++) {
    $drops += Get-Random -Minimum 0 -Maximum $height
}

$endTime = (Get-Date).AddSeconds($DurationSeconds)


while ((Get-Date) -lt $endTime) {

    for ($x = 0; $x -lt $width; $x++) {

        $y = $drops[$x]

        if ($y -ge 0 -and $y -lt $height) {
            [Console]::SetCursorPosition($x, $y)
            $char = $Chars[(Get-Random -Maximum $Chars.Length)]
            Write-Host $char -ForegroundColor Green -NoNewline
        }

        
        if ($y - 10 -ge 0) {
            [Console]::SetCursorPosition($x, $y - 10)
            Write-Host " " -NoNewline
        }

        
        if ($y -gt $height + (Get-Random -Minimum 0 -Maximum 20)) {
            $drops[$x] = 0
        } else {
            $drops[$x]++
        }
    }

    Start-Sleep -Milliseconds $SleepMs
}


Clear-Host
[Console]::CursorVisible = $true

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
    Write-Host "ProductID не найден или нет доступа" -ForegroundColor Red
}

Write-Host ""
Write-Host "Нажми Enter для выхода..." -ForegroundColor DarkGreen
[void][System.Console]::ReadLine()