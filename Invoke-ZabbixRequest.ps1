function Invoke-ZabbixRequest($Method, $Params = @{}) {
    $response = Invoke-WebRequest -UseBasicParsing -Uri "https://$($Global:bixHost)/$($Global:bixApi)" -ContentType "application/json-rpc" -Method Post -Body (ConvertTo-Json -InputObject @{
        jsonrpc = "2.0"
        method = $Method
        id = 0
        auth = $Global:bixToken
        params = $Params
    })
    return (ConvertFrom-Json -InputObject $response.Content).result
}
