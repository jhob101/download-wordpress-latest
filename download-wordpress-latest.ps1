# Set the working directory to the directory where the script is located
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path $scriptPath -Parent
Set-Location -Path $scriptDirectory

# Define the URL to check the latest WordPress version
$wordpressVersionUrl = "https://api.wordpress.org/core/version-check/1.7/"

# Define the file paths
$versionFile = "wordpress-version.txt"
$downloadFileName = "wordpress.zip"
$locale = "en_GB"
$subDomain = "en-gb"
$downloadUrlStub = "https://$subDomain.wordpress.org/wordpress-"
$destinationDir = ".\wordpress-latest"

# Check if the version file exists
if (Test-Path $versionFile) {
    # Read the currently saved WordPress version
    $currentVersion = Get-Content $versionFile
} else {
    # Set the current version to an empty string if the file doesn't exist
    $currentVersion = ""
}

# Query the WordPress API to get the latest version
$response = Invoke-RestMethod -Uri $wordpressVersionUrl

# Extract the latest version from the JSON response
$latestVersion = $response.offers | Sort-Object -Property version -Descending | Select-Object -First 1 | Select-Object -ExpandProperty version

# Check if the latest version is different from the current version
if ($latestVersion -ne $currentVersion) {
    # Construct the download URL
    $downloadUrl = "$downloadUrlStub$latestVersion-$locale.zip"

    Write-Host "There is a new WordPress version available ($latestVersion)"

    # Download the latest WordPress version
    Write-Host "Downloading version $latestVersion from $downloadUrl"
    $downloaded = $false
    try {
        Invoke-WebRequest $downloadUrl -OutFile $downloadFileName
        $downloaded = $true
    } catch {
        Write-Host "Failed to download version $latestVersion"
    }

    if ($downloaded) {
        # Extract the downloaded WordPress zip
        $extracted = $false
        try {
            Expand-Archive -Path $downloadFileName -DestinationPath .
            Write-Host "Downloaded & extracted version $latestVersion"
            $extracted = $true
        } catch {
            Write-Host "Failed to extract the downloaded version"
        }

        if ($extracted) {
            # Archive the old WordPress installation
            $removed = $false
            try {
                if ($currentVersion -ne "") {
                    #Remove-Item -Path $destinationDir -Force -Recurse
                    Rename-Item -Path $destinationDir -NewName "wordpress-$currentVersion"
                }
                Write-Host "Archived version $currentVersion"
                $removed = $true
            } catch {
                Write-Host "Failed to archive version $currentVersion"
            }

            if ($removed) {
                # Rename the new WordPress to the path of the old one
                $renamed = $false
                try {                    
                    Rename-Item -Path .\wordpress -NewName wordpress-latest

                    # Remove Akismet & Hello Dolly
                    try {
                        Remove-Item -Path ".\wordpress-latest\wp-content\plugins\akismet" -Force -Recurse
                        Remove-Item -Path ".\wordpress-latest\wp-content\plugins\hello.php" -Force
                        Write-Host "Default plugins removed"
                    } catch {
                        Write-Host "Failed to remove default plugins"
                    }

                    # Remove default themes
                    try {
                        $directoryToClean = ".\wordpress-latest\wp-content\themes\"

                        # Get a list of directories in the specified path
                        $directories = Get-ChildItem -Path $directoryToClean -Directory

                        # Loop through the directories and remove them
                        foreach ($dir in $directories) {
                            Remove-Item -Path $dir.FullName -Recurse -Force
                        }

                        # Output a message indicating the cleanup is complete
                        Write-Host "Default themes removed"
                    } catch {
                        Write-Host "Failed to remove default themes"
                    }
                    $renamed = $true
                } catch {
                    Write-Host "Failed to rename the new WordPress directory"
                }

                if ($renamed) {
                    # Save the latest version to the version file
                    Set-Content -Path $versionFile -Value $latestVersion

                    # Clean up: Remove the downloaded zip
                    Remove-Item -Path $downloadFileName -Force
                    Write-Host "WordPress updated to version $latestVersion"
                }
            }
        }
    }
} else {
    Write-Host "WordPress is already up to date (version $latestVersion)"
}
