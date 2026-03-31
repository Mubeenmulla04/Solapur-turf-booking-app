# Webhook Testing Helper Script
# Starts backend server and ngrok tunnel for webhook testing

Write-Host "🚀 Starting Webhook Testing Environment..." -ForegroundColor Cyan
Write-Host ""

# Check if backend directory exists
if (-not (Test-Path "backend")) {
    Write-Host "❌ Error: backend directory not found!" -ForegroundColor Red
    Write-Host "   Please run this script from the project root." -ForegroundColor Yellow
    exit 1
}

# Check if ngrok is installed
$ngrokInstalled = Get-Command ngrok -ErrorAction SilentlyContinue
if (-not $ngrokInstalled) {
    Write-Host "⚠️  ngrok not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Install ngrok:" -ForegroundColor Cyan
    Write-Host "  1. Download from: https://ngrok.com/download" -ForegroundColor White
    Write-Host "  2. Or use: choco install ngrok" -ForegroundColor White
    Write-Host "  3. Or use: scoop install ngrok" -ForegroundColor White
    Write-Host ""
    Write-Host "After installing, configure your authtoken:" -ForegroundColor Cyan
    Write-Host "  ngrok config add-authtoken YOUR_TOKEN" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

# Check if node_modules exists
if (-not (Test-Path "backend\node_modules")) {
    Write-Host "📦 Installing backend dependencies..." -ForegroundColor Yellow
    Set-Location backend
    npm install
    Set-Location ..
    Write-Host ""
}

# Check if .env exists
if (-not (Test-Path "backend\.env")) {
    Write-Host "⚠️  .env file not found!" -ForegroundColor Yellow
    Write-Host "   Creating from .env.example..." -ForegroundColor Yellow
    if (Test-Path "backend\.env.example") {
        Copy-Item "backend\.env.example" "backend\.env"
        Write-Host "   ✅ Created backend/.env" -ForegroundColor Green
        Write-Host "   ⚠️  Please update backend/.env with your credentials!" -ForegroundColor Yellow
    } else {
        Write-Host "   ❌ .env.example not found!" -ForegroundColor Red
    }
    Write-Host ""
}

# Start backend server
Write-Host "🔧 Starting backend server on port 3000..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\backend'; Write-Host '🔧 Backend Server' -ForegroundColor Cyan; Write-Host ''; npm run start:dev"

# Wait for server to start
Write-Host "⏳ Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Check if server is running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Backend server is running!" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Backend server may still be starting..." -ForegroundColor Yellow
    Write-Host "   Check the backend terminal for any errors." -ForegroundColor Yellow
}

Write-Host ""

# Start ngrok
Write-Host "🌐 Starting ngrok tunnel..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host '🌐 Ngrok Tunnel' -ForegroundColor Cyan; Write-Host ''; ngrok http 3000"

# Wait a moment for ngrok to start
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ Webhook Testing Environment Started!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Check ngrok terminal for your public URL" -ForegroundColor White
Write-Host "   Example: https://abc123.ngrok-free.app" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Your webhook URL will be:" -ForegroundColor White
Write-Host "   https://YOUR-NGROK-URL.ngrok-free.app/api/webhook/razorpay" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Configure in Razorpay Dashboard:" -ForegroundColor White
Write-Host "   → Settings → Webhooks → + New Webhook" -ForegroundColor Gray
Write-Host "   → Paste webhook URL" -ForegroundColor Gray
Write-Host "   → Select events: payment.captured, payment.failed" -ForegroundColor Gray
Write-Host "   → Copy webhook secret" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Add webhook secret to backend/.env:" -ForegroundColor White
Write-Host "   RAZORPAY_WEBHOOK_SECRET=whsec_your_secret_here" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Test webhook:" -ForegroundColor White
Write-Host "   → Razorpay Dashboard → Webhooks → Send Test Webhook" -ForegroundColor Gray
Write-Host ""
Write-Host "📖 Full guide: WEBHOOK_TESTING_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Tip: Open http://localhost:4040 for ngrok web interface" -ForegroundColor Yellow
Write-Host ""

