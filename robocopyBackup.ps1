# Ensure the script execution policy is set to RemoteSigned
function Set-ExecutionPolicyIfNeeded {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser

    if ($currentPolicy -ne 'RemoteSigned') {
        Write-Host "The current execution policy is $currentPolicy. Changing it to RemoteSigned for the current user..." -ForegroundColor Yellow
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "Execution policy set to RemoteSigned for the current user." -ForegroundColor Green
    }
}

# Function to display the warning if moving files
function Show-Warning {
    [CmdletBinding()]
    param ()

    Write-Host "WARNING: Ensure that any software related to the files being moved is closed before proceeding." -ForegroundColor Yellow
    Write-Host "Moving files while the software is open may cause issues."
    Write-Host "Press [Enter] to continue, or [Ctrl] + [C] to cancel." -ForegroundColor Yellow
    Read-Host
}

# Function to perform the Robocopy operation
function Invoke-FileOperation {
    param (
        [string]$Source,
        [string]$Destination,
        [string]$Operation
    )

    # Build the robocopy command based on user selection
    if ($Operation -eq "Move") {
        Show-Warning
        robocopy "$Source" "$Destination" /sec /move /e
    } elseif ($Operation -eq "Copy") {
        robocopy "$Source" "$Destination" /sec /e
    } else {
        Write-Host "Invalid operation selected." -ForegroundColor Red
        return
    }

    Write-Host "Operation completed." -ForegroundColor Green
}

# Main script flow
Clear-Host

# Set the execution policy to RemoteSigned if needed
Set-ExecutionPolicyIfNeeded

# Get the source directory from the user
$sourcePath = Read-Host "Please enter the full source path (e.g., C:\SourceFolder)"

# Check if source exists
if (-not (Test-Path $sourcePath)) {
    Write-Host "Source path does not exist. Exiting..." -ForegroundColor Red
    exit
}

# Get the destination directory from the user
$destPath = Read-Host "Please enter the full destination path (e.g., D:\DestinationFolder)"

# Ask the user if they want to move or copy
$operation = Read-Host "Do you want to 'Move' or 'Copy' the files? Type 'Move' or 'Copy'"

# Validate the input for Move or Copy
if ($operation -ne "Move" -and $operation -ne "Copy") {
    Write-Host "Invalid operation. Please type either 'Move' or 'Copy'." -ForegroundColor Red
    exit
}

# Confirm operation
$confirmation = Read-Host "You are about to $operation files from '$sourcePath' to '$destPath'. Continue? (Y/N)"

if ($confirmation -ne 'Y') {
    Write-Host "Operation canceled." -ForegroundColor Yellow
    exit
}

# Perform the operation based on the user's input
Invoke-FileOperation -Source $sourcePath -Destination $destPath -Operation $operation
