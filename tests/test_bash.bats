#!/usr/bin/env bats

dir_base="/av/data/repos/metashell"

setup() {
    # Ensure we run in a clean bash environment
    if [[ -n "$BASH_VERSION" ]]; then
        #echo "Not running in Bash"
        unset ZSH_VERSION
        export BASH_VERSION="$(bash --version | head -n 1)"
    fi
    av_var_shell="bash"
    source "${dir_base}/metashell.sh"
    METASHELL_FORBIDDEN_COMMANDS="forbidden_command"
    METASHELL_LOG_DIR="$BATS_TEST_TMPDIR/logs"
    mkdir -p "$METASHELL_LOG_DIR"
}

teardown() {
    av_fn_metashell_toggle disable
}

@test "Bash: enable hooks" {
    av_fn_metashell_toggle enable
    run ls
    [ "$status" -eq 0 ]
}

@test "Bash: forbidden command" {
    av_fn_metashell_toggle enable
    run forbidden_command
    # Expect command to fail/abort
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Aborting forbidden command" ]]
}

@test "Bash: per-command logging" {
    av_fn_metashell_toggle enable
    run echo "Hello"
    [ "$status" -eq 0 ]
    # Check logs directory for a newly created logfile
    logfile_count=$(ls "$METASHELL_LOG_DIR" | wc -l)
    [ "$logfile_count" -gt 0 ]
    # Optionally check if "Hello" is in one of the logs
    grep "Hello" "$METASHELL_LOG_DIR"/* || fail "Output not found in logs"
}

@test "Bash: command not found handling" {
    METASHELL_RERUN_COMMAND_NOT_FOUND=0
    av_fn_metashell_toggle enable
    run some_unknown_command
    [ "$status" -eq 127 ]
    [[ "$output" =~ "command not found" ]]
}
