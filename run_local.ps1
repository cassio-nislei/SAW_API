$env:DB_HOST = "104.234.173.105"
$env:DB_USER = "root"
$env:DB_PASS = "Ncm@647534"
$env:DB_NAME = "saw_quality"

Write-Host "Starting PHP server at http://localhost:8000..."
Write-Host "Press Ctrl+C to stop."

Start-Process "http://localhost:8000"
php -d variables_order=EGPCS -S localhost:8000
