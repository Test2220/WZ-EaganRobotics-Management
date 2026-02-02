{
    $clientIp = $WebEvent.Request.RemoteEndPoint.Address.IPAddressToString
    Write-PodeTextResponse $clientIp
}