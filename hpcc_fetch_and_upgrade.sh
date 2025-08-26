#!/usr/bin/env bash

# Step 1: Fetch the releases from GitHub API
REPO="hpcc-systems/HPCC-Platform"
RELEASES_URL="https://api.github.com/repos/$REPO/releases?per_page=20&page=1"
echo "[INFO] Fetching releases from: $RELEASES_URL"
RELEASES_JSON=$(curl -s $RELEASES_URL)
echo "[INFO] API Response length: ${#RELEASES_JSON}"

# Step 2: Parse 'name' field to find relevant release names
echo "[INFO] List of all release names:"
all_tags=$(echo "$RELEASES_JSON" | grep '"name":' | grep -o '"hpccsystems-platform-community_[^"]*noble_amd64_withsymbols\.deb"' | sed -E 's/.*"([^"]+)".*/\1/')
echo "[INFO] Number of tags found: $(echo "$all_tags" | wc -l)"
echo "[DEBUG] Raw all_tags:"
echo "$all_tags"
echo "---"

# Step 3: Filter out release candidates (rc1, rc2, rc3, etc.) to get only gold releases
echo -e "\n[INFO] Filtering out release candidates..."
gold_releases=$(echo "$all_tags" | grep -v "rc[0-9]")
echo "[SUCCESS] Gold releases found:"
echo "$gold_releases"

# Step 4: Find the latest version by comparing version numbers
echo -e "\n[INFO] Finding latest gold release..."
latest_gold=""
highest_version=""

while IFS= read -r release; do
    if [ -n "$release" ]; then
        # Extract version number from the release name
        # Format: hpccsystems-platform-community_VERSION-REVISIONnoble_amd64_withsymbols.deb
        # Where REVISION can be 1, 2, 3, etc.
        version=$(echo "$release" | sed -E 's/hpccsystems-platform-community_([0-9]+\.[0-9]+\.[0-9]+-[0-9]+)noble_amd64_withsymbols\.deb/\1/')
        
        if [ -n "$version" ]; then
            echo "[DEBUG] Checking version: $version"
            
            # Compare versions using sort -V (version sort)
            if [ -z "$highest_version" ]; then
                highest_version="$version"
                latest_gold="$release"
            else
                # Check if current version is higher than stored highest
                # Convert versions to comparable format for sort -V
                higher=$(printf "%s\n%s" "$highest_version" "$version" | sort -V | tail -n1)
                if [ "$higher" = "$version" ] && [ "$version" != "$highest_version" ]; then
                    highest_version="$version"
                    latest_gold="$release"
                fi
            fi
        fi
    fi
done <<< "$gold_releases"

echo -e "\n[SUCCESS] Latest gold release:"
echo "[INFO] Release: $latest_gold"
echo "[INFO] Version: $highest_version"

# Step 5: Compare with existing releases in parent directory
echo -e "\n[INFO] Checking parent directory for existing releases..."
parent_dir="/home/innovate/"
existing_releases=$(find "$parent_dir" -name "hpccsystems-platform-community_*noble_amd64_withsymbols.deb" -type f 2>/dev/null | xargs -I {} basename {})

if [ -z "$existing_releases" ]; then
    echo "[WARNING] No existing HPCC releases found in parent directory."
    echo "[INFO] Latest gold release ($latest_gold) is new and should be downloaded."
