#!/bin/bash
#
# Usage: ./create-new-slac-epics-repos.sh
#  Creates new GitHub-mirrored EPICS module packages with a remote
#  named "github-slac".
#
#  Requires an SSH key that is:
#    1. Configured with GitHub
#    2. Added to your SSH agent (see ssh-add -l)
#
#  Additionally requires the "gh" command-line tool (as available in pcds-envs)
#  in your PATH.

command -v gh || exit 1

for gitdir in ${GIT_TOP}/package/epics/modules/*.git
do
    # Skip symlinks
    if [ -L "$gitdir" ]; then
        echo "Skipping symlink $gitdir ..."
        continue
    fi

    pushd "$gitdir" &> /dev/null || continue
    gitname=$(basename $PWD)
    (git remote get-url --push github-slac &> /dev/null) || (
        repo_name=${gitname/.git/}
        full_repo_name="slac-epics/$repo_name"
        echo "* Creating new repository $full_repo_name for $gitdir ..."
        (cd /tmp && \
            gh repo create --confirm --enable-issues --enable-wiki --public \
            -d "${repo_name}: Mirror for $gitdir" $full_repo_name \
        ) || echo "gh repo create failed; maybe repository already exists?"
        git remote add github-slac git@github.com:$full_repo_name
        # git push --mirror github-slac
    ) || (
        echo "* $(basename $gitdir) is already on slac-epics"
    )
    popd &> /dev/null || exit 1
done
