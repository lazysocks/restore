

function catchExitCode{
    $errmsg = "Something went wrong. Contact CEG for assitance."
    if ( $LASTEXITCODE -ne 0) {
        throw $errmsg
    }
}


function applyFFU{
    [CmdletBinding()] 
    param(
        [string]$imagePath,
        [string]$imageName,
        [string]$diskNum
    )

    $path_to_file = $imagePath + "\" + $imageName + ".ffu"
    dism /apply-ffu /imagefile:$path_to_file /ApplyDrive:\\.\PhysicalDrive${diskNum}
    catchExitCode
  
}

function applyWIM {
    [CmdletBinding()] 
    param(
        [string]$imagePath,
        [string]$imageName,
        [string]$imageType,
        [string]$driveLetter,
        [string]$indexNum
    )
    $path_to_file = $imagePath + "\" + $imageName + ".${imageType}"
    dism /apply-image /imagefile:$path_to_file /index:${indexNum} /applydir:${driveLetter}:\
    catchExitCode
}

function applySWM {
    [CmdletBinding()] 
    param(
        [string]$imagePath,
        [string]$imageName,
        [string]$driveLetter,
        [string]$indexNum
    )
    $path_to_file = $imagePath + "\" + $imageName + ".swm"
    $swmfiles = $imagePath + "\" + $imageName + "*.swm"
    dism /apply-image /imagefile:$path_to_file /SWMFile:$swmfiles /index:${indexNum} /applydir:${driveLetter}:\
    catchExitCode
}

function doPartition{
    [CmdletBinding()] 
    param(
        [string]$diskNum
    )

    $diskpart = @"
select disk ${diskNum}
clean
convert gpt
create partition efi size=500
format quick fs=fat32 label="System"
assign letter="S"
create partition msr size=128
create partition primary
format quick fs=ntfs 
assign letter="W"
list part
list volume
exit
"@


$diskpart | diskpart
catchExitCode

}

function setboot{
    [CmdletBinding()] 
    param(
        [string]$sysLtr,
        [string]$os
    )
    ""
    "Installing boot files..."
    bcdboot ${os}:\windows /s ${sysLtr}:
    catchExitCode
    "Configuring boot options..."
    bcdedit /set "{bootmgr}" device partition=${sysLtr}:
    catchExitCode
    bcdedit /set "{default}" device   partition=${os}:
    catchExitCode
    bcdedit /set "{default}" osdevice partition=${os}:
    catchExitCode

}