<#PSWiki#>
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
    [int]$Timeout = 100
) {
    begin { Import-SNMPModule }
    process {
        try {
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
        } catch {
            Write-Verbose "Failed to connect / receive SNMP object: $Hostname."
        }
    }
}

function Global:Get-SnmpTable(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$Hostname,
    [int]$Port = 161,
    [string]$Community = "public",
    [string]$OID = ".1.3.6.1.2.1.1.1.0",
    [string]$Version = "V2",
    [int]$Timeout = 100,
    [int]$MaxRepetitions = [int]::MaxValue
) {
    begin { Import-SNMPModule }
    process {
        try {
            $snmpVer = [System.Enum]::Parse([Lextm.SharpSnmpLib.VersionCode], $Version)
            $ipEndpoint = ConvertTo-IPEndPoint -Hostname $Hostname -Port $Port
            $octetCommunity = [Lextm.SharpSnmpLib.OctetString]::new($Community)
            $oOID = [Lextm.SharpSnmpLib.ObjectIdentifier]::new($OID)
            [Lextm.SharpSnmpLib.Messaging.Messenger]::GetTable(
                $snmpVer,
                $ipEndpoint,
                $octetCommunity,
                $oOID,
                $Timeout,
                $MaxRepetitions
            )
        } catch {
            Write-Verbose "Failed to connect / receive SNMP object: $Hostname."
        }
    }
}

function Global:Walk-SnmpObject(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$Hostname,
    [int]$Port = 161,
    [string]$Community = "public",
    [string]$OID = ".1.3.6.1.2.1.1.1.0",
    [string]$Version = "V2",
    [int]$Timeout = 100,
    [string]$Mode = "WithinSubtree"
) {
    begin { Import-SNMPModule }
    process {
        try {
            $snmpVer = [System.Enum]::Parse([Lextm.SharpSnmpLib.VersionCode], $Version)
            $walkMode = [System.Enum]::Parse([Lextm.SharpSnmpLib.Messaging.WalkMode], $Mode)
            $ipEndpoint = ConvertTo-IPEndPoint -Hostname $Hostname -Port $Port
            $octetCommunity = [Lextm.SharpSnmpLib.OctetString]::new($Community)
            $oOID = [Lextm.SharpSnmpLib.ObjectIdentifier]::new($OID)
            $oList = [System.Collections.Generic.List[Lextm.SharpSnmpLib.Variable]]::new()
            [Lextm.SharpSnmpLib.Messaging.Messenger]::Walk(
                $snmpVer,
                $ipEndpoint,
                $octetCommunity,
                $oOID,
                $oList,
                $Timeout,
                $walkMode
            )
            $oList
        } catch {
            Write-Verbose "Failed to connect / receive SNMP object: $Hostname."
        }
    }
}
<#/PSWiki#>
