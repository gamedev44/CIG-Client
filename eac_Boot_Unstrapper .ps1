Add-Type -AssemblyName PresentationFramework

function Show-MessageBox {
    param (
        [string]$message,
        [string]$title = "Information"
    )
    [System.Windows.MessageBox]::Show($message, $title)
}

# Step 1: Check if StarCitizen_Launcher.exe path is stored, if not, prompt user to drag and drop
$starCitizenLauncherPath = Get-Content -Path "C:\path\to\starCitizenLauncherPath.txt" -ErrorAction SilentlyContinue
if (-not $starCitizenLauncherPath) {
    Show-MessageBox -message "StarCitizen_Launcher.exe path not found. Please drag and drop StarCitizen_Launcher.exe from the directory 'C:\Program Files\Roberts Space Industries\StarCitizen\HOTFIX\'." -title "StarCitizen_Launcher.exe Path Not Found"
    exit
}

# Set up variables for EAC workaround
$wine_prefix = "C:\path\to\wine\prefix"
$eac_dir = "$wine_prefix\drive_c\users\$env:USERNAME\AppData\Roaming\EasyAntiCheat"
$eac_hosts = "127.0.0.1 modules-cdn.eac-prod.on.epicgames.com"

# Check if the EAC workaround is needed
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$hostsContent = Get-Content -Path $hostsPath
$hostsExist = $hostsContent -contains "$eac_hosts #Star Citizen EAC workaround"

$applyEacHosts = -not $hostsExist
$deleteEacDir = Test-Path -Path $eac_dir
$eacMessage = "Easy Anti-Cheat workaround has been deployed!"

if ($applyEacHosts -or $deleteEacDir) {
    $eacMessage = "The following changes will be made:"
    if ($applyEacHosts) {
        $eacMessage += "`n- Add the entry '$eac_hosts' to your hosts file."
    }
    if ($deleteEacDir) {
        $eacMessage += "`n- Delete the directory '$eac_dir'."
    }
    $eacMessage += "`n`nDo you want to proceed?"

    $result = [System.Windows.MessageBox]::Show($eacMessage, "Confirmation", [System.Windows.MessageBoxButton]::YesNo)
    if ($result -eq [System.Windows.MessageBoxResult]::No) {
        Show-MessageBox -message "Operation cancelled by the user."
        exit
    }

    if ($applyEacHosts) {
        Add-Content -Path $hostsPath -Value "$eac_hosts #Star Citizen EAC workaround"
        Write-Output "Hosts file modified successfully."
    }

    if ($deleteEacDir) {
        Remove-Item -Path $eac_dir -Recurse -Force
        Write-Output "EAC directory deleted successfully."
    }

    Show-MessageBox -message "Easy Anti-Cheat workaround has been deployed successfully."
}

Write-Output "All operations completed successfully."
