function Get-NextRunDay
{
    [CmdletBinding()]
    param($fromDate)

    $startDate = @(1..7) | ForEach-Object {
        $(Get-Date $fromDate).AddDays($_)
    } | Where-Object {$_.DayOfWeek -ieq "Sunday"}

    [hashtable]$return = @{}

    $return.startDate = $startDate
    $return.endDate = $($startDate.AddDays(7)).AddTicks(-1)

    # return the hashtable
    return $return
}

Clear-Host

$fromDate = '1/1/2019'

do{
    if ( $((Get-Date $fromDate).DayOfWeek) -ne 'Sunday' )
    {
        $hash = Get-NextRunDay -fromDate $fromDate
        $hash.startDate

        $fromDate = $($hash.endDate).AddTicks(1)
    }
    else
    {
        $hash = @{ 'startDate'=$fromDate; 'endDate'=$fromDate.AddDays(7).AddTicks(-1)}
    }
} while ( $hash.endDate -lt $((Get-Date).AddDays(-30)) )
