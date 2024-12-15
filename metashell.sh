#!/usr/bin/env bash

# metashell.sh
# Main entry point. Source this file in your interactive shell.

# Detect shell if av_var_shell is not set
if [ -z "$av_var_shell" ]; then
    if [ -n "$ZSH_VERSION" ]; then
        av_var_shell="zsh"
    elif [ -n "$BASH_VERSION" ]; then
        av_var_shell="bash"
    else
        av_var_shell="unsupported"
    fi
fi

# Source modules
# Adjust paths as needed
. "/path/to/metashell-logging.sh"
. "/path/to/metashell-cnf.sh"

if [ "$av_var_shell" = "zsh" ]; then
    . "/path/to/metashell-zsh-hooks.sh"
elif [ "$av_var_shell" = "bash" ]; then
    . "/path/to/metashell-bash-hooks.sh"
else
    echo "Unsupported shell: $av_var_shell"
    return 1
fi

# Documentation
# av_fn_metashell_toggle [enable|disable] [options]
# Options can be passed as environment variables, e.g.:
# METASHELL_LOG_DIR, METASHELL_FORBIDDEN_COMMANDS, etc.
#
# Example:
# METASHELL_FORBIDDEN_COMMANDS="rm" av_fn_metashell_toggle enable

av_fn_metashell_toggle() {
    local action="$1"
    case "$action" in
        enable)
            metashell_enable_logging
            if [ "$av_var_shell" = "zsh" ]; then
                metashell_zsh_enable_hooks
                metashell_zsh_cnf_enable
            elif [ "$av_var_shell" = "bash" ]; then
                metashell_bash_enable_hooks
                metashell_bash_cnf_enable
            fi
            ;;
        disable)
            if [ "$av_var_shell" = "zsh" ]; then
                metashell_zsh_disable_hooks
            elif [ "$av_var_shell" = "bash" ]; then
                metashell_bash_disable_hooks
            fi
            metashell_disable_logging
            ;;
        *)
            echo "Invalid action: '$action'"
            return 1
            ;;
    esac
}
