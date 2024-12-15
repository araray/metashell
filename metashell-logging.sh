#!/usr/bin/env bash

# metashell-logging.sh
# Logging module

: "${METASHELL_LOG_DIR:=$HOME/metashell_logs}"
mkdir -p "$METASHELL_LOG_DIR"

# Store original file descriptors
exec {ORIG_STDOUT}>&1 {ORIG_STDERR}>&2

metashell_enable_logging() {
    local str_now log_file
    str_now="$(date +%Y-%m-%d_%H-%M-%S)"
    log_file="${METASHELL_LOG_DIR}/${str_now}.log"

    # Safely redirect stdout and stderr to tee
    exec > >(tee -a "$log_file") 2>&1

    # Optionally store the logfile path in a variable
    METASHELL_ACTIVE_LOGFILE="$log_file"

    echo "Logging enabled: output going to $METASHELL_ACTIVE_LOGFILE"
}

metashell_disable_logging() {
    # Restore original stdout/stderr
    exec 1>&${ORIG_STDOUT} 2>&${ORIG_STDERR}

    echo "Logging disabled. Output restored to terminal."
    unset METASHELL_ACTIVE_LOGFILE
}
