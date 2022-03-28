**New-SSHSession** is a PS module that makes it easier to connect to
devices via SSH and send / receive commands and data.

## Commands

### Import-SSHModule

#### Syntax

`Import-SSHModule`

#### Remarks

Downloads and imports SSH.NET library from MS Nuget.

### Get-SSHSession

#### Syntax

`Get-SSHSession [[-ID] `<int>`]`

#### Remarks

Lists all SSH sessions created. Also pulls a `SSHSession` by ID.

### New-SSHSession

#### Syntax

`New-SSHSession [-Hostname] `<string>` [-Credential] `<pscredential>` [[-Port] `<int>`]`

#### Remarks

Creates a new `SSHSession` object with the specified parameters.

### Start-SSHSession

#### Syntax

`Start-SSHSession [-Session] `<SSHSession>

#### Remarks

Connects the session to the target host and prepares the session to
accept commands.

### Stop-SSHSession

#### Syntax

`Start-SSHSession [-Session] `<SSHSession>

#### Remarks

Disconnects the session from the target host. (The connection can be
restarted without creating a new `SSHSession` object)

### Send-SSHCommand

#### Syntax

`Send-SSHCommand [-Session] `<SSHSession>` [-Commands] <string[]> [[-Expect] `<regex>`] [[-Timeout] `<timespan>`] [-RawOutput]`

#### Remarks

This command sends a list of commands to the target host and waits for
and outputs a response.

By default this command will wait for a response containing a hashtag.
`#` Once a hashtag is received from the SSH target, the command will
return all the text before the hashtag was received.

It is possible to specify a regular expression that the command should
wait for instead of a hashtag. `-Expect `<regex>

By default this command will wait for a response, but after 30 seconds
will return anyway (with no data).

It is possible to specify a new timeout. `-Timeout `<timespan>

By default this command will return a filtered output from the SSH
target. This data usually includes VT100 escape codes, so this command
will strip these by default.

It is possible to bypass this and return the raw data including VT100
escape codes. `-RawOutput`  
  
## Examples

### Pull a switch running config:

``` powershell
#Import the PSWiki command-lets.
Enter-PSWiki

#Create a new SSHSession and then connect.
$session = New-SSHSession | Start-SSHSession

#Send a command to the SSHSession. First send 0 to clear the MOTD, then send "no page" to disable pagation for this session.
$session | Send-SSHCommand -Commands "0", "no page" -Expect "no page"

#Send "show run", and then send a percent symbol.
#Expect parameter is set to the percent symbol since the switch will respond with "Invalid command %".
#This behavior can be used to our advantage to indicate the switch has completed sending the running config.
$session | Send-SSHCommand -Commands "show run", "%" -Expect "%"

#Disconnect the session.
$_ = $session | Stop-SSHSession
```

### Pull an HP switch firmware version:

``` powershell
#Import the PSWiki command-lets.
Enter-PSWiki

#Create a new SSHSession and then connect.
$session = New-SSHSession | Start-SSHSession

#Send a 0 to dismiss the MOTD.
$_ = $session | Send-SSHCommand -Commands "0"

#Send the "show version" command and then a percent symbol.
#Expect a percent symbol so that we know the "show version" command has completed.
$rawVersion = $session | Send-SSHCommand -Commands "show version", "%" -Expect "%"

#Use regular expressions to grab the switch version number from the output.
$version = ($rawVersion | Select-String -Pattern "\w\w\w\s\d\d\s\d{4}\s\d\d:\d\d:\d\d\s*(.*)").Matches.Groups[1].Value

#Disconnect from the session.
$_ = $session | Stop-SSHSession

Write-Host "The switch firmware version is: $version"
```
