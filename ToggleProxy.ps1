# Paths to configuration files
$NpmrcPath = "$HOME\.npmrc"
$GitConfigPath = "$HOME\.gitconfig"
$VSCodeSettingPath = "$HOME\AppData\Roaming\Code\User\settings.json"
$Pattern = 'proxy\s*=\s*http.*'

# Take proxy cred from here
$proxyServer = Get-ItemPropertyValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyServer

# ping $proxyServer -n 1 -w 50 > $null 2>&1
ping $proxyServer.Split(':')[0] -n 1 -w 50 > $null 2>&1

if ($?) {
    # Enable proxy
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 1
    # In .npmrc
    if (Test-Path $NpmrcPath) {
        Get-Content $NpmrcPath -Raw -replace "(?m)^#\s*($Pattern)", '$1' | Set-Content $NpmrcPath -Force -NoNewline
    }
    # In .gitconfig
    if (Test-Path $GitConfigPath) {
        Get-Content $GitConfigPath -Raw -replace "(?m)^(\s*)#\s*($Pattern)", '$1$2' | Set-Content $GitConfigPath -Force -NoNewline
    }
    # In vscode/settings.json
    if (Test-Path $VSCodeSettingPath) {
        (Get-Content $VSCodeSettingPath -Raw) -replace '(?m)^(\s*)//\s*("http.proxy":.*)', '$1$2' | Set-Content $VSCodeSettingPath -Force -NoNewline
    }
} else {
    # Disable proxy
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 0
    # In .npmrc
    if (Test-Path $NpmrcPath) {
        (Get-Content $NpmrcPath -Raw) -replace "(?m)^($Pattern)", '# $1' | Set-Content $NpmrcPath -Force -NoNewline
    }
    # In .gitconfig
    if (Test-Path $GitConfigPath) {
        (Get-Content $GitConfigPath -Raw) -replace "(?m)^(\s*)($Pattern)", '$1# $2' | Set-Content $GitConfigPath -Force -NoNewline
    }
    # In vscode/settings.json
    if (Test-Path $VSCodeSettingPath) {
        (Get-Content $VSCodeSettingPath -Raw) -replace '(?m)^(\s*)("http.proxy":.*)', '$1// $2' | Set-Content $VSCodeSettingPath -Force -NoNewline
    }
}