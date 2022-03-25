$Global:SSHSessions = [List[SSHSession]]::new()

class SSHSession {
    [object]$Client
    [object]$ShellStream
    SSHSession($Client) {
        $this.Client = $Client
    }
}

function Global:Import-SSHModule() {
    if ((Get-Package -Name SSH.NET).Count -eq 0) {
        Write-Host "Installing SSH.NET..."
        Install-Package SSH.NET -Scope CurrentUser -Force 
    }
    $package = Get-Package -Name SSH.NET
    $path = $package.Source | Get-Item
    $dll = "$($path.Directory.FullName)\lib\net40\Renci.SshNet.dll"
    Import-Module $dll
}

function Global:New-SSHSession(
    [Parameter(Mandatory)][string]$Hostname,
    [Parameter(Mandatory)][PSCredential]$Credential, 
    [int]$Port = 22
) {
    Import-SSHModule
    $Session = [SSHSession]::new([Renci.SshNet.SshClient]::new($Hostname, $Port, $Credential.UserName, $Credential.GetNetworkCredential().Password))
    $Global:SSHSessions.Add($Session)
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
    return $Stream.Expect($Expect, $Timeout)
}
