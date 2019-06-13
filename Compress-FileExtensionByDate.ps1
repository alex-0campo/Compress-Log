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
    if ( !($endDate = Get-NextSunday $endDate) )
    {
        Write-Host $invalidDateMessage -ForegroundColor Red 
        Break
    }
    
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
            $_.LastWriteTime -ge $($endDate.AddDays(-7)) -and `
            $_.LastWriteTime -le $endDate
        } | sort LastWriteTime # | Select LastWriteTime, FullName
 

    if ( $FilesToCompress )
    {
        $timer = New-Object System.Diagnostics.Stopwatch
        $timer.Start()

        $strFileExtension = $FileExtension -join "-"

        $yyyy = $endDate.Year
        $mm = "{0:00}" -f $endDate.Month
        $dd = "{0:00}" -f $endDate.Day

        # create temporary folder
        $TempFolderName = "$($strFileExtension.ToUpper()) files older than $yyyy-$mm-$dd"
        Write-Host "Compressing $TempFolderName" -ForegroundColor Yellow

        # $FilesToCompress | ft LastWriteTime,Name -auto
        # "`r`n"

        $tempFolderDestination = $("$SoureFolderPath\ZippedLogs")
        $TempFolderNamePath = $("$tempFolderDestination\$TempFolderName")

        if ( !$(Test-Path -Path $TempFolderNamePath) )
        { 
            New-Item -Path $tempFolderDestination -Name $TempFolderName -ItemType Directory -Force | Out-Null 
        }
        else
        {
            Write-Host "Cannot create folder; $TempFolderNamePath exists." -ForegroundColor Red
            Exit
        }

        # move files to temporary folder
        foreach ( $file in $FilesToCompress )
        {
            Move-Item -Path $file.FullName -Destination $("$tempFolderDestination\$TempFolderName") -Force #-WhatIf
        }

        # compress temporary folder
        $CompressedFileName = "$tempFolderDestination\$TempFolderName.zip"
        Compress-Archive -Path $TempFolderNamePath -DestinationPath $CompressedFileName -Force #-WhatIf

        # remove temporary folder
        Remove-Item -Path $("$tempFolderDestination\$TempFolderName") -Recurse -Force #-WhatIf

        $timer.Stop()
        "Duration (minutes): {0:N3}" -f $(($timer.ElapsedMilliseconds)/60000).ToString() 
    
    }
    else
    {
        Write-Host "No files|fileExtentions that matched the search criteria..." -ForegroundColor Red
    } 

} # end function Compress-FileExtensionByDate
#endregion

#region execution starts here #

Clear-Host

Push-Location
Set-Location -Path "L:\Logs\ForwardedEvents\"

$searchPath = "L:\Logs\ForwardedEvents"
$fileExtensions = @("evtx") # wildcard not allowed


# hardcode during testing only
$start = '2/11/2019'
$sunDate = Get-NextSunday -CurrentDate $start

$invalidDateMessage = @"
You entered an invalid date; 
example: 1/20/2019
"@

do {
    # $sunDate = Get-NextSunday -CurrentDate $start
    $sunDate
    
    Compress-FileExtensionByDate -SoureFolderPath $searchPath `
        -FileExtension $fileExtensions -endDate $sunDate
    <#
    ### exclude last 2-Fridays ###
    if ($sunDate -le $((Get-Date).AddDays(-7)) )
    {
        $start = $sunDate
    } #>

    $sunDate = $(($sunDate).AddDays(7)) # $(($sunDate).AddDays(8))
}
While( $sunDate -lt $((Get-Date).AddDays(-30)) ) # loop each Friday's except Fridays in the last 30 days
#endregion

Pop-Location
