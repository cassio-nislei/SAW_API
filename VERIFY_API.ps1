#!/usr/bin/env pwsh
# SAW API - Verification Checklist
# Script para verificar se todos os componentes estão funcionando

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        SAW API - PRODUCTION VERIFICATION CHECKLIST             ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://104.234.173.105:7080"
$apiUrl = "$baseUrl/api/v1"
$checks = @()

# Function to check endpoint
function Check-Endpoint {
    param(
        [string]$name,
        [string]$url,
        [string]$expectedStatus = "200"
    )
    
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        
        if ($response.StatusCode -eq [int]$expectedStatus) {
            Write-Host "✅ $name" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️  $name - Status: $($response.StatusCode)" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "❌ $name - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 1. API Infrastructure
Write-Host "1️⃣  API Infrastructure" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

$checks += (Check-Endpoint "Health Check" "$apiUrl/")
$checks += (Check-Endpoint "Swagger UI HTML" "$baseUrl/api/swagger-ui.html")
$checks += (Check-Endpoint "Swagger JSON (PHP)" "$baseUrl/api/swagger-json.php")
$checks += (Check-Endpoint "Postman Collection File" "c:\Users\nislei\Downloads\SAW-main\SAW-main\api\SAW_API_Postman.json")

Write-Host ""

# 2. Main Endpoints
Write-Host "2️⃣  Main Endpoints" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

$checks += (Check-Endpoint "GET /atendimentos" "$apiUrl/atendimentos")
$checks += (Check-Endpoint "GET /menus" "$apiUrl/menus")
$checks += (Check-Endpoint "GET /parametros" "$apiUrl/parametros")
$checks += (Check-Endpoint "GET /horarios" "$apiUrl/horarios")

Write-Host ""

# 3. CORS Headers
Write-Host "3️⃣  CORS Configuration" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri "$apiUrl/menus" -UseBasicParsing
    $corsOrigin = $response.Headers['Access-Control-Allow-Origin']
    $corsMethods = $response.Headers['Access-Control-Allow-Methods']
    
    if ($corsOrigin -eq "*") {
        Write-Host "✅ CORS Allow-Origin: $corsOrigin" -ForegroundColor Green
        $checks += $true
    } else {
        Write-Host "⚠️  CORS Allow-Origin: $corsOrigin" -ForegroundColor Yellow
        $checks += $false
    }
    
    if ($corsMethods) {
        Write-Host "✅ CORS Methods configured" -ForegroundColor Green
        $checks += $true
    } else {
        Write-Host "❌ CORS Methods not configured" -ForegroundColor Red
        $checks += $false
    }
} catch {
    Write-Host "❌ Cannot check CORS headers" -ForegroundColor Red
    $checks += $false
}

Write-Host ""

# 4. Database Connection
Write-Host "4️⃣  Database Connection" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri "$apiUrl/atendimentos" -UseBasicParsing
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success -eq $true) {
        Write-Host "✅ Database query successful" -ForegroundColor Green
        $checks += $true
    } else {
        Write-Host "❌ Database query failed" -ForegroundColor Red
        $checks += $false
    }
} catch {
    Write-Host "❌ Database connection error: $($_.Exception.Message)" -ForegroundColor Red
    $checks += $false
}

Write-Host ""

# 5. Documentation Files
Write-Host "5️⃣  Documentation Files" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

$docFiles = @(
    "API_DEPLOYMENT_SUMMARY.md",
    "API_QUICK_REFERENCE.md",
    "IMPLEMENTATION_SUMMARY.md",
    "api/README.md",
    "api/swagger.json"
)

foreach ($file in $docFiles) {
    $fullPath = "c:\Users\nislei\Downloads\SAW-main\SAW-main\$file"
    if (Test-Path $fullPath) {
        $size = (Get-Item $fullPath).Length / 1KB
        Write-Host "✅ $file ($(([math]::Round($size, 1))) KB)" -ForegroundColor Green
        $checks += $true
    } else {
        Write-Host "❌ $file - Not found" -ForegroundColor Red
        $checks += $false
    }
}

Write-Host ""

# 6. Summary
Write-Host "6️⃣  Summary" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

$totalChecks = $checks.Count
$passedChecks = ($checks | Where-Object { $_ -eq $true }).Count
$percentage = [math]::Round(($passedChecks / $totalChecks) * 100, 1)

Write-Host "Total Checks: $totalChecks" -ForegroundColor Cyan
Write-Host "Passed: $passedChecks" -ForegroundColor Green
Write-Host "Failed: $($totalChecks - $passedChecks)" -ForegroundColor Yellow
Write-Host "Success Rate: $percentage%" -ForegroundColor Cyan

Write-Host ""

if ($percentage -eq 100) {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║         ✅ ALL CHECKS PASSED - API READY FOR PRODUCTION          ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
} elseif ($percentage -ge 80) {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║         ⚠️  MOST CHECKS PASSED - REVIEW FAILURES                ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
} else {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║         ❌ MULTIPLE FAILURES - REVIEW CONFIGURATION              ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
}

Write-Host ""
Write-Host "📚 Documentation URLs:" -ForegroundColor Cyan
Write-Host "   Swagger UI: $baseUrl/api/swagger-ui.html" -ForegroundColor White
Write-Host "   API Base: $apiUrl" -ForegroundColor White
Write-Host "   Postman: Import api/SAW_API_Postman.json" -ForegroundColor White

Write-Host ""
Write-Host "✨ Verification complete!" -ForegroundColor Green
