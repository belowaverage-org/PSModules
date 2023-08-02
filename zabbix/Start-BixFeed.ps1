.\Import-Bix.ps1

function Get-Events {
    $events = Invoke-BixRequest -Method event.get -Params @{
        sortfield = @("clock")
        sortorder = "DESC"
        selectHosts = @("name")
        value = 1
        limit = 100
    }
    $formated_events = foreach ($event in $events) {
        [PSCustomObject]@{
            device = $event.hosts[0].name
            event = $event.name
            time = $([System.DateTimeOffset]::FromUnixTimeSeconds($event.clock))
            eventid = $event.eventid
        }
    }
    return $formated_events
}

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:9437/")
$listener.Start()

while ($true) {
    $ctx = $listener.GetContext()
    $ctx.Response.AddHeader("Content-Type", "text/html")
    $response = ""

    $response += "<!DOCTYPE html>"
    $response += "<head>"
    $response += "    <style>"
    $response += "        body {"
    $response += "            background-color:black;"
    $response += "        }"
    $response += "        table {"
    $response += "            font-size: 26px;"
    $response += "            font-family: monospace;"
    $response += "            color: white;"
    $response += "        }"
    $response += "        tr:nth-child(even) {"
    $response += "            background-color: #28005d;"
    $response += "        }"
    $response += "        .nowrap {"
    $response += "            white-space: nowrap;"
    $response += "        }"
    $response += "    </style>"
    $response += "</head>"
    $response += "<body>"
    $response += "    <table>"

    foreach ($event in Get-Events) {
        $response += "    <tr>"
        $response += "        <td>$($event.device)</td>"
        $response += "        <td>$($event.event)</td>"
        $response += "        <td class=`"nowrap`">$($event.time.ToString("G"))</td>"
        $response += "    </tr>"
    }

    $response += "    </table>"
    $response += "</body>"

    $bytes = [System.Text.UTF8Encoding]::Default.GetBytes($response)
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $ctx.Response.Close()
}