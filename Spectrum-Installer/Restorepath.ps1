<# 
    .SYNOPSIS
    Restore Path environmental variable post-java install

    .NOTES 
    NAME: Restorepath.ps1
	VERSION: 1.0
    AUTHOR: Daniel Tsekhanskiy
    LASTEDIT: 3/1/16
#>

# Save the registry entry for the path environment variable to variable $Reg
$Reg = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"

# Import path.xml from the pre-install (Savepath.ps1) saved xml file
$FileName = "$env:TEMP\path.xml"
$OldPath = Import-Clixml $FileName

# Set the Path registry value equal to the one from before post-java install
Set-ItemProperty -Path "$Reg" -Name PATH –Value $OldPath -Force

# Delete path.xml, if it exists
If (Test-Path $FileName){
	Remove-Item $FileName
}

# Set the registry key referencing java's currentversion to what it was Pre java install. This enables java commands from command prompt.
reg import $ENV:TEMP\CurrentVersion.reg


   