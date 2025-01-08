# <CONFIG>

$share="\\DC\folder-to-sysmon" 

# </CONFIG>

$sysmon=((Get-Service -Name Sysmon64 -ErrorAction SilentlyContinue).DisplayName)

if ($sysmon -ne $null)
{

    if ((Get-CimInstance Win32_OperatingSystem).OSArchitecture -eq "64-bit")
    {
        Write-Host "[*] Getting 64-bit Sysmon! [*]"
        Invoke-WebRequest -Uri $share\sysmon64.exe -OutFile $env:TEMP\sysmon.exe
    }
    elseif ((Get-CimInstance Win32_OperatingSystem).OSArchitecture -eq "32-bit")
    {
        Write-Host "[*] Getting 32-bit Sysmon! [*]"
        Invoke-WebRequest -Uri $share\sysmon.exe -OutFile $env:TEMP\sysmon.exe
    }

}

if (Test-Path -Path $env:TEMP\sysmon-hash.txt)
{
    Write-Host "[*] sysmon-hash.txt exists! [*]"

    $new=((Get-FileHash -Path $share\config.xml).Hash)
    $cur=(Get-Content $env:TEMP\sysmon-hash.txt)

    if ($cur -ne $new)
    {
        Write-Host "[*] sysmon-hash.txt changed! [*]"

        Invoke-WebRequest -Uri $share\config.xml -OutFile $env:TEMP\config.xml
        (Get-FileHash $env:TEMP\config.xml).Hash | Out-File -FilePath $env:TEMP\sysmon-hash.txt

        & $env:TEMP\sysmon.exe -accepteula -i $env:TEMP\config.xml
    }
    else
    {
        Write-Host "[*] sysmon-hash.txt didn't change! [*]"
        exit
    }
    
}
else
{
    Write-Host "[*] sysmon-hash.txt doesn't exist! [*]"

    Invoke-WebRequest -Uri $share\config.xml -OutFile $env:TEMP\config.xml
    (Get-FileHash $env:TEMP\config.xml).Hash | Out-File -FilePath $env:TEMP\sysmon-hash.txt

    & $env:TEMP\sysmon.exe -accepteula -i $env:TEMP\config.xml
}

