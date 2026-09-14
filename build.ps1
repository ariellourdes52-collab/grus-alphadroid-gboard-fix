param(
    [Parameter(Mandatory = $true)]
    [string]$ApkPath,

    [string]$OutputName = "Grus-AlphaDroid-Gboard-Fix-v1.0-KernelSU.zip"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleDir = Join-Path $RepoRoot "module"
$ModuleProp = Join-Path $ModuleDir "module.prop"
$Customize = Join-Path $ModuleDir "customize.sh"
$OutputDir = Join-Path $RepoRoot "out"
$StageDir = Join-Path $RepoRoot ".build"
$ApkDestDir = Join-Path $StageDir "system\product\app\LatinIMEGooglePrebuilt"
$ApkDest = Join-Path $ApkDestDir "LatinIMEGooglePrebuilt.apk"
$OutputZip = Join-Path $OutputDir $OutputName

if (-not (Test-Path -LiteralPath $ModuleProp)) {
    throw "Missing module/module.prop"
}

if (-not (Test-Path -LiteralPath $Customize)) {
    throw "Missing module/customize.sh"
}

$ResolvedApk = (Resolve-Path -LiteralPath $ApkPath).Path
if ([System.IO.Path]::GetExtension($ResolvedApk).ToLowerInvariant() -ne ".apk") {
    throw "ApkPath must point to an .apk file."
}

Write-Host "Using APK: $ResolvedApk"
Write-Host "APK size: $((Get-Item -LiteralPath $ResolvedApk).Length) bytes"

if (Test-Path -LiteralPath $StageDir) {
    Remove-Item -LiteralPath $StageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $ApkDestDir -Force | Out-Null
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

Copy-Item -LiteralPath $ModuleProp -Destination (Join-Path $StageDir "module.prop")
Copy-Item -LiteralPath $Customize -Destination (Join-Path $StageDir "customize.sh")
Copy-Item -LiteralPath $ResolvedApk -Destination $ApkDest

if (Test-Path -LiteralPath $OutputZip) {
    Remove-Item -LiteralPath $OutputZip -Force
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$fileStream = [System.IO.File]::Open($OutputZip, [System.IO.FileMode]::CreateNew)
try {
    $zip = New-Object System.IO.Compression.ZipArchive(
        $fileStream,
        [System.IO.Compression.ZipArchiveMode]::Create,
        $false
    )

    try {
        Get-ChildItem -LiteralPath $StageDir -File -Recurse | ForEach-Object {
            $relative = $_.FullName.Substring($StageDir.Length).TrimStart('\', '/')
            $entryName = $relative.Replace('\', '/')

            $entry = $zip.CreateEntry(
                $entryName,
                [System.IO.Compression.CompressionLevel]::Optimal
            )

            $source = [System.IO.File]::OpenRead($_.FullName)
            try {
                $target = $entry.Open()
                try {
                    $source.CopyTo($target)
                }
                finally {
                    $target.Dispose()
                }
            }
            finally {
                $source.Dispose()
            }
        }
    }
    finally {
        $zip.Dispose()
    }
}
finally {
    $fileStream.Dispose()
}

# Validate ZIP entry paths. KernelSU/meta-overlayfs expects normal Unix-style paths.
$checkStream = [System.IO.File]::OpenRead($OutputZip)
try {
    $checkZip = New-Object System.IO.Compression.ZipArchive(
        $checkStream,
        [System.IO.Compression.ZipArchiveMode]::Read,
        $false
    )
    try {
        $entries = @($checkZip.Entries | ForEach-Object { $_.FullName })

        if ($entries | Where-Object { $_ -match '\\' }) {
            throw "Invalid ZIP: one or more entries contain backslashes."
        }

        $required = @(
            "module.prop",
            "customize.sh",
            "system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk"
        )

        foreach ($item in $required) {
            if ($entries -notcontains $item) {
                throw "Invalid ZIP: missing required entry $item"
            }
        }

        Write-Host ""
        Write-Host "ZIP contents:"
        $entries | ForEach-Object { Write-Host "  $_" }
    }
    finally {
        $checkZip.Dispose()
    }
}
finally {
    $checkStream.Dispose()
}

Remove-Item -LiteralPath $StageDir -Recurse -Force

Write-Host ""
Write-Host "Build complete:"
Write-Host $OutputZip
Write-Host ""
Write-Host "Install this ZIP from KernelSU > Modules > Install from storage, then reboot."
