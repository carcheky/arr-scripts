#!/bin/bash

# Repository Reference Checker and Updater
# This script checks for references to the original repository and can update them to the current repository

ORIGINAL_REPO="carcheky/arr-scripts"
CURRENT_REPO="carcheky/arr-scripts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check for references
check_references() {
    print_color $BLUE "=== Repository Reference Checker ==="
    print_color $YELLOW "Searching for references to: $ORIGINAL_REPO"
    print_color $YELLOW "Current repository: $CURRENT_REPO"
    echo ""
    
    local total_files=0
    local files_with_refs=0
    local total_refs=0
    
    print_color $BLUE "Files containing references to $ORIGINAL_REPO:"
    echo ""
    
    # Search for references
    for file in $(find . -type f \( -name "*.md" -o -name "*.txt" -o -name "*.sh" -o -name "*.bash" -o -name "*.py" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.conf" \) 2>/dev/null | grep -v ".repo_reference_backup"); do
        ((total_files++))
        local ref_count=$(grep -c "$ORIGINAL_REPO" "$file" 2>/dev/null || echo "0")
        if [[ "$ref_count" -gt 0 ]] 2>/dev/null; then
            ((files_with_refs++))
            ((total_refs += ref_count))
            print_color $RED "  $file ($ref_count references)"
            
            # Show the actual lines with references
            grep -n "$ORIGINAL_REPO" "$file" 2>/dev/null | while IFS= read -r line; do
                echo "    $line"
            done
            echo ""
        fi
    done
    
    print_color $BLUE "=== Summary ==="
    echo "Total files scanned: $total_files"
    echo "Files with references: $files_with_refs"
    echo "Total references found: $total_refs"
    echo ""
    
    if [ "$files_with_refs" -gt 0 ]; then
        print_color $YELLOW "Run with --fix to automatically update these references"
        print_color $YELLOW "Note: Image URLs to other repositories will NOT be changed"
        return 1
    else
        print_color $GREEN "No references to the original repository found!"
        return 0
    fi
}

# Function to fix references
fix_references() {
    print_color $BLUE "=== Fixing Repository References ==="
    print_color $YELLOW "Updating $ORIGINAL_REPO -> $CURRENT_REPO"
    echo ""
    
    local files_updated=0
    local total_replacements=0
    
    # Create backup directory
    local backup_dir=".repo_reference_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    print_color $BLUE "Created backup directory: $backup_dir"
    echo ""
    
    # Find and fix references
    for file in $(find . -type f \( -name "*.md" -o -name "*.txt" -o -name "*.sh" -o -name "*.bash" -o -name "*.py" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.conf" \) 2>/dev/null | grep -v ".repo_reference_backup"); do
        local ref_count=$(grep -c "$ORIGINAL_REPO" "$file" 2>/dev/null || echo "0")
        if [[ "$ref_count" -gt 0 ]] 2>/dev/null; then
            # Create backup
            cp "$file" "$backup_dir/$(basename "$file").backup"
            
            # Create a temporary file for selective replacement
            local temp_file=$(mktemp)
            
            # Process line by line to avoid replacing image URLs to other repos
            while IFS= read -r line; do
                # Skip lines that contain image URLs to other repositories 
                if [[ "$line" =~ "unraid-templates" ]] || [[ "$line" =~ "docker-lidarr-extended" ]] || [[ "$line" =~ "docker-amtd" ]]; then
                    echo "$line" >> "$temp_file"
                else
                    # Replace in this line
                    echo "${line//$ORIGINAL_REPO/$CURRENT_REPO}" >> "$temp_file"
                fi
            done < "$file"
            
            # Count actual replacements made
            local new_ref_count=$(grep -c "$ORIGINAL_REPO" "$temp_file" 2>/dev/null || echo "0")
            local replacements_made=0
            if [[ "$ref_count" =~ ^[0-9]+$ ]] && [[ "$new_ref_count" =~ ^[0-9]+$ ]]; then
                replacements_made=$((ref_count - new_ref_count))
            fi
            
            if [ "$replacements_made" -gt 0 ]; then
                mv "$temp_file" "$file"
                ((files_updated++))
                ((total_replacements += replacements_made))
                print_color $GREEN "Updated: $file ($replacements_made replacements)"
            else
                rm "$temp_file"
                print_color $YELLOW "Skipped: $file (only image URLs found)"
            fi
        fi
    done
    
    echo ""
    print_color $BLUE "=== Fix Summary ==="
    echo "Files updated: $files_updated"
    echo "Total replacements: $total_replacements"
    echo "Backups stored in: $backup_dir"
    echo ""
    
    if [ "$files_updated" -gt 0 ]; then
        print_color $YELLOW "Please review the changes and test before committing!"
        print_color $YELLOW "You can restore from backups if needed."
    else
        print_color $GREEN "No files needed updating (only image URLs were found)."
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [--fix] [--help]"
    echo ""
    echo "  (no args)  Check for repository references"
    echo "  --fix      Fix repository references automatically"
    echo "  --help     Show this help message"
    echo ""
    echo "This script helps identify and fix references to the original repository"
    echo "($ORIGINAL_REPO) and update them to point to the current repository"
    echo "($CURRENT_REPO)."
}

# Main script logic
case "${1:-}" in
    --fix)
        check_references
        if [ $? -eq 1 ]; then
            echo ""
            read -p "Do you want to proceed with fixing these references? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                fix_references
            else
                print_color $YELLOW "Fix cancelled by user."
            fi
        fi
        ;;
    --help)
        show_usage
        ;;
    "")
        check_references
        ;;
    *)
        print_color $RED "Unknown option: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac