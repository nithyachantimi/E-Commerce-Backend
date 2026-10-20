# Windows PowerShell Startup Script for E-Commerce Spring Boot Backend
# Usage: .\start-backend.ps1
$ErrorActionPreference = 'Stop'
if ($PSScriptRoot) { Set-Location -Path $PSScriptRoot }

# 1. Database Connection Configuration
$env:SPRING_DATASOURCE_URL = 'jdbc:mysql://localhost:3306/ecommerce_auth?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true'
$env:SPRING_DATASOURCE_USERNAME = 'ecommerce_app'
if (-not $env:SPRING_DATASOURCE_PASSWORD) {
    $securePassword = Read-Host 'Enter the local ecommerce_app database password' -AsSecureString
    $passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    try {
        $env:SPRING_DATASOURCE_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
    }
}

# 2. Local profile enables console delivery of OTP recovery codes
$env:SPRING_PROFILES_ACTIVE = 'local'

# 3. Generate a secure 256-bit HMAC-SHA256 signing secret for JWTs
if (-not $env:JWT_SECRET) {
    $secretBytes = New-Object byte[] 32
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($secretBytes)
    $env:JWT_SECRET = [Convert]::ToBase64String($secretBytes)
}

# 4. CORS and Cookie Policy for Local Development
$env:CORS_ALLOWED_ORIGINS = 'http://localhost:5173'
$env:APP_COOKIE_SECURE = 'false'
$env:APP_COOKIE_SAME_SITE = 'Lax'

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " Starting E-Commerce Auth Backend (http://localhost:8080)" -ForegroundColor Green
Write-Host " Swagger UI: http://localhost:8080/swagger-ui.html" -ForegroundColor Cyan
Write-Host " OpenAPI Docs: http://localhost:8080/v3/api-docs" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Green

$wrapper = if ($PSScriptRoot) { "$PSScriptRoot\mvnw.cmd" } else { ".\mvnw.cmd" }
& $wrapper spring-boot:run
