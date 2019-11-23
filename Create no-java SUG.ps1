# Author: Roger Cossaboom 2019-Nov-22
# Function: Copies a SCCM SUG to another SUG, while filtering out Oracle JRE
#           for the purpose of creating a SUG to be used to exclude clients from JRE updates
# Vesion 1.0.0.0

$Source_SUG = 'SUG - Windows Desktop Updates - Third Party Updates - 2019-11'

$Dest_SUG = "$Source_SUG - No Oracle JRE"

$Dest_Description = "Filtered copy of [$Source_SUG] - excludes Java Runtime Environment"

Write-Host "Processing Begins" 
if (Get-CMSoftwareUpdateGroup -Name $Dest_SUG) {
    write-host "SUG already exists. Aborting" -ForegroundColor Green
} else {
    
    write-host "Create SUG: $Dest_SUG" -ForegroundColor Green
    Write-Host " -- $Dest_Description" -ForegroundColor Green
    write-host 
    New-CMSoftwareUpdateGroup -Name $Dest_SUG -Description $Dest_Description | out-null
    
    Write-Host "Scan original SUG: $Source_SUG" -ForegroundColor Green
    Write-Host (" -- " + (Get-CMSoftwareUpdateGroup -Name $Source_SUG).LocalizedDescription) -ForegroundColor Green
    write-host 


    (Get-CMSoftwareUpdateGroup -Name $Source_SUG).updates | 
    foreach {
        write-host '.' -NoNewline -ForegroundColor Green
        Get-CMSoftwareUpdate -Id $_ -fast |
        where { (!($_.LocalizedDisplayName -like 'oracle*' -And $_.BulletinID -like 'jre-*')) } |
        Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName $Dest_SUG | out-null
    }
}
Write-host
Write-Host "Processing ends" 
