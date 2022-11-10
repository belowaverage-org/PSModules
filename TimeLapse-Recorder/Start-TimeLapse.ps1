$global:VIDS_FOLDER  = ".\vids"
$global:VIDS_OUTPUT  = ".mp4"
$global:VIDS_IN_FPS  = 9000
$global:VIDS_OUT_FPS = 30
$global:VIDS_SOURCE  = "rtsp://10.1.1.1:554/cam/realmonitor?channel=1&subtype=0&unicast=true&proto=Onvif"
$global:FAIL_TIMEOUT = 10
$global:LEDGER_FILE  = ".\ledger.txt"


function Get-NextName {
    $largest_num = 0
    $items = Get-ChildItem -Path $global:VIDS_FOLDER -Filter "*.mp4"
    foreach ($item in $items) {
        $num = 0
        if (-not [int]::TryParse($item.Name.Replace($global:VIDS_OUTPUT, ""), [ref] $num)) { continue }
        if ($num -gt $largest_num) { $largest_num = $num }
    }
    return "$($largest_num + 1)$global:VIDS_OUTPUT"
}

function Start-Record {
    Out-File -FilePath $global:LEDGER_FILE -Encoding utf8 -Append -Force -NoClobber -InputObject "$((Get-Date).ToString()): $(Get-NextName)"
    Start-Process -FilePath ".\bin\ffmpeg.exe" -Wait -ArgumentList `
    "-r", $global:VIDS_IN_FPS,
    "-i", $global:VIDS_SOURCE,
    "-r", $global:VIDS_OUT_FPS,
    "$global:VIDS_FOLDER\$(Get-NextName)"
}

function Start-Loop {
    while ($true) {
        Write-Output "Recording started..."
        Start-Record
        Write-Output "Recording stopped, starting after $($global:FAIL_TIMEOUT)s timeout..."
        Start-Sleep -Seconds $global:FAIL_TIMEOUT
    }
}

Start-Loop
