#!/bin/bash

# Set the working directory to the directory where the script is located
scriptPath="$(realpath "$0")"
scriptDirectory="$(dirname "$scriptPath")"
cd "$scriptDirectory" || exit

# Define the URL to check the latest WordPress version
wordpressVersionUrl="https://api.wordpress.org/core/version-check/1.7/"

# Define the file paths
versionFile="wordpress-version.txt"
downloadFileName="wordpress.zip"
locale="en_GB"
subDomain="en-gb"
downloadUrlStub="https://$subDomain.wordpress.org/wordpress-"
destinationDir="wordpress-latest"

# Check if the version file exists
if [ -f "$versionFile" ]; then
    # Read the currently saved WordPress version
    currentVersion=$(cat "$versionFile")
else
    # Set the current version to an empty string if the file doesn't exist
    currentVersion=""
fi

# Query the WordPress API to get the latest version
response=$(curl -s "$wordpressVersionUrl")

# Extract the latest version from the JSON response
latestVersion=$(echo "$response" | jq -r '.offers | sort_by(.version) | last | .version')

# Check if the latest version is different from the current version
if [ "$latestVersion" != "$currentVersion" ]; then
    # Construct the download URL
    downloadUrl="${downloadUrlStub}${latestVersion}-${locale}.zip"

    echo "There is a new WordPress version available ($latestVersion)"

    # Download the latest WordPress version
    echo "Downloading version $latestVersion from $downloadUrl"
    if curl -o "$downloadFileName" "$downloadUrl"; then
        echo "Downloaded version $latestVersion"

        # Extract the downloaded WordPress zip
        if unzip "$downloadFileName" -d .; then
            echo "Extracted version $latestVersion"

            # Archive the old WordPress installation
            if [ -d "$destinationDir" ]; then
                if [ -n "$currentVersion" ]; then
                    mv "$destinationDir" "wordpress-$currentVersion"
                    echo "Archived version $currentVersion"
                fi
            fi

            # Rename the new WordPress to the path of the old one
            if mv wordpress "$destinationDir"; then
                echo "Renamed new WordPress directory"

                # Remove Akismet & Hello Dolly
                rm -rf "${destinationDir}/wp-content/plugins/akismet"
                rm -f "${destinationDir}/wp-content/plugins/hello.php"
                echo "Default plugins removed"

                # Remove default themes
                rm -rf "${destinationDir}/wp-content/themes/"*
                echo "Default themes removed"

                # Save the latest version to the version file
                echo "$latestVersion" > "$versionFile"

                # Clean up: Remove the downloaded zip
                rm -f "$downloadFileName"
                echo "WordPress updated to version $latestVersion"
            else
                echo "Failed to rename the new WordPress directory"
            fi
        else
            echo "Failed to extract the downloaded version"
        fi
    else
        echo "Failed to download version $latestVersion"
    fi
else
    echo "WordPress is already up to date (version $latestVersion)"
fi
