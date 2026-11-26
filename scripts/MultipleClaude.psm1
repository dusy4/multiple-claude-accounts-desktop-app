<#
  MultipleClaude: run several Claude Desktop accounts on one Windows PC, by hand.

  Each account is the official Claude Desktop app started with its own data folder
  (--user-data-dir), so each keeps its own sign-in. Every account opens in its own window.

    New-ClaudeProfile Work       # create the account's folder and a Start-menu shortcut, then open it
    Start-ClaudeProfile Work     # open it again later
    Get-ClaudeProfile            # list accounts and whether they're open
    Send-ClaudeSignIn Work       # hand a copied claude:// sign-in link to that account

  Nothing is ever deleted. Want every account in one window, switching without signing out?
  That's SaneCode: https://sanecode.co (free for 2 accounts).
  MIT License. Not affiliated with Anthropic.
#>

# Claude Desktop on Windows is a Store (MSIX) app. Windows redirects its writes into the app's
# private storage, except under %LOCALAPPDATA%\Claude-Data, so account folders live there.
$script:Root  = Join-Path $env:LOCALAPPDATA 'Claude-Data'
$script:Alias = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\claude-desktop.exe'
$script:Menu  = Join-Path ([Environment]::GetFolderPath('Programs')) 'Claude accounts'

function Assert-Name([string]$Name) {
  if ($Name -notmatch '^[A-Za-z0-9@+._-]{1,60}$' -or $Name -match '^\.+$') {
    throw "Use letters, digits and @ + . _ - only (got '$Name')."
  }
}
function Get-Folder([string]$Name) { Join-Path $script:Root "acct-$Name" }
function Assert-Claude {
  if (-not (Test-Path -LiteralPath $script:Alias)) {
    throw "Claude Desktop isn't installed (no $script:Alias). Get it from https://claude.ai/download and open it once."
  }
}

function Get-ClaudeProfile {
  <# Lists your Claude accounts and whether each is open. #>
  if (-not (Test-Path $script:Root)) { return }
  $open = @(Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -notmatch '--type=' } |
    ForEach-Object { [regex]::Match([string]$_.CommandLine, 'Claude-Data\\acct-([^"\\\s]+)').Groups[1].Value })
  Get-ChildItem $script:Root -Directory -Filter 'acct-*' | ForEach-Object {
    $n = $_.Name.Substring(5)
    [pscustomobject]@{ Name = $n; Open = ($open -contains $n); Folder = $_.FullName }
  }
}

function Start-ClaudeProfile {
  <# Opens one account in its own Claude window. #>
  param([Parameter(Mandatory, Position = 0)][string]$Name, [string]$Link)
  Assert-Name $Name; Assert-Claude
  $dir = Get-Folder $Name
  if (-not (Test-Path -LiteralPath $dir)) { throw "No account '$Name'. Create it with: New-ClaudeProfile $Name" }
  $argList = "--user-data-dir=`"$dir`""
  if ($Link) { $argList += " `"$Link`"" }
  Start-Process $script:Alias $argList
}

function New-ClaudeProfile {
  <# Creates an account: its own data folder and a Start-menu shortcut. Then opens it so you can sign in. #>
  param([Parameter(Mandatory, Position = 0)][string]$Name, [switch]$NoStart)
  Assert-Name $Name; Assert-Claude
  $dir = Get-Folder $Name
  if (Test-Path -LiteralPath $dir) { Write-Host "'$Name' already exists."; if (-not $NoStart) { Start-ClaudeProfile $Name }; return }
  New-Item -ItemType Directory -Force $dir | Out-Null
  New-Item -ItemType Directory -Force $script:Menu | Out-Null
  $lnk = (New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $script:Menu "Claude - $Name.lnk"))
  $lnk.TargetPath = $script:Alias
  $lnk.Arguments = "--user-data-dir=`"$dir`""
  $lnk.Description = "Claude Desktop, account $Name"
  $lnk.Save()
  Write-Host "Created '$Name'. Start menu: Claude accounts > Claude - $Name."
  Write-Host "Sign in inside the new window. If the browser sends the sign-in to another Claude window, use: Send-ClaudeSignIn $Name"
  if (-not $NoStart) { Start-ClaudeProfile $Name }
}

function Send-ClaudeSignIn {
  <# Windows sends claude:// sign-in links to the first Claude window. Copy the link, then run this to send it to the right account. #>
  param([Parameter(Mandatory, Position = 0)][string]$Name)
  Add-Type -AssemblyName System.Windows.Forms
  $m = [regex]::Match([Windows.Forms.Clipboard]::GetText(), "claude://[^\s'`"<>]+")
  if (-not $m.Success) {
    throw "No claude:// link on the clipboard. On the sign-in page press F12, open Console, click 'Open Claude', copy the claude://... line, then run this again."
  }
  Start-ClaudeProfile $Name -Link $m.Value
  Write-Host "Sign-in link sent to '$Name'."
}

Export-ModuleMember -Function Get-ClaudeProfile, Start-ClaudeProfile, New-ClaudeProfile, Send-ClaudeSignIn
