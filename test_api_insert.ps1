$url = "http://localhost:8000/api/v1/atendimentos"
$body = @{
    numero     = "5511999999999"
    nome       = "Teste API Local"
    idAtende   = 1
    nomeAtende = "Admin"
    situacao   = "P"
    canal      = 1
    setor      = 1
} | ConvertTo-Json

Write-Host "Sending POST request to $url..."
try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    Write-Host "Success!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
    }
}
