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
[Parameter]
[string]$diskPartScriptPath
)
Import-Module $PSScriptRoot\func.psm1

$start_time = Get-Date
$len = $imageFile.Length
$len = $len - 4
$imageName = $imageFile.Remove($len,4)
$imageType = $imageFile.Substring($imageFile.Length - 3)

Write-Host $imageName
Get-Date -Format "dd/MM/yyyy HH:mm:ss"

if ( $imageType -eq "ffu") {

    $doImage = @{
        imagePath = $ImagePath
        imageName = $imageName
        diskNum = $diskNum
    }

    applyFFU @doImage
   


    

} elseif ( $imageType -eq "wim") {
    if ([string]::IsNullOrEmpty($diskPartScriptPath)) {

        doPartition $diskNum

    } else {

        $diskpart = Get-Content -Path $diskPartScriptPath
        $diskpart = $diskpart -f $diskNum
        $diskpart | diskpart

    }

    $doImage = @{
        imagePath = $imagePath
        imageName = $imageName
        driveLetter = $osLetter
        indexNum = $indexNum
    }

    applyWIM @doImage
    setboot -sysLtr $sysLetter -osLtr $osLetter
    
} elseif ( $imageType -eq "swm") {
    if ([string]::IsNullOrEmpty($diskPartScriptPath)) {

        doPartition $diskNum

    } else {

        $diskpart = Get-Content -Path $diskPartScriptPath
        $diskpart = $diskpart -f $diskNum
        $diskpart | diskpart

    }

    $doImage = @{
        imagePath = $imagePath
        imageName = $imageName
        driveLetter = $osLetter
        indexNum = $indexNum
    }

    applySWM @doImage
    setboot -sysLtr $sysLetter -os $osLetter

}






Get-Date -Format "dd/MM/yyyy HH:mm:ss"




$end_time = Get-Date
$elapsed = $end_time - $start_time

""
"{0:d2}:{1:d2}:{2:d2} seconds total elapsed time" -f $elapsed.Hours, $elapsed.Minutes, $elapsed.Seconds

pause
