#!/usr/bin/env bash

# metashell-cnf.sh

: "${METASHELL_RERUN_COMMAND_NOT_FOUND:=0}"

metashell_handle_command_not_found() {
    local cmd="$1"
    echo "The command '$cmd' was not found."
    if [ "$METASHELL_RERUN_COMMAND_NOT_FOUND" -eq 1 ]; then
        echo "Attempting to rerun '$cmd' after handling..."
        return 0
    else
        echo "Not attempting to rerun '$cmd'."
        return 1
    fi
}

# Zsh: define command_not_found_handler
# Bash: define command_not_found_handle
metashell_zsh_cnf_enable() {
    # Zsh uses command_not_found_handler
    command_not_found_handler() {
        zsh_command_not_found_handler "$@"
    }
}

metashell_bash_cnf_enable() {
    # Bash uses command_not_found_handle
    command_not_found_handle() {
        local cmd="$1"
        local ret
        if (( ! IN_CNFH++ )) && metashell_handle_command_not_found "$cmd"; then
            "$@"
            ret=$?
        else
            printf >&2 '%s: %s: command not found\n' "$BASH_ARGV0" "$cmd"
            ret=127
        fi
        (( IN_CNFH-- ))
        return "$ret"
    }
}
