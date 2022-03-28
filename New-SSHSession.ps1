class SSHSession {
    static $VT100RegEx = "\u001B\[(1M|2K|2J|6n|\?(25h|6l|7h)|[0-9]*;[0-9]*[Hr])"
    static $VT100NewLn = "\u001B\[1L"
    static $Sessions = [System.Collections.Generic.List[SSHSession]]::new()
    [int]$ID
    [string]$Hostname
    [string]$User
    [object]$Client
    [object]$ShellStream
    SSHSession($Client) {
        $this.Client = $Client
        $this.ID = [SSHSession]::Sessions.Count + 1
    }
}

function Global:Import-SSHModule() {
    $modPath = "C:\Windows\Temp\SSH.NET\lib\net40\Renci.SshNet.dll"
    if ((Test-Path -Path $modPath) -eq $false) {
        Write-Host "Installing SSH.NET..."
        Invoke-WebRequest -UseBasicParsing -Uri "https://www.nuget.org/api/v2/package/SSH.NET" -OutFile "C:\Windows\Temp\SSH.NET.zip"
        Expand-Archive -Path "C:\Windows\Temp\SSH.NET.zip" -DestinationPath "C:\Windows\Temp\SSH.NET\"
    }
    $dll = $modPath
    Import-Module $dll
}

function Global:Get-SSHSession([int]$ID = 0) {
    if ($ID -ne 0) {
        return [SSHSession]::Sessions | Where-Object -Property ID -EQ -Value $ID
    }
    return [SSHSession]::Sessions
}

function Global:New-SSHSession(
    [Parameter(Mandatory)][string]$Hostname,
    [Parameter(Mandatory)][PSCredential]$Credential,
    [int]$Port = 22
) {
    Import-SSHModule
    $Session = [SSHSession]::new([Renci.SshNet.SshClient]::new($Hostname, $Port, $Credential.UserName, $Credential.GetNetworkCredential().Password))
    [SSHSession]::Sessions.Add($Session)
    return $Session
}

function Global:Start-SSHSession(
    [Parameter(Mandatory, ValueFromPipeline)][SSHSession]$Session
) {
    $Client = ([Renci.SshNet.SshClient]$Session.Client)
    Write-Host -ForegroundColor Yellow "Connecting to: $($Client.ConnectionInfo.Host)..."
    $Client.Connect()
    $Session.ShellStream = $Client.CreateShellStream("MAIN", 100, 100, 1024, 1024, 1024)
    return $Session
}

function Global:Stop-SSHSession(
    [Parameter(Mandatory, ValueFromPipeline)][SSHSession]$Session
) {
    $Client = ([Renci.SshNet.SshClient]$Session.Client)
    Write-Host -ForegroundColor Yellow "Disconnecting from: $($Client.ConnectionInfo.Host)..."
    $Client.Disconnect()
    return $Session
}

function Global:Send-SSHCommand(
    [Parameter(Mandatory, ValueFromPipeline)][SSHSession]$Session,
    [Parameter(Mandatory)][string[]]$Commands,
    [Regex]$Expect = [Regex]::new("# "),
    [TimeSpan]$Timeout = [TimeSpan]::new(0, 0, 30)
) {
    $Client = ([Renci.SshNet.SshClient]$Session.Client)
    $Stream = ([Renci.SshNet.ShellStream]$Session.ShellStream)
    $Guid = New-Guid
    foreach($cmd in $Commands) {
        Write-Host -ForegroundColor Green "Sending: $cmd"
        $Stream.WriteLine($cmd)
    }
    Write-Host -ForegroundColor Red "Waiting for: $Expect"
    $rawOut = $Stream.Expect($Expect, $Timeout)
    $clnOut = $rawOut -replace [SSHSession]::VT100RegEx, ""
    $clnOut = $clnOut -replace [SSHSession]::VT100NewLn, "`r`n"
    return $clnOut
}
