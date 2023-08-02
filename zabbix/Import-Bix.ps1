$Global:bixHost = "hostgoeshere.com"
$Global:bixApi = "api_jsonrpc.php"
$Global:bixToken = "keygoeshere"

function Global:Invoke-BixRequest($Method, $Params = @{}) {
    $body = ConvertTo-Json -Depth 100 -InputObject @{
        jsonrpc = "2.0"
        method = $Method
        id = 0
        auth = $Global:bixToken
        params = $Params
    }
    $response = Invoke-WebRequest -UseBasicParsing -Uri "https://$($Global:bixHost)/$($Global:bixApi)" -ContentType "application/json-rpc" -Method Post -Body $body
    return (ConvertFrom-Json -InputObject $response.Content).result
}