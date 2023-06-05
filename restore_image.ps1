# Name of file to use to image with
Param(
[Parameter(Mandatory=$True)]
[string]$imageFile,
[Parameter(Mandatory=$True)]
[string]$imagePath,
[string]$diskNum = "0",
[string]$osLetter = "W",
[string]$sysLetter = "S",
[string]$indexNum = "1",
[bool]$systemProtection = $False,
[Parameter]
[string]$diskPartScriptPath
)
Import-Module $PSScriptRoot\func.psm1
Import-Module $PSScriptRoot\imageAction.psm1

$api_url = "http://portal.c6.confignet.com/sysdb/"
$ErrorActionPreference = 'Stop'
$start_time = Get-Date
$len = $imageFile.Length
$len = $len - 4
$imageName = $imageFile.Remove($len,4)
$imageType = $imageFile.Substring($imageFile.Length - 3)


$log = @{
    api_url = $api_url
    imagePath = $imagePath
    imageName = $imageName
    imageType = $imageType

}

function check_code($LASTEXITCODE) {
    $end_time = Get-Date
    If ($LASTEXITCODE -ne 0){
        $log.total_time = get_total_time $start_time $end_time
        $log.completed = $False
        doImageLog @log
        Pause
        exit
    }
    
}


Write-Host $imageName
Get-Date -Format "dd/MM/yyyy HH:mm:ss"

if ( $imageType -eq "ffu") {

    $doImage = @{
        imagePath = $ImagePath
        imageName = $imageName
        diskNum = $diskNum
    }

    
    applyFFU @doImage 
    check_code $LASTEXITCODE


        
        
        
        

   
   


    

} elseif ( $imageType -eq "wim" -or $imageType -eq "esd") {
    if ([string]::IsNullOrEmpty($diskPartScriptPath)) {

        doPartition $diskNum
        check_code $LASTEXITCODE

    } else {

        $diskpart = Get-Content -Path $diskPartScriptPath
        $diskpart = $diskpart -f $diskNum
        $diskpart | diskpart
        check_code $LASTEXITCODE

    }

    $doImage = @{
        imagePath = $imagePath
        imageName = $imageName
        imageType = $imageType
        driveLetter = $osLetter
        indexNum = $indexNum
    }

    applyWIM @doImage
    check_code $LASTEXITCODE
    if ($systemProtection) {
        enable_system_protection -os $osLetter
        check_code $LASTEXITCODE
    }
    setboot -sysLtr $sysLetter -os $osLetter
    check_code $LASTEXITCODE

} elseif ( $imageType -eq "swm") {
    if ([string]::IsNullOrEmpty($diskPartScriptPath)) {

        doPartition $diskNum
        check_code $LASTEXITCODE

    } else {

        $diskpart = Get-Content -Path $diskPartScriptPath
        $diskpart = $diskpart -f $diskNum
        $diskpart | diskpart
        check_code $LASTEXITCODE

    }

    $doImage = @{
        imagePath = $imagePath
        imageName = $imageName
        driveLetter = $osLetter
        indexNum = $indexNum
    }

    applySWM @doImage
    check_code $LASTEXITCODE
    if ($systemProtection) {
        enable_system_protection -os $osLetter
        check_code $LASTEXITCODE
    }
    setboot -sysLtr $sysLetter -os $osLetter
    check_code $LASTEXITCODE
    

}






Get-Date -Format "dd/MM/yyyy HH:mm:ss"

$end_time = Get-Date   
$msg = get_total_time $start_time $end_time
$log.total_time = $msg
$log.completed = $True
Write-Host $msg
doImageLog @log 
pause
