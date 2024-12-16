#!/usr/bin/env bash
# run_tests.sh
#
# This script runs both Bats (Bash) tests and ZUnit (Zsh) tests.
#
# Prerequisites:
# - Bats: https://github.com/bats-core/bats-core
# - ZUnit: https://github.com/zunit-zsh/zunit
#
# Usage:
#   ./run_tests.sh
#
# Adjust paths as needed.

set -e
dir_base="/av/data/repos/metashell"


BASH_TESTS="${dir_base}/tests/test_bash.bats"
ZSH_TESTS="${dir_base}/tests/test_zsh.zunit"

# Check for Bats
if ! command -v bats &>/dev/null; then
    echo "Error: bats is not installed or not in PATH."
    echo "Please install bats: https://github.com/bats-core/bats-core"
    exit 1
fi

# Check for ZUnit
if ! command -v zunit &>/dev/null; then
    echo "Error: zunit is not installed or not in PATH."
    echo "Please install zunit: https://github.com/zunit-zsh/zunit"
    exit 1
fi

echo "Running Bash tests with Bats..."
bats_result=0
bats "$BASH_TESTS" || bats_result=$?

echo
echo "Running Zsh tests with ZUnit..."
zunit_result=0
zunit "$ZSH_TESTS" || zunit_result=$?

echo
echo "Test summary:"
if [ "$bats_result" -eq 0 ]; then
    echo "Bash tests (Bats): PASSED"
else
    echo "Bash tests (Bats): FAILED"
fi

if [ "$zunit_result" -eq 0 ]; then
    echo "Zsh tests (ZUnit): PASSED"
else
    echo "Zsh tests (ZUnit): FAILED"
fi

# If either test suite failed, exit with a non-zero code
if [ "$bats_result" -ne 0 ] || [ "$zunit_result" -ne 0 ]; then
    exit 1
fi

echo "All tests passed successfully."
exit 0
