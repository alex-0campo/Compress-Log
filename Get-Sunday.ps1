[CmdletBinding()]
param()

#region Get-NextFriday
function Get-NextFriday
{
    [CmdletBinding()]
    param($CurrentDate)

    @(1..7) | ForEach-Object {
        $(Get-Date $CurrentDate).AddDays($_)
    } | Where-Object {$_.DayOfWeek -ieq "Sunday"}

}
#endregion

Clear-Host

$endDate = Get-NextFriday -CurrentDate $($(Get-Date).Date).AddDays(1)#.AddTicks(-1)
$startDate = $endDate.AddDays(-7)

$startDate
$endDate
