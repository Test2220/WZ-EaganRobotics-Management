{
   
$newip = $WebEvent.Request.RemoteEndPoint.Address.IPAddressToString
if (Test-Path -Path ./data/StacklightList.txt) {
       $Stacklightlist =  Get-Content ./data/StacklightList.txt
    }else {
       $Stacklightlist | Out-File -FilePath ./data/StacklightList.Csv
    }


    foreach ($item in $Stacklightlist){
        if ($item -match $newip){
            $input -eq $true
            break
        }
    }
    if($input -eq $true){
        Write-PodeTextResponse "IP already added"
    }else {
        Add-Content -path ./data/Stacklightlist.txt -Value $newip
        Write-PodeTextResponse "OK"
    }
}