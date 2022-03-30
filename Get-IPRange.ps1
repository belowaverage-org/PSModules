function Global:Get-IPRange(
    [string]$IPRange,
    [string[]]$IPRanges = $null
) {
    if ($null -ne $IPRanges) {
        foreach ($Ranges in $IPRanges) {
            Get-IPRange -IPRange $Ranges
        }
        return
    }
    if (-not ($IPRange -match "(^(?:(?:\d{1,3}-\d{1,3}|\d{1,3})\.){3}(?:\d{1,3}-\d{1,3}|\d{1,3})$)")) { return }
    $ipOctets = $IPRange.Split('.')
    $ipRangeMin = 0
    $ipRangeMax = 0
    $rangeFound = $false
    $octetIndex = 0
    foreach ($ipOctet in $ipOctets) {
        $ipSplit = $ipOctet.Split('-')
        if ($ipSplit.Length -eq 2) {
            $ipRangeMin = [int]$ipSplit[0]
            $ipRangeMax = [int]$ipSplit[1]
            $rangeFound = $true
            break
        }
        $octetIndex++
    }
    if ($rangeFound) {
        for ($index = $ipRangeMin; $index -le $ipRangeMax; $index++) {
            $ipOctets[$octetIndex] = $index
            Get-IPRange -IPRange ([string]::Join('.', $ipOctets))
        }
    } else {
        [string]::Join('.', $ipOctets)
    }
}
