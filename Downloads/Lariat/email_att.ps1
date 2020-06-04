Add-type -assembly "Microsoft.Office.Interop.Outlook" | out-null
$outlook=new-object -com outlook.application;
$mapi=$outlook.GetNameSpace('MAPI');
$inbox=$mapi.GetDefaultFolder(6);
$mail=$inbox.Items;
$tempdir = $env:temp
$mail |foreach {
    $_.attachments |foreach {
        if (!$_.filename.StartsWith("collab")) {
            $fp = (Join-Path $tempdir $_.filename)
            $_.saveasfile($fp)

            $xl = new-object -comobject Word.Application
            $xl.visible = $true
            $xl.DisplayAlerts = [Microsoft.Office.Interop.Word.WdAlertLevel]::wdAlertsNone
            $wb = $xl.Documents.Open($fp)
            Start-Sleep 1
            Stop-Process -name "WINWORD"
        }
    }
}
Stop-Process -name "OUTLOOK"
