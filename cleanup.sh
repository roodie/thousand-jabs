#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cd "${SCRIPT_DIR}"

tjfind() {
    find . \( "$@" \) -and -not -path './.git/*' -and -not -path './simc*' -and -not -path './Temp*' -print | sort
}

# Remove executable flag on all files
tjfind -type f | parallel "chmod -x '{1}'"

# Make sure scripts are executable
tjfind -iname '*.sh' -or -iname '*.pl' | parallel "chmod +x '{1}'"

# Make sure everything has Unix line endings
tjfind -iname '*.toc' -or -iname '*.lua' -or -iname '*.sh' -or -iname '*.pl' -or -iname '*.simc' -or -iname '*.xml' | parallel "dos2unix '{1}' >/dev/null 2>&1"

# Remove trailing whitespace
tjfind -iname '*.toc' -or -iname '*.lua' -or -iname '*.sh' -or -iname '*.py' -or -iname '*.simc' | parallel "sed -i 's/[ \t]*\$//' '{1}'"

# Reformat perl scripts
tjfind -iname '*.pl' | parallel "echo \"Formatting '{1}'\" && perltidy -pt=2 -dws -nsak='if for while' -l=200 '{1}' && cat '{1}.tdy' > '{1}' && rm '{1}.tdy'"

# Reformat lua files
tjfind -iname '*.lua' | parallel "echo \"Formatting '{1}'\" && luaformatter -a -s4 '{1}'"

# Disable devMode
tjfind -iname '*.lua' | parallel "sed -i 's/^local devMode = true/local devMode = false/' '{1}'"

# Install this script as a pre-commit hook if it's not already present
if [[ ! -L "${SCRIPT_DIR}/.git/hooks/pre-commit" ]] ; then
    (cd "${SCRIPT_DIR}/.git/hooks" && ln -sf ../../cleanup.sh pre-commit)
fi

# Drop out of "git commit" if there are any uncommitted changes after the cleanup.
if [[ ! -z "$(echo "${BASH_SOURCE[@]}" | grep "pre-commit")" ]] ; then
    [[ ! -z "$(git diff)" ]] && echo -e "\e[0;37m[\e[1;31mFAIL\e[0;37m]\e[0m Aborting commit: 'git diff' says changes are still present." && exit 1
fi

exit 0
