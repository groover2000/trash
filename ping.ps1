1..126 | ForEach-Object {
    $ip = "192.168.116.$_"
    Write-Host "Проверяю $ip ..."
    if (Test-Connection $ip -Count 1 -Quiet) {
        Write-Host "  [+] $ip отвечает" -ForegroundColor Green
    } else {
        Write-Host "  [-] нет ответа"
    }
}