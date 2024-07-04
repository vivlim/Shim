param(
    [ValidateScript({
        if( -Not ($_ | Test-Path) ){
            throw "The provided path doesn't exist."
        }
        if(-Not ($_ | Test-Path -PathType Leaf) ){
            throw "The provided path is not a file."
        }
        if($_ -notmatch "\.exe"){
            throw "The provided file path is not an exe."
        }
        return $true
    })]
    [System.IO.FileInfo]$TargetPath
)

$ErrorActionPreference = "Stop"

$shimDestinationPath = "C:\tools\shims"

$shimExe = "$PSScriptRoot\dist\shim.exe"
if(-Not ($shimExe | Test-Path -PathType Leaf) ){
    throw "The shim exe has not been built, couldn't find it at $shimExe"
}

$name = [System.IO.Path]::GetFileNameWithoutExtension($TargetPath.FullName)
$newPathBase = "$shimDestinationPath\$name"
$newShimPath = "$newPathBase.shim"
$newExePath = "$newPathBase.exe"

if ($newExePath | Test-Path){
    Write-Host -ForegroundColor Yellow "Existing shim exe at $newExePath, it will be overwritten."
    rm $newExePath
}

if ($newShimPath | Test-Path){
    Write-Host -ForegroundColor Yellow "Existing shim defined at $newShimPath, it will be overwritten. It contained:"
    cat $newShimPath
    rm $newShimPath
}

Write-Host -ForegroundColor Green "Creating shim '$name' targeting $($TargetPath.FullName)"
New-Item -ItemType Directory -Force -Path $shimDestinationPath > $null

New-Item -Path $newShimPath -Value "path = $($TargetPath.FullName)" > $null

Copy-Item -Path $shimExe -Destination $newExePath

Write-Host -ForegroundColor Green "Shim created at $newExePath"
