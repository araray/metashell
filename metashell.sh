#!/usr/bin/env bash


# Main entry point. Source this file in your interactive shell.

#dir_base="$(dirname "$0")"
dir_base="/av/data/repos/metashell"

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
source "${dir_base}/metashell-logging.sh"
source "${dir_base}/metashell-cnf.sh"

if [ "$av_var_shell" = "zsh" ]; then
    . "${dir_base}/metashell-zsh-hooks.sh"
elif [ "$av_var_shell" = "bash" ]; then
    . "${dir_base}/metashell-bash-hooks.sh"
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
            # For per-command logging, we no longer do a global enable here
            # Logging starts per-command in hooks.
            # We could still note that logging is conceptually enabled.
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
            ;;
        *)
            echo "Invalid action: '$action'"
            return 1
            ;;
    esac
}
