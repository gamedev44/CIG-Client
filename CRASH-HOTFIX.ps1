Add-Type -AssemblyName PresentationFramework

# Prompt user to drag and drop StarCitizen.exe
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$form = New-Object System.Windows.Forms.Form
$form.Text = "Drag and Drop StarCitizen.exe"
$form.Width = 400
$form.Height = 200

$label = New-Object System.Windows.Forms.Label
$label.Text = "Drag and drop StarCitizen.exe here"
$label.Dock = [System.Windows.Forms.DockStyle]::Fill
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($label)

$form.AllowDrop = $true
$form.Add_DragEnter({$_.Effect = [System.Windows.Forms.DragDropEffects]::Copy})
$form.Add_DragDrop({
    param($sender, $e)
    $files = $e.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
    if ($files -and $files.Length -eq 1 -and (Get-Item $files[0]).Name -eq "StarCitizen.exe") {
        $path = $files[0]
        $label.Text = "File path: $path"
        $form.Close()
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please drag and drop the correct StarCitizen.exe file.")
    }
})

$form.ShowDialog()

# Check if the path is set
if (-not $path) {
    Write-Output "Operation cancelled by the user."
    exit
}

# Define the desired size in MB
$initialSize = 64000
$maximumSize = 64000

# Get the page file settings
$pagefile = Get-WmiObject -Query "SELECT * FROM Win32_PageFileSetting WHERE Name='C:\\pagefile.sys'"

# Check if the page file setting exists
if ($pagefile) {
    # Modify the existing page file settings
    $pagefile.InitialSize = $initialSize
    $pagefile.MaximumSize = $maximumSize
    $pagefile.Put()
    Write-Output "Paging file size updated successfully."
} else {
    # Create a new page file setting
    $newPagefile = ([WmiClass]"\\.\root\cimv2:Win32_PageFileSetting").CreateInstance()
    $newPagefile.Name = "C:\\pagefile.sys"
    $newPagefile.InitialSize = $initialSize
    $newPagefile.MaximumSize = $maximumSize
    $newPagefile.Put()
    Write-Output "Paging file size set successfully."
}

Write-Output "Paging file settings have been updated for the system."
