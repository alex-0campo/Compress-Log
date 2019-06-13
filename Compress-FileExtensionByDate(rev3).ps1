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

#region hide1
# Get OldFiles group by week (LastWriteTime Range: Sunday 12:00:00 AM => Saturday 11:59:59.999 PM) 
function Get-OldFileExtensionByDate
{
    [CmdletBinding()]
    param(
        $searchPath='L:\Logs\ForwardedEvents',
        $searchStartDate,
        $searchEndDate
    )

    Get-ChildItem -Path $searchPath -Include "*.evtx" | ? { 
        $_.LastWriteTime -ge $searchStartDate -and $_.LastWriteTime -le $searchEndDate
    }
}

function Compress-OldFileExtension
{

}
#endregion

# Get-NextRunDay -fromDate '1/7/2019'



Clear-Host
# $searchPath = "L:\Logs\ForwardedEvents"
# $fileExtensions = @("evtx") # wildcard not allowed
$start = Get-Date '1/1/2019'


do {
    $hashRange = Get-NextRunDay -fromDate $start
    
    $from = $hashRange.startDate
    $to = $hashRange.endDate

    "Start: {0}" -f $from
    "End: {0}`r`n" -f $to

    $start = $($to).AddTicks(1)
    
    #region hide
    #Compress-FileExtensionByDate -SoureFolderPath $searchPath `
        # -FileExtension $fileExtensions -ReportEndDate $friDate
    
    ### exclude last 2-Fridays ###
    <# if ($friDate -le $((Get-Date).AddDays(-7)) )
    {
        $start = $friDate
    } #>
    #endregion
}
While( $to -le $((Get-Date).AddDays(-30)) ) # loop each Friday's except Fridays in the last 30 days