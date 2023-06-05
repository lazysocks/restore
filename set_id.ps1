Import-Module Z:\CfgMenu\Images\restore\imageAction.psm1

Get-DeviceCfgID -api_url http://portal.c6.confignet.com/sysdb/
$var = @"
@echo off
set device_id=${env:DEVICE_PORTAL_ID}
"@


[system.io.file]::WriteAllText("X:\dev_id.bat", $var)
