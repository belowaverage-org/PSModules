function Global:Import-SNMPModule() {
    $modPath = "C:\Windows\Temp\Lextm.SharpSnmpLib\lib\net471\SharpSnmpLib.dll"
    if ((Test-Path -Path $modPath) -eq $false) {
        Write-Host "Installing Lextm.SharpSnmpLib..."
        Invoke-WebRequest -UseBasicParsing -Uri "https://www.nuget.org/api/v2/package/Lextm.SharpSnmpLib" -OutFile "C:\Windows\Temp\Lextm.SharpSnmpLib.zip"
        Expand-Archive -Path "C:\Windows\Temp\Lextm.SharpSnmpLib.zip" -DestinationPath "C:\Windows\Temp\Lextm.SharpSnmpLib\"
    }
    $dll = $modPath
    Import-Module $dll
}

function Global:ConvertTo-IPEndPoint([string]$Hostname, [int]$Port) {
    try {
        $IP = $null
        if (-not [System.Net.IPAddress]::TryParse($Hostname, [ref] $IP)) {
            $IP = [System.Net.IPAddress]::Parse((Resolve-DnsName -ErrorAction SilentlyContinue -Name $Hostname).IPAddress)
        }
        return [System.Net.IPEndpoint]::new($IP, $Port)
    } catch {
        throw [System.Exception]::new("Could not convert. Hostname not resolved?")
        return $null
    }
}

function Global:Get-SnmpObject(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$Hostname,
    [int]$Port = 161,
    [string]$Community = "public",
    [string[]]$OIDs = ".1.3.6.1.2.1.1.1.0",
    [string]$Version = "V2",
    [int]$Timeout = 1000
) {
    Import-SNMPModule
    process {
        $snmpVer = [System.Enum]::Parse([Lextm.SharpSnmpLib.VersionCode], $Version)
        $ipEndpoint = ConvertTo-IPEndPoint -Hostname $Hostname -Port $Port
        $octetCommunity = [Lextm.SharpSnmpLib.OctetString]::new($Community)
        $vars = [System.Collections.Generic.List[Lextm.SharpSnmpLib.Variable]]::new()
        foreach ($oid in $OIDs) {
            $parsedOID = [Lextm.SharpSnmpLib.Variable]::new([Lextm.SharpSnmpLib.ObjectIdentifier]::new($oid))
            $vars.Add($parsedOID)
        }
        [Lextm.SharpSnmpLib.Messaging.Messenger]::Get(
            $snmpVer,
            $ipEndpoint,
            $octetCommunity,
            $vars,
            $Timeout
        )
    }
}
