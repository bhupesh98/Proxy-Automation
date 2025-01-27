# Paths to configuration files
$NpmrcPath = "$HOME\.npmrc"
$GitConfigPath = "$HOME\.gitconfig"
$VSCodeSettingPath = "$HOME\AppData\Roaming\Code\User\settings.json"
$Pattern = 'proxy\s*=\s*http.*'

# Take proxy cred from here
$proxyServer = Get-ItemPropertyValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyServer
try {
    $proxyUser = Get-ItemPropertyValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyUser
    $proxyPass = Get-ItemPropertyValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyPass
} catch {
    $proxyUser = $null
    $proxyPass = $null
}
$proxy = $null
if ($proxyUser -and $proxyPass) {
    $proxy = "http://${proxyUser}:${proxyPass}@$proxyServer"
}

# ping $proxyServer -n 1 -w 50 > $null 2>&1
ping $proxyServer.Split(':')[0] -n 1 -w 50 > $null 2>&1

if ($?) {
    # Enabling Env Vars Proxy for applications like Docker and Ollama
    if ($proxy) {
        [Environment]::SetEnvironmentVariable('HTTPS_PROXY', $proxy, [System.EnvironmentVariableTarget]::Machine)
    }
    # Enable proxy
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 1
    # In .npmrc
    if (Test-Path $NpmrcPath) {
        # Set proxy in .npmrc if it's not already set
        $content = Get-Content $NpmrcPath -Raw
        if ($proxy -and ($content -notmatch $Pattern)) {
            Add-Content $NpmrcPath "`nproxy = $proxy"
        } else {
            $content -replace "(?m)^#\s*($Pattern)", '$1' | Set-Content $NpmrcPath -Force -NoNewline
        }
    }
    # In .gitconfig
    if (Test-Path $GitConfigPath) {
        $content = Get-Content $GitConfigPath -Raw
        if ($proxy -and ($content -notmatch $Pattern)) {
            Add-Content $GitConfigPath "`n[http]`n    proxy = $proxy"
        } else {
            $content -replace "(?m)^(\s*)#\s*($Pattern)", '$1$2' | Set-Content $GitConfigPath -Force -NoNewline
        }
    }
    # In vscode/settings.json
    if (Test-Path $VSCodeSettingPath) {
        # Here, also check whether JSON is there or not, if it's there then only add proxy not create new JSON, but if JSON is not there then create new JSON
        $content = Get-Content $VSCodeSettingPath -Raw
        if ($proxy -and ($content -notmatch '"http.proxy"')) {
            # Check if JSON is there or not
            if ($content -match '^{.*}$') {
                $content = $content -replace '^{', '{`n    "http.proxy": "' + $proxy + '",'
            } else {
                $content = '{`n    "http.proxy": "' + $proxy + '",`n' + $content
            }
            # Add JSON to settings.json
            $content | Set-Content $VSCodeSettingPath -Force -NoNewline
        } else {
            $content -replace '(?m)^(\s*)//\s*("http.proxy":.*)', '$1$2' | Set-Content $VSCodeSettingPath -Force -NoNewline
        }
    }
} else {
    # Disable proxy
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 0

    # Disable Env Vars Proxy for applications like Docker and Ollama
    [Environment]::SetEnvironmentVariable('HTTPS_PROXY', $null, [System.EnvironmentVariableTarget]::Machine)

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