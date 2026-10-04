# Backend Test Script (PowerShell)
# Bu dosyayı PowerShell ile çalıştırın: .\test_backend.ps1

# Health Check
Write-Host "=== Health Check ==="
$response = Invoke-WebRequest -Uri "https://officialai-backend.onrender.com/health" -Method GET
Write-Host $response.Content

# Register Test
Write-Host "`n=== Register Test ==="
$body = @{
    email = "test@test.com"
    password = "test123"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-WebRequest -Uri "https://officialai-backend.onrender.com/api/v1/auth/register" -Method POST -Body $body -ContentType "application/json"
    Write-Host $registerResponse.Content
} catch {
    Write-Host "Register Error: $($_.Exception.Message)"
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)"
}
