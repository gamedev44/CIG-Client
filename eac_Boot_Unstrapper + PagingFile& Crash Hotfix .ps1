Add-Type -AssemblyName PresentationFramework

function Show-MessageBox {
    param (
        [string]$message,
        [string]$title = "Information"
    )
    [System.Windows.MessageBox]::Show($message, $title)
}

function Prompt-DragAndDrop {
    param (
        [string]$promptMessage,
        [string]$expectedFileName
    )
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $promptMessage
    $form.Width = 400
    $form.Height = 200

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $promptMessage
    $label.Dock = [System.Windows.Forms.DockStyle]::Fill
    $label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $form.Controls.Add($label)

    $form.AllowDrop = $true
    $form.Add_DragEnter({$_.Effect = [System.Windows.Forms.DragDropEffects]::Copy})
    $form.Add_DragDrop({
        param($sender, $e)
        $files = $e.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
        if ($files -and $files.Length -eq 1 -and (Get-Item $files[0]).Name -eq $expectedFileName) {
            $path = $files[0]
            $label.Text = "File path: $path"
            $form.Tag = $path
            $form.Close()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please drag and drop the correct file: $expectedFileName")
        }
    })

    $form.ShowDialog()
    return $form.Tag
}

# Step 1: Check if StarCitizen.exe path is stored, if not, prompt user to drag and drop
$starCitizenPath = Get-Content -Path "C:\path\to\starCitizenPath.txt" -ErrorAction SilentlyContinue
if (-not $starCitizenPath) {
    $starCitizenPath = Prompt-DragAndDrop -promptMessage "Drag and drop StarCitizen.exe here" -expectedFileName "StarCitizen.exe"
    if (-not $starCitizenPath) {
        Show-MessageBox -message "Operation cancelled by the user."
        exit
    }
    $starCitizenPath | Set-Content -Path "C:\path\to\starCitizenPath.txt"
}

# Define the desired size in MB for paging file
$initialSize = 64000
$maximumSize = 64000

# Step 2: Modify the paging file settings
$pagefile = Get-WmiObject -Query "SELECT * FROM Win32_PageFileSetting WHERE Name='C:\\pagefile.sys'"

if ($pagefile) {
    $pagefile.InitialSize = $initialSize
    $pagefile.MaximumSize = $maximumSize
    $pagefile.Put()
    Write-Output "Paging file size updated successfully."
} else {
    $newPagefile = ([WmiClass]"\\.\root\cimv2:Win32_PageFileSetting").CreateInstance()
    $newPagefile.Name = "C:\\pagefile.sys"
    $newPagefile.InitialSize = $initialSize
    $newPagefile.MaximumSize = $maximumSize
    $newPagefile.Put()
    Write-Output "Paging file size set successfully."
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
