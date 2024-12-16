# Metashell Project Documentation

## Overview

**Metashell** is a modular script-based framework that enhances interactive shell sessions—both in Bash and Zsh—by providing:

1. **Per-Command Hooks**: Run custom logic before and after every command executed in your shell (e.g., logging, filtering forbidden commands).
2. **Per-Command Logging**: Capture the output of every command into an individual logfile.
3. **Command Not Found Handling**: Intercept “command not found” errors, log them, and optionally attempt to rerun commands.
4. **Environment-Driven Customization**: Control various behaviors (e.g., log directories, forbidden commands) through environment variables.

Metashell integrates seamlessly with your interactive shell session without patching the shell. It uses native hooks and traps (Zsh’s `preexec`/`precmd` hooks; Bash’s `DEBUG` trap and `PROMPT_COMMAND`) to achieve desired behaviors.

**Key Features:**

- Compatible with both **Zsh** and **Bash**.
- Easily enable or disable functionality at runtime.
- Store each command’s output into a uniquely named logfile.
- Prevent execution of certain forbidden commands.
- Intercept and customize the behavior when a command is not found.
- Parameterize behavior using `METASHELL_` environment variables.

------

## Requirements

- An interactive shell session (Zsh or Bash).
- For Bash testing: [Bats](https://github.com/bats-core/bats-core)
- For Zsh testing: [ZUnit](https://github.com/zunit-zsh/zunit)

You must have `zsh` and `bash` installed if you intend to run tests or switch between shells.

------

## Installation

1. **Clone or Download the Project:**

    ```bash
    git clone https://example.com/metashell.git
    cd metashell
    ```

2. **Make the Scripts Executable (Optional):** While you can source them directly, you may want to ensure the main script has execute permissions:

    ```bash
    chmod +x metashell.sh
    ```

3. **Add Metashell to Your Shell Initialization File:** For Zsh, add to `~/.zshrc`:

    ```bash
    source /path/to/metashell/metashell.sh
    ```

    For Bash, add to `~/.bashrc`:

    ```bash
    source /path/to/metashell/metashell.sh
    ```

Next time you open a new interactive shell, Metashell will be available. However, it won’t run its hooks until you enable them.

------

## Configuration

**Metashell** uses environment variables to customize behavior. Set these variables **before** enabling Metashell hooks for them to take effect.

- **`METASHELL_LOG_DIR`**: Directory where per-command logfiles are stored. Default: `"$HOME/metashell_logs"`
- **`METASHELL_FORBIDDEN_COMMANDS`**: Space-separated list of commands that should be prevented from running. Default: `"forbidden_command"`
- **`METASHELL_RERUN_COMMAND_NOT_FOUND`**: Set to `1` to attempt rerunning unknown commands, or `0` to just report them. Default: `0`
- **`METASHELL_MERGE_PROMPT`** (Bash-only): Set to `1` to merge the postexec hook into your existing `PROMPT_COMMAND`, or `0` to overwrite it. Default: `0`

Example:

```bash
export METASHELL_LOG_DIR="$HOME/my_custom_logs"
export METASHELL_FORBIDDEN_COMMANDS="rm dangerous_command"
export METASHELL_RERUN_COMMAND_NOT_FOUND=1
export METASHELL_MERGE_PROMPT=1
```

------

## Usage

**Enable Hooks:** Once sourced, run:

```bash
av_fn_metashell_toggle enable
```

This sets up hooks, logging per command, and command-not-found handling.

**Disable Hooks:** To cleanly remove hooks and restore original shell behavior:

```bash
av_fn_metashell_toggle disable
```

**After enabling:**

- Every command you run will trigger a “Preexec” message and start a new logfile under `$METASHELL_LOG_DIR`.
- After the command finishes, a “Postexec” message is printed, and logging stops.
- If the command is forbidden, you’ll see an “Aborting forbidden command” message, and it will not execute.
- If you run a non-existent command, you’ll see a “command not found” message. If `METASHELL_RERUN_COMMAND_NOT_FOUND` is set to `1`, Metashell will attempt to rerun the command after handling it.

------

## Internals and Architecture

**File Structure:**

- `metashell.sh`: Main entry point that detects your shell and sources the appropriate modules.
- `metashell-logging.sh`: Functions for handling per-command logging. Stores original file descriptors, creates a logfile per command.
- `metashell-zsh-hooks.sh`: Zsh-specific hooks (`preexec`, `precmd`) to start/stop logging and handle forbidden commands.
- `metashell-bash-hooks.sh`: Bash-specific hooks (`DEBUG` trap and `PROMPT_COMMAND`) to achieve similar behavior.
- `metashell-cnf.sh`: Command-not-found handling logic for both Zsh and Bash.

**How Hooks Work:**

- In Zsh, `preexec` is called right before a command runs, and `precmd` is called before the next prompt is displayed (i.e., after the command finishes).
- In Bash, `trap '...' DEBUG` runs before each command, and `PROMPT_COMMAND` runs after the command completes, just before showing the next prompt.

**Per-Command Logging Mechanism:**

- On 

    ```
    preexec
    ```

    /

    ```
    DEBUG trap
    ```

    , Metashell:

    - Restores original stdout/stderr
    - Creates a unique logfile with a timestamp and sanitized command name
    - Redirects stdout/stderr into that logfile using `exec > >(tee -a logfile) 2>&1`

- On 

    ```
    precmd
    ```

    /

    ```
    PROMPT_COMMAND
    ```

    , Metashell:

    - Restores original stdout/stderr, closing the logfile for that command.

------

## Testing

The project comes with automated tests for both Bash and Zsh:

- **Bash Tests**: Written using [Bats](https://github.com/bats-core/bats-core).
- **Zsh Tests**: Written using [ZUnit](https://github.com/zunit-zsh/zunit).

**Test Scripts:**

- `metashell/tests/test_bash.bats`: Bash tests checking enabling/disabling hooks, forbidden commands, per-command logging, and command-not-found handling.
- `metashell/tests/test_zsh.zunit`: Zsh tests checking similar functionality.

**Running Tests:**

1. Ensure `bats` and `zunit` are installed and in your `$PATH`.

2. From the project root directory:

    ```bash
    ./run_tests.sh
    ```

    This script:

    - Runs the Bash tests via Bats.
    - Runs the Zsh tests via ZUnit.
    - Prints a summary of results.

If all tests pass, you’ll see a success message. If not, check the test output for diagnostic information.

------

## Troubleshooting

- **No Logs Appearing**:
     Check that `METASHELL_LOG_DIR` is writable and that hooks are enabled (`av_fn_metashell_toggle enable`).
- **Forbidden Commands Not Working**:
     Verify `METASHELL_FORBIDDEN_COMMANDS` is set correctly and that you’ve re-enabled hooks after changing the variable.
- **Command Not Found Behavior Not Triggering**:
     Ensure `METASHELL_RERUN_COMMAND_NOT_FOUND` is set before enabling. Check that you’re running a truly non-existent command.
- **Conflicts with Existing PROMPT_COMMAND (Bash)**:
     Set `METASHELL_MERGE_PROMPT=1` to merge Metashell’s postexec hook into your existing `PROMPT_COMMAND`.

------

## Limitations and Future Enhancements

- The project currently focuses on interactive usage. Non-interactive scripts might not invoke hooks as expected.
- Customizing per-command behavior could be expanded, for instance, by tagging commands or choosing different log directories based on patterns.
- Additional logging metadata (e.g., user, hostname, directory) can be incorporated into log filenames or file content.

------

## References and Credits

- **Bash and Zsh Manuals**:
    - [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)
    - [Zsh Manual](https://zsh.sourceforge.net/Doc/)
- **Bats for Bash Testing**:
     https://github.com/bats-core/bats-core
- **ZUnit for Zsh Testing**:
     https://github.com/zunit-zsh/zunit

This documentation, code structure, and testing strategy aim to provide a robust, maintainable, and extensible platform for enhancing your interactive shell environment with Metashell.