else
    echo "[SUCCESS] Existing releases found in parent directory:"
    echo "$existing_releases"
    
    # Check if latest gold release already exists
    if echo "$existing_releases" | grep -q "^$latest_gold$"; then
        echo -e "\n[SUCCESS] Latest gold release ($latest_gold) already exists in parent directory."
        echo "[INFO] No download needed."
    else
        echo -e "\n[INFO] Latest gold release ($latest_gold) not found in parent directory."
        
        # Find the latest version among existing releases
        echo "[INFO] Comparing with existing versions..."
        latest_existing=""
        latest_existing_version=""
        
        while IFS= read -r existing_release; do
            if [ -n "$existing_release" ]; then
                # Filter out release candidates from existing releases too
                if ! echo "$existing_release" | grep -q "rc[0-9]"; then
                    existing_version=$(echo "$existing_release" | sed -E 's/hpccsystems-platform-community_([0-9]+\.[0-9]+\.[0-9]+-[0-9]+)noble_amd64_withsymbols\.deb/\1/')
                    
                    if [ -n "$existing_version" ]; then
                        if [ -z "$latest_existing_version" ]; then
                            latest_existing_version="$existing_version"
                            latest_existing="$existing_release"
                        else
                            # Compare versions including revision numbers using sort -V
                            higher_existing=$(printf "%s\n%s" "$latest_existing_version" "$existing_version" | sort -V | tail -n1)
                            if [ "$higher_existing" = "$existing_version" ] && [ "$existing_version" != "$latest_existing_version" ]; then
                                latest_existing_version="$existing_version"
                                latest_existing="$existing_release"
                            fi
                        fi
                    fi
                fi
            fi
        done <<< "$existing_releases"
        
        if [ -n "$latest_existing_version" ]; then
            echo "[INFO] Latest existing version: $latest_existing_version ($latest_existing)"
            echo "[INFO] Latest available version: $highest_version ($latest_gold)"
            
            # Compare the versions
            comparison=$(printf "%s\n%s" "$latest_existing_version" "$highest_version" | sort -V | tail -n1)
            
            if [ "$comparison" = "$highest_version" ] && [ "$highest_version" != "$latest_existing_version" ]; then
                echo -e "\n[SUCCESS] Found newer version! Latest gold release is newer than existing releases."
                echo "[INFO] Recommendation: Download $latest_gold"
                
                # Call hpcc_fetch.sh to download the newer version
                echo -e "\n[INFO] Calling hpcc_fetch to download the latest version..."
                echo "[INFO] Executing: hpcc_fetch \"$highest_version\""
                hpcc_fetch "$highest_version"
                fetch_result=$?
                
                if [ $fetch_result -eq 0 ]; then
                    echo -e "\n[SUCCESS] Successfully downloaded $latest_gold"
                    
                    # Delete the oldest release version file
                    echo -e "\n[INFO] Finding oldest release to delete..."
                    oldest_release=""
                    oldest_version=""
                    
                    while IFS= read -r existing_release; do
                        if [ -n "$existing_release" ]; then
                            # Filter out release candidates from existing releases
                            if ! echo "$existing_release" | grep -q "rc[0-9]"; then
                                existing_version=$(echo "$existing_release" | sed -E 's/hpccsystems-platform-community_([0-9]+\.[0-9]+\.[0-9]+-[0-9]+)noble_amd64_withsymbols\.deb/\1/')
                                
                                if [ -n "$existing_version" ]; then
                                    if [ -z "$oldest_version" ]; then
                                        oldest_version="$existing_version"
                                        oldest_release="$existing_release"
                                    else
                                        # Compare versions to find the oldest (smallest)
                                        older=$(printf "%s\n%s" "$oldest_version" "$existing_version" | sort -V | head -n1)
                                        if [ "$older" = "$existing_version" ] && [ "$existing_version" != "$oldest_version" ]; then
                                            oldest_version="$existing_version"
                                            oldest_release="$existing_release"
                                        fi
                                    fi
                                fi
                            fi
                        fi
                    done <<< "$existing_releases"
                    
                    if [ -n "$oldest_release" ] && [ "$oldest_release" != "$latest_gold" ]; then
                        echo "[INFO] Oldest release found: $oldest_release (version: $oldest_version)"
                        
                        # Count current files in directory (including the new one just downloaded)
                        current_file_count=$(find "$parent_dir" -name "hpccsystems-platform-community_*noble_amd64_withsymbols.deb" -type f 2>/dev/null | wc -l)
                        echo "[INFO] Current file count in directory: $current_file_count"
                        
                        if [ "$current_file_count" -ge 4 ]; then
                            echo "[INFO] Deleting: $parent_dir$oldest_release (keeping at least 3 files)"
                            if rm "$parent_dir$oldest_release" 2>/dev/null; then
                                echo -e "[SUCCESS] Successfully deleted oldest release: $oldest_release"
                            
                            # Run hpcc_upgrade with the new version
                            echo -e "\n[INFO] Running hpcc_upgrade with new version..."
                            echo "[INFO] Executing: hpcc_upgrade \"$latest_gold\""
                            hpcc_upgrade "$latest_gold"
                            upgrade_result=$?
                            
                            if [ $upgrade_result -eq 0 ]; then
                                echo -e "[SUCCESS] Successfully upgraded to HPCC version $highest_version"
                            else
                                echo -e "[ERROR] Failed to upgrade HPCC (exit code: $upgrade_result)"
                            fi
                        else
                            echo -e "[ERROR] Failed to delete oldest release: $oldest_release"
                        fi
                    else
                        echo "[INFO] Not deleting oldest release. Current file count ($current_file_count) is less than 4. Keeping all files to maintain at least 3 releases."
                        
                        # Still run hpcc_upgrade even if no deletion was needed
                        echo -e "\n[INFO] Running hpcc_upgrade with new version..."
                        echo "[INFO] Executing: hpcc_upgrade \"$latest_gold\""
                        hpcc_upgrade "$latest_gold"
                        upgrade_result=$?
                        
                        if [ $upgrade_result -eq 0 ]; then
                            echo -e "[SUCCESS] Successfully upgraded to HPCC version $highest_version"
                        else
                            echo -e "[ERROR] Failed to upgrade HPCC (exit code: $upgrade_result)"
                        fi
                    fi
                    else
                        echo "[INFO] No older release found to delete."
                        
                        # Still run hpcc_upgrade even if no deletion was needed
                        echo -e "\n[INFO] Running hpcc_upgrade with new version..."
                        echo "[INFO] Executing: hpcc_upgrade \"$latest_gold\""
                        hpcc_upgrade "$latest_gold"
                        upgrade_result=$?
                        
                        if [ $upgrade_result -eq 0 ]; then
                            echo -e "[SUCCESS] Successfully upgraded to HPCC version $highest_version"
                        else
                            echo -e "[ERROR] Failed to upgrade HPCC (exit code: $upgrade_result)"
                        fi
                    fi
                else
                    echo -e "\n[ERROR] Failed to download $latest_gold (exit code: $fetch_result)"
                fi
            elif [ "$highest_version" = "$latest_existing_version" ]; then
                echo -e "\n[SUCCESS] Versions are the same. No update needed."
            else
                echo -e "\n[WARNING] Existing version is newer than the latest gold release found."
                echo "[INFO] This might indicate the API didn't return the most recent releases."
            fi
        else
            echo "[ERROR] No valid existing gold releases found for comparison."
            echo "[INFO] Recommendation: Download $latest_gold"
            
            # Call hpcc_fetch to download since no existing releases found
            echo -e "\n[INFO] No existing releases found. Calling hpcc_fetch to download the latest version..."
            echo "[INFO] Executing: hpcc_fetch \"$highest_version\""
            hpcc_fetch "$highest_version"
            fetch_result=$?
            
            if [ $fetch_result -eq 0 ]; then
                echo -e "\n[SUCCESS] Successfully downloaded $latest_gold"
                
                # Delete the oldest release version file
                echo -e "\n[INFO] Finding oldest release to delete..."
                oldest_release=""
                oldest_version=""
                
                while IFS= read -r existing_release; do
                    if [ -n "$existing_release" ]; then
                        # Filter out release candidates from existing releases
                        if ! echo "$existing_release" | grep -q "rc[0-9]"; then
                            existing_version=$(echo "$existing_release" | sed -E 's/hpccsystems-platform-community_([0-9]+\.[0-9]+\.[0-9]+-[0-9]+)noble_amd64_withsymbols\.deb/\1/')
                            
                            if [ -n "$existing_version" ]; then
                                if [ -z "$oldest_version" ]; then
                                    oldest_version="$existing_version"
                                    oldest_release="$existing_release"
                                else
                                    # Compare versions to find the oldest (smallest)
                                    older=$(printf "%s\n%s" "$oldest_version" "$existing_version" | sort -V | head -n1)
                                    if [ "$older" = "$existing_version" ] && [ "$existing_version" != "$oldest_version" ]; then
                                        oldest_version="$existing_version"
                                        oldest_release="$existing_release"
                                    fi
                                fi
                            fi
                        fi
                    fi
                done <<< "$existing_releases"
                
                if [ -n "$oldest_release" ] && [ "$oldest_release" != "$latest_gold" ]; then
                    echo "[INFO] Oldest release found: $oldest_release (version: $oldest_version)"
                    
                    # Count current files in directory (including the new one just downloaded)
                    current_file_count=$(find "$parent_dir" -name "hpccsystems-platform-community_*noble_amd64_withsymbols.deb" -type f 2>/dev/null | wc -l)
                    echo "[INFO] Current file count in directory: $current_file_count"
                    
                    if [ "$current_file_count" -ge 4 ]; then
                        echo "[INFO] Deleting: $parent_dir$oldest_release (keeping at least 3 files)"
                        if rm "$parent_dir$oldest_release" 2>/dev/null; then
                            echo -e "[SUCCESS] Successfully deleted oldest release: $oldest_release"
                        
                        # Run hpcc_upgrade with the new version
                        echo -e "\n[INFO] Running hpcc_upgrade with new version..."
                        echo "[INFO] Executing: hpcc_upgrade \"$latest_gold\""
                        hpcc_upgrade "$latest_gold"
                        upgrade_result=$?
                        
                        if [ $upgrade_result -eq 0 ]; then
                            echo -e "[SUCCESS] Successfully upgraded to HPCC version $highest_version"
                        else
                            echo -e "[ERROR] Failed to upgrade HPCC (exit code: $upgrade_result)"
                        fi
                    else
                        echo -e "[ERROR] Failed to delete oldest release: $oldest_release"
                    fi
                else
                    echo "[INFO] Not deleting oldest release. Current file count ($current_file_count) is less than 4. Keeping all files to maintain at least 3 releases."
                    
                    # Still run hpcc_upgrade even if no deletion was needed
                    echo -e "\n[INFO] Running hpcc_upgrade with new version..."
                    echo "[INFO] Executing: hpcc_upgrade \"$latest_gold\""
                    hpcc_upgrade "$latest_gold"
                    upgrade_result=$?
                    
                    if [ $upgrade_result -eq 0 ]; then
                        echo -e "[SUCCESS] Successfully upgraded to HPCC version $highest_version"
                    else
                        echo -e "[ERROR] Failed to upgrade HPCC (exit code: $upgrade_result)"
                    fi
                fi
                else
                    echo "[INFO] No older release found to delete."
                    
                    # Still run hpcc_upgrade even if no deletion was needed
                    echo -e "\n[INFO] Running hpcc_upgrade with new version..."
                    echo "[INFO] Executing: hpcc_upgrade \"$latest_gold\""
                    hpcc_upgrade "$latest_gold"
                    upgrade_result=$?
                    
                    if [ $upgrade_result -eq 0 ]; then
                        echo -e "[SUCCESS] Successfully upgraded to HPCC version $highest_version"
                    else
                        echo -e "[ERROR] Failed to upgrade HPCC (exit code: $upgrade_result)"
                    fi
                fi
            else
                echo -e "\n[ERROR] Failed to download $latest_gold (exit code: $fetch_result)"
            fi
        fi
    fi
