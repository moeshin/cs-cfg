param (
  [switch]$Debug,
  [switch]$Force,
  [switch]$Copy
)

function getStreamDir() {
  $dir = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
  if (-not $dir) {
    throw 'Not found Steam dir'
  }
  if (-not (Test-Path $dir -PathType Container)) {
    throw "No exist dir: $dir"
  }
  return $dir
}

function getSteamLibDir(
  [Parameter(Mandatory = $true)]
  [int]$AppId
) {
  $streamDir = getStreamDir
  Write-Debug "streamDir: $streamDir"

  $path = Join-Path $streamDir "steamapps/libraryfolders.vdf"
  if (-not (Test-Path $path -PathType Leaf)) {
    throw "No exist file: $path"
  }
  $lines = (Get-Content $path) -split '\n'

  for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "^\s+""$AppId""\s+""\d+""\s*$") {
      for ($j = $i - 1; $j -ge 0 ; $j--) {
        if ($lines[$j] -match '^\s+"path"\s+"([^"]+)"\s*$') {
          $libDir = $matches[1]
          return $libDir
        }
      }
    }
  }
}

function getFinalPath {
  param (
    [string]$Path
  )

  $item = Get-Item $Path
  while ($item.Target) {
    $item = Get-Item $item.Target
  }

  return $item.FullName
}

function installMyCs2Cfg(
  [switch]$Force,
  [switch]$Copy
) {
  $myCfgDirName = 'moeshin-test'

  $libDir = getSteamLibDir 730
  if (-not $libDir) {
    throw 'Not found Steam Library'
  }
  $cfgDir = Join-Path $libDir "steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg"
  Write-Debug "cfgDir: $cfgDir"
  if (-not (Test-Path $cfgDir -PathType Container)) {
    throw "No exist cfg dir: $cfgDir"
  }

  $myCfgDir = Join-Path $cfgDir $myCfgDirName
  Write-Debug "myCfgDir: $myCfgDir"
  if (Test-Path $myCfgDir) {
    $filnalPath = getFinalPath $myCfgDir
    if ($filnalPath -eq (Get-Location)) {
      Write-Host "myCfgDir has been installed: $myCfgDir"
      return
    }
    if (-not $Force) {
      Write-Host "Exist myCfgDir: $myCfgDir"
      $in = Read-Host "Delete it? [y/N]"
      $in = $in.Trim().ToLower()
      if (-not $in -and $in -ne 'y') {
        return
      }
    }
    Remove-Item -Recurse -Force $myCfgDir
  }
  if ($Copy) {
    Copy-Item -Recurse $MyCs2CfgDir $myCfgDir
  } else {
    New-Item -ItemType SymbolicLink -Path $myCfgDir -Target $MyCs2CfgDir
  }
}

$MyCs2CfgDir = Split-Path $MyInvocation.MyCommand.path -Parent

if ($Debug) {
  $DebugPreference = 'Continue'
}

if ($MyInvocation.CommandOrigin -eq 'Runspace') {
  installMyCs2Cfg @PSBoundParameters
}
