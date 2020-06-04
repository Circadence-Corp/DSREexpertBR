$outlook=new-object -com outlook.application;
$mapi=$outlook.GetNameSpace('MAPI');
$inbox=$mapi.GetDefaultFolder(6);
$mail=$inbox.Items;
$text=($mail | where-object {$_.Body -like '*HYPERLINK*'} |Select-Object -last 1).Body;
$startix=$text.IndexOf('HYPERLINK');
$len=$text.IndexOf('click here')-$startix-12;
$url=$text.Substring($startix+11, $len)
$ie=new-object -com internetexplorer.application;
$ie.visible=$true;
$ie.navigate($url);
Start-Sleep 120;
$ie.Quit();
