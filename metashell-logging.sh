# Logging module

: "${METASHELL_LOG_DIR:=$HOME/metashell_logs}"
mkdir -p "$METASHELL_LOG_DIR"

# Store original file descriptors once
if [ -z "${ORIG_STDOUT}" ]; then
    exec {ORIG_STDOUT}>&1 {ORIG_STDERR}>&2
fi

# Setup per-command logging. Called by preexec hooks.
metashell_start_command_logging() {
    local timestamp cmd logfile
    timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
    cmd="$1"
    # Sanitize command for filename (replace spaces with underscores)
    local safe_cmd="${cmd// /_}"
    logfile="${METASHELL_LOG_DIR}/${timestamp}_${safe_cmd}_$$.log"

    # Restore original FDs before redirecting again (in case already redirected)
    exec >&${ORIG_STDOUT} 2>&${ORIG_STDERR}

    # Now redirect to new logfile
    exec > >(tee -a "$logfile") 2>&1
    export METASHELL_CURRENT_CMD_LOGFILE="$logfile"
}

# Stop per-command logging. Called by postexec hooks.
metashell_stop_command_logging() {
    # Restore original stdout/stderr
    exec >&${ORIG_STDOUT} 2>&${ORIG_STDERR}
    unset METASHELL_CURRENT_CMD_LOGFILE
}
