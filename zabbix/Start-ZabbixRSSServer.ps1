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
    $response = ""

    $response += "<?xml version=`"1.0`" encoding=`"UTF-8`" ?>"
    $response += "<rss version=`"2.0`">"
    $response += "<channel>"
    $response += "    <title>Zabbix Events</title>"
    $response += "    <link>https://zabbix.com</link>"
    $response += "    <description>Ouchie boo boo's</description>"
    $response += "    <ttl>1</ttl>"

    foreach ($event in Get-Events) {
        $response += "    <item>"
        $response += "        <description>$($event.device): $($event.event)</description>"
        $response += "        <pubDate>$($event.time.ToString("r"))</pubDate>"
        $response += "        <guid>$($event.eventid)</guid>"
        $response += "    </item>"
    }

    $response += "</channel>"
    $response += "</rss>"

    $bytes = [System.Text.UTF8Encoding]::Default.GetBytes($response)
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $ctx.Response.Close()
}
