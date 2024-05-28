Add-Type -AssemblyName PresentationFramework

function Show-MessageBox {
    param (
        [string]$message,
        [string]$title = "Information"
    )
    [System.Windows.MessageBox]::Show($message, $title)
}

# Step 1: Check if StarCitizen.exe path is stored, if not, prompt user to drag and drop
$starCitizenPath = Get-Content -Path "C:\path\to\starCitizenPath.txt" -ErrorAction SilentlyContinue
if (-not $starCitizenPath) {
    Show-MessageBox -message "StarCitizen.exe path not found. Please drag and drop StarCitizen.exe from the directory 'C:\Program Files\Roberts Space Industries\StarCitizen\HOTFIX\Bin64\'." -title "StarCitizen.exe Path Not Found"
    exit
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

Write-Output "All operations completed successfully."
