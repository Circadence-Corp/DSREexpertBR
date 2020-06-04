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

            $xl = new-object -comobject Excel.Application
            $xl.visible = $true
            $xl.DisplayAlerts = $false
            $wb = $xl.Workbooks.Open($fp)
            $xl.Run("Workbook_Open")

            Start-Sleep 30
            $xl.Quit()
            break
        }
    }
}
Stop-Process -name "OUTLOOK"
