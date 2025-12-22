#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# === CONFIG ===
BUILD_DIR="build"
OUTPUT_FILE="$BUILD_DIR/nepali-calendar.plasmoid"
SOURCE_DIR="package"
LOG_FILE="/tmp/$(basename "$0").log"

# === COLORS ===
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# === LOGGING ===
log() {
    local level="$1"
    local message="$2"

    local color="$NC"
    case "$level" in
        INFO) color="$BLUE" ;;
        SUCCESS) color="$GREEN" ;;
        WARNING) color="$YELLOW" ;;
        ERROR) color="$RED" ;;
    esac

    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] ${color}${level}:${NC} $message" | tee -a "$LOG_FILE"
}

# === CLEANUP AND ERROR HANDLING ===
cleanup() {
    log INFO "Performing cleanup before exit..."
}

error_handler() {
    local exit_code=$?
    local line=$1
    log ERROR "Error on or near line $line (exit code: $exit_code)."
    cleanup
    exit "$exit_code"
}

trap 'error_handler $LINENO' ERR
trap cleanup EXIT INT TERM

# === DEPENDENCY CHECK ===
check_dependencies() {
    local missing=0
    for cmd in zip; do
        if ! command -v "$cmd" &>/dev/null; then
            log ERROR "Required command '$cmd' not found in PATH."
            missing=1
        fi
    done

    if [[ $missing -eq 1 ]]; then
        log ERROR "Please install missing dependencies and retry."
        exit 1
    fi
}

# === MAIN BUILD LOGIC ===
main() {
    log INFO "Starting build process..."
    check_dependencies

    if [[ ! -d "$SOURCE_DIR" ]]; then
        log ERROR "Source directory '$SOURCE_DIR' does not exist."
        exit 1
    fi

    if [[ -d "$BUILD_DIR" ]]; then
        log WARNING "Removing existing build directory..."
        rm -rf "$BUILD_DIR"
    fi
    mkdir -p "$BUILD_DIR"

    log INFO "Creating plasmoid package..."
    zip -rq "$OUTPUT_FILE" "$SOURCE_DIR"

    log SUCCESS "Build successful. Output: $OUTPUT_FILE"
}

main "$@"
