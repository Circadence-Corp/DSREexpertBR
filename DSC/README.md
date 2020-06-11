# What's the resources for?

ARM does a lot of heavy lifting, but DSC does even more.  In these DSC configurations, [Choco](https://chocolatey.org/) is also leveraged on all the VMs.

## ContosoDC

ContosoDC is the Domain Controller.  It's default Forest is 'Contoso.Azure'.  It also creates users, including:

| Username | Role | Purpose |
|----------|------|---------|
| SamiraA  | Domain Admin | Manages the domain |
| RonHD    | Helpdesk | Manages endpoints, but not Domain Controller |
| JeffL    | Unprivileged domain user, has admin access to VictimPC | User which is compromised, has admin access on own workstation to mimic local escalation |
| LisaV    | Unprivileged domain user, high impact user | Has access to highly confidential data | 

## VictimPC

This is where majority of attack tools are staged. VictimPC is where the adversary starts.

Note that these attack tools are for research purposes, and really aren't "malicious" but can be used maliciously based on *intent*.  Those tools include:
* Mimikatz (thanks [Benjamin Delpy](https://twitter.com/gentilkiwi]))
* PowerSploit (thanks [Will](https://twitter.com/HarmJ0y))
* Kekeo (thanks [Benjamin Delpy](https://twitter.com/gentilkiwi))

>**Note**
>
>[JoeWare's NetSess.exe](http://www.joeware.net/freetools/tools/netsess/index.htm) explicitly prevents us from including this automatically in the build.  You can however, add this yourself by grabbing it from their site.

## AdminPC

This is where SamiraA operates from.  This mimics a Privileged Admin Workstation (PAW).  It also shows that these workstations also have to be managed, which is why RonHD is also an administrator of this machine.

## Client01

Has data on the machine which can be seen as confidential, including credit card information and social security data.

## Updated Users and Workstations
User Full Name | Username | VM Name | IP Address |
| ------------ | -------- | ------- | ---------- |
Elsie Millar | ElsieM | INT-WKST01 | 10.0.24.14
Kerri Mason | KerriM | INT-WKST02 | 10.0.24.16
Muhammed Orozco | MuhammedO | INT-WKST03 | 10.0.24.17
Yasmin Weston | YasminW | INT-WKST04 | 10.0.24.18
Stefan Mcphee | StefanM | INT-WKST05 | 10.0.24.19
Pascal Rossi | PascalR | INT-WKST06 | 10.0.24.20
Nola Mclellan | NolaM | INT-WKST07 | 10.0.24.21
Raife Decker | RaifeD | INT-WKST08 | 10.0.24.22
Lilliana Dean | LillianaD | INT-WKST09 | 10.0.24.23
Karina Mccallum | KarinaM | INT-WKST10 | 10.0.24.24
Morgan Pineda | MorganP | INT-WKST11 | 10.0.24.25
Maureen Grimes | MaureenG | INT-WKST12 | 10.0.24.26
Shanna Mcclain | ShannaM | INT-WKST13 | 10.0.24.27
Macauly Walter | MacaulyW | INT-WKST14 | 10.0.24.28
Angel Taylor | AngelT | INT-WKST15 | 10.0.24.29
Tonya Mckay | TonyaM | INT-WKST16 | 10.0.24.30
Zaine O'Doherty | ZaineO | INT-WKST17 | 10.0.24.31
Jaxon Rosales | JaxonR | INT-WKST18 | 10.0.24.32
Owain Talbot | OwainT | INT-WKST19 | 10.0.24.33
Krish Gardiner | KrishG | INT-WKST20 | 10.0.24.34
Lariat | Lariat | Lariat | 10.0.24.51

## Local DSC Deployment Testing and Non-Secure Mof File Creation

### Remove Mof Files from dsc location: 

C:\Packages\Plugins\Microsoft.Powershell.DSC\2.80.0.0\DSCWork\Provision<Virtual Machine Name>Dsc.0\Setup<Virtual Machine Name>

### Set User variable credentials
(Example user variables)
#$ElsieMCred= get-credential -Credential contoso\elsiem
#$AdminCred = get-credential -Credential contoso\contosoadmin

### Update Script (Add code below to end of script): 
Script Location: 
C:\Packages\Plugins\Microsoft.Powershell.DSC\2.80.0.0\DSCWork\Provision<Virtual Machine Name>Dsc.0\Provision<Virtual Machine Name>Dsc.ps1

Code:
```powershell
 $cd = @{
    AllNodes = @(   
        @{
            NodeName = "localhost"
            PsDscAllowPlainTextPassword = $true
        }
    )
}

#$ElsieMCred= get-credential -Credential contoso\elsiem
#$AdminCred = get-credential -Credential contoso\contosoadmin
SetupIntWkst01 -DomainName "Contoso.Azure" -NetBiosName "Contoso" -DnsServer "10.0.24.4" -ElsieMCred $ElsieMCred -AdminCred $AdminCred -Branch "master" -ConfigurationData $cd
```

### Add any DSC updates

```powershell
        #region Lariat
        xRemoteFile GetLariat
        {
            DestinationPath = 'C:\Lariat\LariatClient.exe'
            Uri = "https://github.com/Circadence-Corp/DSREexpertBR/blob/$Branch/Downloads/Lariat/Lariat-9.7.1.0-install.exe?raw=true"
            DependsOn = '[Computer]JoinDomain'
        }

        #endregion
```
		
		
### Publish and run DSC

```powershell
Publish-DscConfiguration -Path C:\Packages\Plugins\Microsoft.Powershell.DSC\2.80.0.0\DSCWork\ProvisionIntWkst01Dsc.0\SetupIntWkst01
Start-DscConfiguration -UseExisting -ComputerName IntWkst01
```

### Troubleshooting
```powershell
Get-DscConfigurationStatus
```