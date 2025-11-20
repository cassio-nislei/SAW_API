# PowerShell - Executar SQL Migrations

## ⚠️ PROBLEMA

# O PowerShell interpreta "<" como operador, não como redirecionamento

## ✅ SOLUÇÃO 1: CMD.EXE (Recomendado - Mais Simples)

cmd /c "mysql -h 104.234.173.105 -u root -p saw15 < api\v1\migrations-audit.sql"

## ✅ SOLUÇÃO 2: PowerShell Nativo (Get-Content)

Get-Content api\v1\migrations-audit.sql | mysql -h 104.234.173.105 -u root -p saw15

## ✅ SOLUÇÃO 3: PowerShell com Prompt de Senha

$password = Read-Host "Senha MySQL" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential("root", $password)
Get-Content api\v1\migrations-audit.sql | mysql -h 104.234.173.105 -u root --password=$($credential.GetNetworkCredential().Password) saw15

## ✅ SOLUÇÃO 4: Script PowerShell Completo

# Criar arquivo: execute-migrations.ps1

$dbHost = "104.234.173.105"
$dbUser = "root"
$dbName = "saw15"
$sqlFile = "api\v1\migrations-audit.sql"

# Solicitar senha

$dbPassword = Read-Host "Digite a senha MySQL" -AsSecureString
$dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($dbPassword))

# Executar SQL

$sqlContent = Get-Content $sqlFile -Raw
mysql -h $dbHost -u $dbUser -p"$dbPasswordPlain" $dbName | Out-Null

# Alternativa com arquivo temporário

$tempFile = [System.IO.Path]::GetTempFileName()
Get-Content $sqlFile | Out-File $tempFile -Encoding UTF8
mysql -h $dbHost -u $dbUser -p"$dbPasswordPlain" $dbName < $tempFile
Remove-Item $tempFile

Write-Host "✅ Migrations executadas com sucesso!" -ForegroundColor Green
