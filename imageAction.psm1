

function Get-DeviceCfgID {
    [CmdletBinding()] 
    param(
        [Parameter(Mandatory=$True)]
        [string]$api_url
        )
    
        $serialnumber = Get-WmiObject win32_bios | Select-Object SerialNumber -ExpandProperty SerialNumber
        $request_url = $api_url +"api/?system_serial=$serialnumber"
        $system = Invoke-RestMethod -Uri $request_url -Method Get

        [System.Environment]::SetEnvironmentVariable('DEVICE_PORTAL_ID', $system.results.id) 

}



function doImageLog {
    [CmdletBinding()] 
    param(
        [string]$imagePath,
        [string]$imageName,
        [string]$imageType, 
        [string]$api_url,
        [string]$total_time,
        [string]$completed = $False
    )

    $serialnumber = Get-WmiObject win32_bios | Select-Object SerialNumber -ExpandProperty SerialNumber

    $base_url = $api_url

    $id_url = $base_url +"api/?system_serial=$serialnumber" 
    $system = Invoke-RestMethod -Uri $id_url -Method Get
    if ($system.count -ne 1) {
        Z:\CfgMenu\sysinfo.bat
        $system = Invoke-RestMethod -Uri $id_url -Method Get
    }
    
    $id = $system.results.id

    $Body = @{
        system_serial = $id
        image_name = $imageName
        image_path = $imagePath
        image_type = $imageType
        total_time = $total_time
        completed = $completed

    }

    $JsonBody = $Body | ConvertTo-Json

    $Params = @{
        Method = "Post"
        Uri = $base_url + "imagerecord/"
        Body = $JsonBody
        ContentType = "application/json"
    }

    Invoke-RestMethod @Params
  
}