#!/usr/bin/env zsh

# Zsh-specific hooking logic
autoload -Uz add-zsh-hook

: "${METASHELL_FORBIDDEN_COMMANDS:=forbidden_command}"  # Example customization

zsh_preexec() {
    local current_command=$1
    # Forbidden commands check
    for fc in ${(s: :)METASHELL_FORBIDDEN_COMMANDS}; do
        if [[ "$current_command" == "$fc" ]]; then
            echo "Aborting forbidden command: $fc"
            if [[ -o interactive && -n "$ZLE_LINE_TEXT" ]]; then
                zle kill-buffer
            fi
            return 1
        fi
    done

    echo "Preexec: $current_command"
    # Start per-command logging
    metashell_start_command_logging "$current_command"
}

zsh_precmd() {
    # Postexec
    # Stop per-command logging
    metashell_stop_command_logging
    echo "Postexec: last command finished"
}

metashell_zsh_enable_hooks() {
    add-zsh-hook preexec zsh_preexec
    add-zsh-hook precmd zsh_precmd
    echo "Zsh hooks enabled."
}

metashell_zsh_disable_hooks() {
    add-zsh-hook -d preexec zsh_preexec
    add-zsh-hook -d precmd zsh_precmd
    echo "Zsh hooks disabled."
}

# Command not found handling in Zsh
zsh_command_not_found_handler() {
    local cmd="$1"
    if (( ! IN_CNFH++ )) && metashell_handle_command_not_found "$cmd"; then
        "$@"
    else
        print -ru2 -- "command not found: $cmd"
        (( IN_CNFH-- ))
        return 127
    fi
    (( IN_CNFH-- ))
}
