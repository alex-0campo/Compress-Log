[CmdletBinding()]
param()

#region Get-LastSunday
function Get-LastSunday
{
    [CmdletBinding()]
    param($CurrentDate)

    @(1..7) | ForEach-Object {
        $(Get-Date $CurrentDate).AddDays($_)
    } | Where-Object {$_.DayOfWeek -ieq "Sunday"}

}
#endregion

#region Get-TopLevelFolder
function Get-TopLevelFolder
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string] $path)

    Get-ChildItem -Path $path -Directory
}
#endregion

#region Get-FilesToCompress
function Get-FilesToCompress
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string] $path)

}
#endregion

#region execution starts here
[bool]$loop = $true

while ($loop) {
    $rptDate = Get-LastSunday -CurrentDate $((Get-Date).AddDays(-30))
    $rptDate

    $folders = Get-TopLevelFolder -path "L:\Logs" | Select FullName

    foreach ($folder in $folders)
    {

    }
}
#endregion