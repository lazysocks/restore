$id = $env:device_id

$hta_info = @"
<html>
    <head>
    
        <HTA:APPLICATION
            APPLICATIONNAME="System"
            NAVIGABLE="YES"
            APPLICATION="No"
            ID="ViewSystem"
            WINDOWSTATE="maximize"
            VERSION="1.0"/>
    </head> 
    <body> 
      <iframe src="http://portal.c6.confignet.com/sysdb/systems/winpe/${id}/" width="100%" height="100%" application="yes"> 
    </body> 
</html>
"@
[system.io.file]::WriteAllText("X:\device_portal.hta", $hta_info)

if(Test-Path X:\device_portal.hta) {
Start-Process X:\device_portal.hta
} else {
    Write-Host Task to create HTA failed
    Pause
    exit
}
