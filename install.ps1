#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$ServerBaseUrl = if ($env:SERVER_BASE_URL) { $env:SERVER_BASE_URL } else { "https://n-suite.github.io" }

$ExtensionBundleId = "dev.n-suite.extension"
$ExtensionHelperBundleId = "dev.n_suite.extension.helper"

$ChromeNMHDir = "$env:LOCALAPPDATA\Google\Chrome\User Data\NativeMessagingHosts"
$ExtensionDir = "$env:LOCALAPPDATA\$ExtensionBundleId"
$ExtensionChromeDir = "$ExtensionDir\chrome-extension"

New-Item -ItemType Directory -Force -Path $ChromeNMHDir | Out-Null

$ManifestPath = "$ChromeNMHDir\$ExtensionHelperBundleId.json"
$HelperExePath = "$ExtensionDir\extension-helper.exe" -replace '\\', '\\'
@"
{
  "name": "$ExtensionHelperBundleId",
  "description": "Native Messaging Host for N Extension",
  "path": "$HelperExePath",
  "type": "stdio",
  "allowed_origins": ["chrome-extension://ajbcfkngjknleogmjkekkajnffgefjem/"]
}
"@ | Set-Content -Encoding UTF8 $ManifestPath

$RegPath = "HKCU:\Software\Google\Chrome\NativeMessagingHosts\$ExtensionHelperBundleId"
New-Item -Path $RegPath -Force | Out-Null
Set-ItemProperty -Path $RegPath -Name "(default)" -Value $ManifestPath

New-Item -ItemType Directory -Force -Path $ExtensionDir | Out-Null

$GzPath = "$ExtensionDir\extension-helper.exe.gz"
Invoke-WebRequest -Uri "$ServerBaseUrl/downloads/helper/extension-helper.exe.gz" -OutFile $GzPath

Add-Type -AssemblyName System.IO.Compression.FileSystem
$inputStream = [System.IO.File]::OpenRead($GzPath)
$outputStream = [System.IO.File]::Create("$ExtensionDir\extension-helper.exe")
$gzStream = [System.IO.Compression.GZipStream]::new($inputStream, [System.IO.Compression.CompressionMode]::Decompress)
$gzStream.CopyTo($outputStream)
$gzStream.Close()
$outputStream.Close()
$inputStream.Close()
Remove-Item $GzPath

Write-Host '1/2: Extension Helperをインストールしました。'

New-Item -ItemType Directory -Force -Path $ExtensionChromeDir | Out-Null

$TarGzPath = "$ExtensionDir\chrome-extension.tar.gz"
Invoke-WebRequest -Uri "$ServerBaseUrl/downloads/extension/chrome-extension.tar.gz" -OutFile $TarGzPath
tar -xzf $TarGzPath -C $ExtensionChromeDir
Remove-Item $TarGzPath

Write-Host '2/2: Chrome用拡張機能をダウンロードしました。'

Start-Process explorer.exe $ExtensionChromeDir

Write-Host 'セットアップが完了しました。続きは: https://n-suite.github.io を参照してください。'
Write-Host '    (開かれたフォルダは消さないでください。Chrome拡張機能のインストールに必要です。)'
Write-Host '    (消してしまった場合は、再度このスクリプトを実行してください。)'