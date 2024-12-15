#!/usr/bin/env bash

# metashell-bash-hooks.sh

: "${METASHELL_MERGE_PROMPT:=0}"
: "${METASHELL_FORBIDDEN_COMMANDS:=forbidden_command}"

# Store original values to restore later
ORIG_PROMPT_COMMAND="$PROMPT_COMMAND"
ORIG_DEBUG_TRAP="$(trap -p DEBUG | sed 's/^trap -- //')"

bash_preexec_hook() {
    # executed before command runs
    local current_command="$BASH_COMMAND"
    for fc in $METASHELL_FORBIDDEN_COMMANDS; do
        if [[ "$current_command" == "$fc" ]]; then
            echo "Aborting forbidden command: $fc"
            # Attempt to delete last history entry
            history -d $((HISTCMD-1)) 2>/dev/null
            # Clear command by setting should_execute_command=0
            should_execute_command=false
            return
        fi
    done
    echo "Preexec: $current_command"
    should_execute_command=true
}

bash_postexec_hook() {
    # executed after command runs (just before prompt)
    # only run if last command was allowed
    if [ "$should_execute_command" = true ]; then
        echo "Postexec: last command finished"
    fi
}

metashell_bash_enable_hooks() {
    # DEBUG trap as preexec
    # shellcheck disable=SC2086
    trap 'bash_preexec_hook' DEBUG

    local new_prompt_cmd='bash_postexec_hook'
    if [ "$METASHELL_MERGE_PROMPT" -eq 1 ] && [ -n "$ORIG_PROMPT_COMMAND" ]; then
        PROMPT_COMMAND="$ORIG_PROMPT_COMMAND; $new_prompt_cmd"
    else
        PROMPT_COMMAND="$new_prompt_cmd"
    fi

    echo "Bash hooks enabled."
}

metashell_bash_disable_hooks() {
    # Restore original DEBUG trap
    if [ -n "$ORIG_DEBUG_TRAP" ] && [ "$ORIG_DEBUG_TRAP" != "''" ]; then
        # shellcheck disable=SC2064
        trap $ORIG_DEBUG_TRAP DEBUG
    else
        trap - DEBUG
    fi

    # Restore original PROMPT_COMMAND
    PROMPT_COMMAND="$ORIG_PROMPT_COMMAND"

    echo "Bash hooks disabled."
}
