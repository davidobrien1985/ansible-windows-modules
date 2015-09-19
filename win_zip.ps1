#!powershell
# This file is part of Ansible
#
# Copyright 2015, David O'Brien <david.obrien@versent.com.au>
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# WANT_JSON
# POWERSHELL_COMMON

Function Test-Key
{
  param (
    [string]$path,
    [string]$key
  )

  if (!(Test-Path $path)) {
    return $false
  }
  if ((Get-ItemProperty $path).$key -eq $null) {
    return $false
  }
  return $true
}

Function Get-FrameworkVersions
{
  $installedFrameworks = @()
  if (Test-Key "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" "Install") {
    $installedFrameworks += "4.0c"
    If ((Get-ItemProperty "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client").Version -like "4.5*") {
      $installedFrameworks += "4.5c"
    }
  }
  If (Test-Key "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" "Install") {
    [int32]$intRelease = (Get-ItemProperty "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full").Release
    Switch ($intRelease)
    {
      "378389" { $installedFrameworks += "4.5" }
      "378675" { $installedFrameworks += "4.5.1" }
      "378758" { $installedFrameworks += "4.5.1" }
    }
  }
  return $installedFrameworks
}

$params = Parse-Args $args;

$result = New-Object psobject @{
  win_zip = New-Object psobject
  changed = $false
}

# Check if all arguments were provided and set defaults for optional params
If ($params.src) {
  $source = $params.src
}
Else {
  Fail-Json $result "mising required argument: src"
}
If ($params.force) {
  $force = $params.force | ConvertTo-Bool
}
Else {
  $force = $false
}

if ($params.dest) {
  $destination = $params.dest
}
else {
  Fail-Json $result "mising required argument: dest"
}

# Check .Net version -ge 4.5
If (-not (Get-FrameworkVersions) -contains '4.5') {
  Fail-Json $result "dotnet Framework 4.5 is required for this module to run."
}

# Check if source actually exist
if (-not (Test-Path -Path $source)) {
  Fail-Json $result "Source $source does not exist"
}

# Check if zip file already exists
if (Test-Path -Path $destination) {
  if (-not ($force)) {
    try {
      Rename-Item -Path $destination -NewName "$($destination.Split('.')[0]).bak" -Force -ErrorAction Stop
    }
    catch {
      $ErrorMessage = $_.Exception.Message
      Fail-Json $result $ErrorMessage
    }
  }
  else {
    Remove-Item -Path $destination -Force
  }
}

# Copy the source to a temporary Backup folder, then zip that folder
$TempDir = $(Join-Path "$([System.IO.Path]::GetTempPath())" AnsibleTemp)

try {
  New-Item -Path $TempDir -ItemType Directory -Force -ErrorAction Stop
}
catch {
  $ErrorMessage = $_.Exception.Message
  Fail-Json $result $ErrorMessage
}

if (Test-Path -Path $source -PathType Container) {
  try {
    Copy-Item -Path $source -Destination $TempDir -Recurse -Force -ErrorAction Stop
  }
  catch {
    $ErrorMessage = $_.Exception.Message
    Fail-Json $result $ErrorMessage
  }
}
else {
  try {
    Copy-Item -Path $source -Destination $TempDir -Force -ErrorAction Stop
  }
  catch {
    $ErrorMessage = $_.Exception.Message
    Fail-Json $result $ErrorMessage
  }
}

# compress the folder
try {
  [Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" )
  [System.IO.Compression.ZipFile]::CreateFromDirectory($TempDir, $destination)
}
catch {
  $ErrorMessage = $_.Exception.Message
  Fail-Json $result $ErrorMessage
}

# cleanup after yourself
Remove-Item -Path $TempDir -Recurse -Force

$result.changed = $true
Set-Attr $result.win_zip 'src' $source.ToString()
Set-Attr $result.win_zip 'dest' $destination.ToString()
Set-Attr $result.win_zip 'force' $force.ToString()

Exit-Json $result;