fi

# Step 6: Handle case when no existing releases found in parent directory
if [ -z "$existing_releases" ]; then
    # Call hpcc_fetch to download since no existing releases found
    echo -e "\n[INFO] Calling hpcc_fetch to download the latest version..."
    echo "[INFO] Executing: hpcc_fetch \"$highest_version\""
    hpcc_fetch "$highest_version"
    fetch_result=$?
    
    if [ $fetch_result -eq 0 ]; then
        echo -e "\n[SUCCESS] Successfully downloaded $latest_gold"

        # Delete the oldest release version file
        echo -e "\n[INFO] Finding oldest release to delete..."
        oldest_release=""
        oldest_version=""
        
        while IFS= read -r existing_release; do
            if [ -n "$existing_release" ]; then
                # Filter out release candidates from existing releases
                if ! echo "$existing_release" | grep -q "rc[0-9]"; then
                    existing_version=$(echo "$existing_release" | sed -E 's/hpccsystems-platform-community_([0-9]+\.[0-9]+\.[0-9]+-[0-9]+)noble_amd64_withsymbols\.deb/\1/')
                    
                    if [ -n "$existing_version" ]; then
                        if [ -z "$oldest_version" ]; then
                            oldest_version="$existing_version"
                            oldest_release="$existing_release"
                        else
                            # Compare versions to find the oldest (smallest)
                            older=$(printf "%s\n%s" "$oldest_version" "$existing_version" | sort -V | head -n1)
                            if [ "$older" = "$existing_version" ] && [ "$existing_version" != "$oldest_version" ]; then
                                oldest_version="$existing_version"
                                oldest_release="$existing_release"
                            fi
                        fi
                    fi
                fi
            fi
        done <<< "$existing_releases"
        
        if [ -n "$oldest_release" ] && [ "$oldest_release" != "$latest_gold" ]; then
            echo "[INFO] Oldest release found: $oldest_release (version: $oldest_version)"
            
            # Count current files in directory (including the new one just downloaded)
            current_file_count=$(find "$parent_dir" -name "hpccsystems-platform-community_*noble_amd64_withsymbols.deb" -type f 2>/dev/null | wc -l)
            echo "[INFO] Current file count in directory: $current_file_count"
            
            if [ "$current_file_count" -ge 4 ]; then
                echo "[INFO] Deleting: $parent_dir$oldest_release (keeping at least 3 files)"
                if rm "$parent_dir$oldest_release" 2>/dev/null; then
                    echo -e "[SUCCESS] Successfully deleted oldest release: $oldest_release"
                
                # Run hpcc_upgrade with the new version
                echo -e "\n[INFO] Running hpcc_upgrade with new version..."
                echo "[INFO] Executing: hpcc_upgrade \"$latest_gold\""
                hpcc_upgrade "$latest_gold"
                upgrade_result=$?
                
                if [ $upgrade_result -eq 0 ]; then
                    echo -e "[SUCCESS] Successfully upgraded to HPCC version $highest_version"
                else
                    echo -e "[ERROR] Failed to upgrade HPCC (exit code: $upgrade_result)"
                fi
            else
                echo -e "[ERROR] Failed to delete oldest release: $oldest_release"
            fi
        else
            echo "[INFO] Not deleting oldest release. Current file count ($current_file_count) is less than 4. Keeping all files to maintain at least 3 releases."
            
            # Still run hpcc_upgrade even if no deletion was needed
            echo -e "\n[INFO] Running hpcc_upgrade with new version..."
            echo "[INFO] Executing: hpcc_upgrade \"$latest_gold\""
            hpcc_upgrade "$latest_gold"
            upgrade_result=$?
            
            if [ $upgrade_result -eq 0 ]; then
                echo -e "[SUCCESS] Successfully upgraded to HPCC version $highest_version"
            else
                echo -e "[ERROR] Failed to upgrade HPCC (exit code: $upgrade_result)"
            fi
        fi
        else
            echo "[INFO] No older release found to delete."
            
            # Still run hpcc_upgrade even if no deletion was needed
            echo -e "\n[INFO] Running hpcc_upgrade with new version..."
            echo "[INFO] Executing: hpcc_upgrade \"$latest_gold\""
            hpcc_upgrade "$latest_gold"
            upgrade_result=$?
            
            if [ $upgrade_result -eq 0 ]; then
                echo -e "[SUCCESS] Successfully upgraded to HPCC version $highest_version"
            else
                echo -e "[ERROR] Failed to upgrade HPCC (exit code: $upgrade_result)"
            fi
        fi
    else
        echo -e "\n[ERROR] Failed to download $latest_gold (exit code: $fetch_result)"
    fi
fi
