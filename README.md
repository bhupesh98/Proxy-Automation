# Proxy-Automation

This is a simple automation script to automate the process of setting up a proxy server on your machine. Currently, it only tackles the setup of a proxy server on a Windows machine. The script is written in PowerShell and is very easy to use. 

Based on contributions and popularity, I will be adding support for other operating systems as well.

## Features

> [!NOTE]
> This script just toggles proxy so it doesn't require credential access. This also means you need to have the proxy settings configured in your system once.

This toggles proxy of following applications:

1. System Proxy
2. Git
3. NPM
4. VS Code

... More to add based on contributions/suggestions.

## How to Contribute

1. Fork the repository

2. Clone the repository to your local machine

```bash
git clone https://github.com/bhupesh98/Proxy-Automation.git && cd Proxy-Automation
```

3. To make this script as an executable, you need to install the `ps2exe` module. You can install it using the following command:

```powershell
Install-Module ps2exe
```

4. To convert the script to an executable, run the following command:

```powershell
Invoke-PS2EXE .\ToggleProxy.ps1 .\toggle-proxy.exe
```

5. Now, you can run the `toggle-proxy.exe` file to toggle the proxy settings on your machine. This needs to be configured in task scheduler to run when you connect to a network. I've prepared a powershell script for that as well. You can run the following command to configure the task scheduler:

```powershell
.\Install-ToggleProxyTask-Contributor.ps1
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.