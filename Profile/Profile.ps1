﻿<#
.SYNOPSIS
  @TsekNet PowerShell Profile.

.DESCRIPTION
  My heavily customized PowerShell profile. Feel free to use and distrubute as
  you see fit. Always improving this, if you catch any errors, or see where I
  can improve this, please let me know!

  To use this profile, simply place this file in any of your $profile
  directories and restart your PowerShell console
  (Ex: $profile.CurrentUserAllHosts)

.LINK
  TsekNet.com
  GitHub.com/TsekNet
  Twitter.com/TsekNet
#>

#region function declarations

# Helper function to change directory to my development workspace
function Set-Path {
  $Path = 'C:\Tmp\'
  if (-not (Test-Path -Path $Path)) {
    New-Item -ItemType Directory -Force -Path $Path
  }
  Set-Location $Path
}

# Helper function to copy the last command entered
function Copy-LastCommand {
  Get-History -id $(((Get-History) | Select-Object -Last 1 |
      Select-Object ID -ExpandProperty ID)) |
  Select-Object -ExpandProperty CommandLine |
  clip
}

# Helper function to ensure all modules are loaded, with error handling
function Get-MyModules {
  try {
    Import-Module posh-git -ErrorAction Stop
  }
  catch {
    Install-Module posh-git -Scope CurrentUser -Force
    Import-Module posh-git
  }

  try {
    Import-Module oh-my-posh -ErrorAction Stop
  }
  catch {
    Install-Module oh-my-posh -Scope CurrentUser -Force
    Import-Module oh-my-posh
  }

  try {
    Import-Module Get-ChildItemColor -ErrorAction Stop
  }
  catch {
    Install-Module Get-ChildItemColor -Scope CurrentUser -Force
    Import-Module Get-ChildItemColor
  }
}

# Helper function to test prompt elevation
function Test-IsAdministrator {
  if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    $n = "Administrator"
  }
  else {
    $n = "Non-Admin"
  }
}

#endregion

#region statements

# If it's Windows PowerShell, we can turn on Verbose output if you're holding shift
if ("Desktop" -eq $PSVersionTable.PSEdition) {
  # Check SHIFT state ASAP at startup so I can use that to control verbosity :)
  Add-Type -Assembly PresentationCore, WindowsBase
  try {
    if ([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -OR
      [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)) {
      $VerbosePreference = "Continue"
    }
  }
  catch {
    # If that didn't work ... oh well.
  }
}

#endregion

#region execution

Test-IsAdministrator

$host.ui.RawUI.WindowTitle = "PowerShell [ $($n) |
$(([regex]"\d+\.\d+.\d+").match($psversiontable.psversion).value) |
$($psversiontable.psedition) |
$env:username@$env:COMPUTERNAME.$env:USERDOMAIN ]"

# Import all my modules
Get-MyModules

# Set ll and ls alias to use the new Get-ChildItemColor cmdlets
Set-Alias ll Get-ChildItemColor -Option AllScope
Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope

# Set the oh-my-posh theme
Set-Theme Paradox

# Set the current directory to the one set in the function above
Set-Path

#endregion