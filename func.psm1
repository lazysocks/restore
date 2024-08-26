

function catchExitCode{
    $errmsg = "Something went wrong. Contact CEG for assitance."
    if ( $LASTEXITCODE -ne 0) {
        throw $errmsg
    }
}

$ErrorActionPreference = 'Stop'
function applyFFU{
    [CmdletBinding()] 
    param(
        [string]$imagePath,
        [string]$imageName,
        [string]$diskNum
    )

    $path_to_file = $imagePath + "\" + $imageName + ".ffu"
    dism /apply-ffu /imagefile:$path_to_file /ApplyDrive:\\.\PhysicalDrive${diskNum}
    
  
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

function enable_system_protection {
    [CmdletBinding()] 
    param(
        [string]$os
    )
""
"Enabling System Protection on C:"
reg load HKLM\image ${os}:\Windows\System32\Config\SOFTWARE
$path  = "HKLM:\Image\Microsoft\Windows NT\CurrentVersion\SPP\Clients" 
If (!(Test-Path $path))
{
   New-Item -Path $path -Force | Out-Null
}
$item  = get-item $path
$key   = $item | select-object -expandProperty property | select-object -first 1
if( $key -eq $null )
{
   $key = "{09F7EDC5-294E-4180-AF6A-FB0E6A0E9513}"
}
$drive = GWMI -namespace root\cimv2 -class win32_volume | where DriveLetter -EQ "${os}:" | select-object -expandProperty DeviceID
$value = $drive + ":Windows (C%3A)"
set-itemproperty -Path $path -type multistring -Name $key -Value $value
$item.Handle.Close()
$path = $null
$item = $null
$key  = $null
[system.gc]::Collect()
reg unload HKLM\image

""
}

function get_total_time($start_time, $end_time){
    $elapsed = $end_time - $start_time
    $total_time = "{0:d2}:{1:d2}:{2:d2} seconds total elapsed time" -f $elapsed.Hours, $elapsed.Minutes, $elapsed.Seconds
    $total_time

}

function display_disks(){
    python Z:\CfgMenu\python-3.9.1\list_disk.py
}

function inject_drivers(){
    [CmdletBinding()] 
    param(
        [string]$imagePath,
        [string]$driverBaseDir = "drivers",
        [string]$driverFolder,
        [string]$driveletter
    )
    Write-Host "Installing Drivers..."
    $fullDriverPath = $imagePath + "\" + $driverBaseDir + "\" + $driverFolder
    dism.exe /Image:${driveletter}:\ /Add-Driver /Driver:$fullDriverPath /ForceUnsigned /recurse
    
}
