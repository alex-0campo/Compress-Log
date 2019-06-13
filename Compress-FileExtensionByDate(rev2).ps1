#region Compress-FileExtensionByDate
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SoureFolderPath,
    [Parameter(Mandatory=$true)][string[]]$FileExtension,
    [Parameter(Mandatory=$true)][datetime]$ReportEndDate
)

Clear-Host
$searchPath = "L:\Logs\ForwardedEvents"
$fileExtensions = @("evtx") # wildcard not allowed
$start = Get-Date '1/7/2019'


$invalidDateMessage = @"
You entered an invalid date; 
example: 1/1/2019
"@

if ( !($SearchEndDate = Get-NextFriday $ReportEndDate) )
{
    Write-Host $invalidDateMessage -ForegroundColor Red 
    Break
}

$yyyy = $SearchEndDate.Year
$mm = "{0:00}" -f $SearchEndDate.Month
$dd = "{0:00}" -f $SearchEndDate.Day
    
$Include = @()

for ( $i=0; $i-le($FileExtension.Length)-1;$i++ )
{
    $Include += "*.$($FileExtension[$i])"
}

$FilesToCompress = Get-ChildItem -Path $("$SoureFolderPath") `
    -Include $Include -Exclude "ForwardedEvents.evtx" -Recurse | `
    Where-Object { 
        $_.LastWriteTime -le $SearchEndDate
    } | sort LastWriteTime # | Select LastWriteTime, FullName

if ( $FilesToCompress )
{
        
    $strFileExtension = $FileExtension -join "-"

    # create temporary folder
    $TempFolderName = "$($strFileExtension.ToUpper()) files older than $yyyy-$mm-$dd"
    Write-Host "Compressing $TempFolderName" -ForegroundColor Yellow

    $FilesToCompress
    "`r`n"

    if ( !$(Test-Path -Path $("$SoureFolderPath\$TempFolderName")) )
    { 
        # New-Item -Path $SoureFolderPath -Name $TempFolderName -ItemType Directory -Force -WhatIf #| Out-Null 
    }
    else
    {
        Write-Host 'Cannot create folder; ("$SoureFolderPath\$TempFolderName") exists.' -ForegroundColor Red
    }

    # move files to temporary folder
    foreach ( $file in $FilesToCompress )
    {
        # Move-Item -Path $file.FullName -Destination $("$SoureFolderPath\$TempFolderName") -Force -WhatIf
    }

    # compress temporary folder
    $CompressedFileName = "$SoureFolderPath\$TempFolderName.zip"
    # Compress-Archive -Path $("$SoureFolderPath\$TempFolderName") -DestinationPath $CompressedFileName -Force -WhatIf

    # remove temporary folder
    # Remove-Item -Path $("$SoureFolderPath\$TempFolderName") -Recurse -Force -WhatIf
    
}
else
{
    Write-Host "No files|fileExtentions that matched the search criteria..." -ForegroundColor Red
} 
#endregion

