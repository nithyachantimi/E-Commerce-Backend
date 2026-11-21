[CmdletBinding()]
param(
    [ValidateSet('All', 'Backend', 'Frontend')]
    [string] $Mode = 'All'
)

$ErrorActionPreference = 'Stop'
$backendDir = $PSScriptRoot
$frontendDir = Join-Path (Split-Path $backendDir -Parent) 'E-Commerce-Frontend'
$backendUrl = 'http://127.0.0.1:8080'
$frontendUrl = 'http://127.0.0.1:5174'
$loginUrl = "$frontendUrl/login"

function Test-PortListening([int] $Port) {
    return [bool](Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -First 1)
}

function Test-BackendReady {
    try {
        $spec = Invoke-RestMethod -Uri "$backendUrl/v3/api-docs" -TimeoutSec 3
        $paths = @($spec.paths.PSObject.Properties.Name)
        return ($paths -contains '/api/reg') -and ($paths -contains '/api/login')
    } catch { return $false }
}

function Test-FrontendReady {
    try {
        $page = Invoke-WebRequest -Uri $loginUrl -TimeoutSec 3 -UseBasicParsing
        return $page.StatusCode -eq 200 -and $page.Content.Contains('E-Commerce')
    } catch { return $false }
}

function Start-Child([string] $ChildMode) {
    $arguments = @('-NoLogo', '-NoExit', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Mode', $ChildMode)
    Start-Process -FilePath 'powershell.exe' -ArgumentList $arguments -WorkingDirectory $backendDir | Out-Null
}

function Start-Backend {
    # Keep the password encrypted for this Windows user only; it is never written to the project.
    $credentialFile = Join-Path $env:LOCALAPPDATA 'ECommerceAuth\ecommerce-app-password.dpapi'
    $password = $null
    if (Test-Path -LiteralPath $credentialFile) {
        try {
            $encrypted = Get-Content -LiteralPath $credentialFile -Raw
            $password = ConvertTo-SecureString -String $encrypted
            Write-Host 'Using the locally encrypted ecommerce_app credential.' -ForegroundColor DarkGray
        } catch {
            Write-Host 'Saved local credential could not be read. Enter the current ecommerce_app password.' -ForegroundColor Yellow
        }
    }
    if (-not $password) {
        $password = Read-Host 'Enter the MySQL ecommerce_app password (input is hidden)' -AsSecureString
        $choice = Read-Host 'Remember it encrypted for this Windows account? (Y/N)'
        if ($choice -match '^(y|yes)$') {
            try {
                $directory = Split-Path $credentialFile -Parent
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
                ConvertFrom-SecureString -SecureString $password | Set-Content -LiteralPath $credentialFile -NoNewline
                Write-Host 'Saved encrypted credential under your Windows profile.' -ForegroundColor Green
            } catch {
                Write-Host 'Could not save the encrypted credential; this run can continue.' -ForegroundColor Yellow
            }
        }
    }

    $passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    try {
        $env:SPRING_DATASOURCE_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
        $env:CORS_ALLOWED_ORIGINS = 'http://127.0.0.1:5174'
        & (Join-Path $backendDir 'start-backend.ps1')
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
        Remove-Item Env:\SPRING_DATASOURCE_PASSWORD -ErrorAction SilentlyContinue
    }
}

function Start-Frontend {
    Set-Location -LiteralPath $frontendDir
    $env:VITE_API_BASE_URL = 'http://127.0.0.1:8080/api'
    Write-Host "Starting E-Commerce frontend at $frontendUrl" -ForegroundColor Green
    & npm.cmd run dev -- --host 127.0.0.1 --port 5174 --strictPort
}

if ($Mode -eq 'Backend') { Start-Backend; exit }
if ($Mode -eq 'Frontend') { Start-Frontend; exit }

Write-Host 'Starting E-Commerce authentication system...' -ForegroundColor Green
Write-Host 'This launcher uses MySQL 3306, backend 8080 and E-Commerce frontend 5174.'

try {
    $mysqlService = Get-Service -Name 'MySQL84' -ErrorAction Stop
    if ($mysqlService.Status -ne 'Running') {
        Write-Host 'Starting the existing MySQL84 service...' -ForegroundColor Cyan
        Start-Service -Name 'MySQL84' -ErrorAction Stop
        $mysqlService = Get-Service -Name 'MySQL84'
        $mysqlService.WaitForStatus('Running', [TimeSpan]::FromSeconds(30))
    }
} catch {
    Write-Host 'Could not inspect or start the existing MySQL84 service.' -ForegroundColor Red
    Write-Host 'Start MySQL84 from Windows Services (you may need administrator access), then double-click this launcher again.' -ForegroundColor Yellow
    exit 1
}

try {
    $db = [System.Net.Sockets.TcpClient]::new()
    $db.Connect('127.0.0.1', 3306)
    $db.Close()
} catch {
    Write-Host 'MySQL84 is running, but port 3306 is not accepting connections. Check the MySQL service configuration, then try again.' -ForegroundColor Red
    exit 1
}

if (-not (Test-BackendReady)) {
    if (Test-PortListening 8080) {
        Write-Host 'Port 8080 is occupied by a service that does not identify as this E-Commerce API. Nothing was stopped.' -ForegroundColor Red
        exit 1
    }
    Start-Child 'Backend'
} else {
    Write-Host 'E-Commerce backend is already running.' -ForegroundColor DarkGray
}

if (-not (Test-FrontendReady)) {
    if (Test-PortListening 5174) {
        Write-Host 'Port 5174 is occupied by a service that does not serve this E-Commerce login page. Nothing was stopped.' -ForegroundColor Red
        exit 1
    }
    Start-Child 'Frontend'
} else {
    Write-Host 'E-Commerce frontend is already running.' -ForegroundColor DarkGray
}

Write-Host 'Waiting for the login page. The backend may pause for the first-time database password.' -ForegroundColor Cyan
$deadline = (Get-Date).AddMinutes(3)
while ((Get-Date) -lt $deadline) {
    if (Test-FrontendReady -and (Test-BackendReady)) {
        Start-Process $loginUrl
        Write-Host "Opened $loginUrl" -ForegroundColor Green
        Write-Host 'Keep the backend and frontend windows open while using the app.'
        exit 0
    }
    Start-Sleep -Seconds 2
}

Write-Host 'The services did not both become ready within 3 minutes. Check the backend and frontend windows for errors.' -ForegroundColor Yellow
Write-Host "When the frontend is ready, open $loginUrl"
exit 1
