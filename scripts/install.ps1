# Installs the MultipleClaude PowerShell module for your user (no admin rights).
#   irm https://raw.githubusercontent.com/dusy4/multiple-claude-accounts-desktop-app/main/scripts/install.ps1 | iex
$ErrorActionPreference = 'Stop'
$docs = [Environment]::GetFolderPath('MyDocuments')
$dest = Join-Path $docs 'WindowsPowerShell\Modules\MultipleClaude'
New-Item -ItemType Directory -Force $dest | Out-Null
$src = 'https://raw.githubusercontent.com/dusy4/multiple-claude-accounts-desktop-app/main/scripts/MultipleClaude.psm1'
Invoke-WebRequest -UseBasicParsing $src -OutFile (Join-Path $dest 'MultipleClaude.psm1')
$ps7 = Join-Path $docs 'PowerShell\Modules\MultipleClaude'
New-Item -ItemType Directory -Force $ps7 | Out-Null
Copy-Item (Join-Path $dest 'MultipleClaude.psm1') $ps7 -Force
Import-Module MultipleClaude -Force
Write-Host ''
Write-Host 'Installed. Create an account per Claude login:' -ForegroundColor Green
Write-Host '  New-ClaudeProfile Work'
Write-Host '  New-ClaudeProfile Personal'
Write-Host ''
Write-Host 'Every account in one window, switching without signing out: SaneCode, free for 2 accounts.'
Write-Host '  https://sanecode.co'
