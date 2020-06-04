param([string]$url)
$ie = New-Object -Com internetExplorer.Application
$ie.visible=$true;
$ie.Navigate($url)

#------------------------------
#Wait for Download Dialog box to pop up
while($ie.Busy){start-sleep -m 100} 
#------------------------------

#check for SSL cert bypass
if ($ie.document.url -Match "invalidcert")
{
    $sslbypass = $ie.Document.getElementsByTagName("a") | where-object {$_.id -eq "overridelink"};
    $sslbypass.click();
    while($ie.ReadyState -ne 4) {start-sleep -m 100};
    # renav to download
    $ie.Navigate($url);
    while($ie.Busy){start-sleep -m 100} 
}

#Hit "S" on the keyboard to hit the "Save" button on the download box
sleep 1
$proc = Get-Process |where {$_.MainWindowTitle.startswith('0%')}
$obj = new-object -com WScript.Shell
$obj.AppActivate($proc.Id)

start-sleep -m 400
$obj.SendKeys('R')
Sleep 1
$obj.SendKeys('R')
# post an extra R
Sleep 1
$obj.SendKeys('R')
