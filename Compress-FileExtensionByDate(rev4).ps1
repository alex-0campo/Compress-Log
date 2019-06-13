[CmdletBinding()]
param()

#region Get-NextFriday
function Get-NextSunday
{
    [CmdletBinding()]
    param($CurrentDate)

    @(1..7) | ForEach-Object {
        $(Get-Date $CurrentDate).AddDays($_)
    } | Where-Object {$_.DayOfWeek -ieq "Sunday"}

}
#endregion

#region Compress-FileExtensionByDate
function Compress-FileExtensionByDate
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$SoureFolderPath,
        [Parameter(Mandatory=$true)][string[]]$FileExtension,
        [Parameter(Mandatory=$true)][datetime]$endDate
    )

<# $invalidDateMessage = @"
You entered an invalid date; 
example: 1/1/2019
"@ #>
    # validate report end date
    if ( !($SearchEndDate = Get-NextSunday $endDate) )
    {
        Write-Host $invalidDateMessage -ForegroundColor Red 
        Break
    }

    $yyyy = $SearchEndDate.Year
    $mm = "{0:00}" -f $SearchEndDate.Month
    $dd = "{0:00}" -f $SearchEndDate.Day
    
    # supports multiple file extensions
    $Include = @()

    for ( $i=0; $i-le($FileExtension.Length)-1;$i++ )
    {
        $Include += "*.$($FileExtension[$i])"
    }

    $FilesToCompress = Get-ChildItem -Path $("$SoureFolderPath") `
        -Include $Include -Recurse | `
        Where-Object {
            $_.Name -match "Archive-ForwardedEvents*" -and ` 
            $_.LastWriteTime -ge $($SearchEndDate.AddDays(-7)) -and `
            $_.LastWriteTime -le $SearchEndDate
        } | sort LastWriteTime # | Select LastWriteTime, FullName
 

    if ( $FilesToCompress )
    {
        $timer = New-Object System.Diagnostics.Stopwatch
        $timer.Start()

        $strFileExtension = $FileExtension -join "-"

        # create temporary folder
        $TempFolderName = "$($strFileExtension.ToUpper()) files older than $yyyy-$mm-$dd"
        Write-Host "Compressing $TempFolderName" -ForegroundColor Yellow

        # $FilesToCompress | ft LastWriteTime,Name -auto
        # "`r`n"

        if ( !$(Test-Path -Path $("$SoureFolderPath\$TempFolderName")) )
        { 
            New-Item -Path $SoureFolderPath -Name $TempFolderName -ItemType Directory -Force | Out-Null 
        }
        else
        {
            Write-Host 'Cannot create folder; ("$SoureFolderPath\$TempFolderName") exists.' -ForegroundColor Red
        }

        # move files to temporary folder
        foreach ( $file in $FilesToCompress )
        {
            Move-Item -Path $file.FullName -Destination $("$SoureFolderPath\$TempFolderName") -Force -WhatIf
        }

        # compress temporary folder
        $CompressedFileName = "$SoureFolderPath\$TempFolderName.zip"
        Compress-Archive -Path $("$SoureFolderPath\$TempFolderName") -DestinationPath $CompressedFileName -Force -WhatIf

        # remove temporary folder
        Remove-Item -Path $("$SoureFolderPath\$TempFolderName") -Recurse -Force

        $timer.Stop()
        "Duration (sec): {0}" -f $(($timer.ElapsedMilliseconds)/1000).ToString() 
    
    }
    else
    {
        Write-Host "No files|fileExtentions that matched the search criteria..." -ForegroundColor Red
    } 

} # end function Compress-FileExtensionByDate
#endregion

#region execution starts here #

Clear-Host
$searchPath = "L:\Logs\ForwardedEvents"
$fileExtensions = @("evtx") # wildcard not allowed

# hardcode during testing only
$start = Get-Date '1/20/2019'

$invalidDateMessage = @"
You entered an invalid date; 
example: 1/20/2019
"@


do {
    $sunDate = Get-NextSunday -CurrentDate $start
    # $sunDate
    
    Compress-FileExtensionByDate -SoureFolderPath $searchPath `
        -FileExtension $fileExtensions -endDate $sunDate
    <#
    ### exclude last 2-Fridays ###
    if ($sunDate -le $((Get-Date).AddDays(-7)) )
    {
        $start = $sunDate
    } #>

    $start = $sunDate
}
While( $sunDate -lt $((Get-Date '1/12/2019')) ) # loop each Friday's except Fridays in the last 30 days
#endregion

<# delete and restore test files and folders

    Remove-Item -Path C:\Temp\Scripts -Recurse -Force
    Expand-Archive -Path C:\Temp\Scripts.zip -DestinationPath C:\Temp -Force

#>
