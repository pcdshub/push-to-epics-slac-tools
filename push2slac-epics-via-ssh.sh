#!/bin/bash
#
# Usage: ./push2slac-epics-via-ssh.sh
#  Updates all GitHub-mirrored EPICS module packages with a remote
#  named "github-slac".
#
#  Requires an SSH key that is:
#    1. Configured with GitHub
#    2. Added to your SSH agent (see ssh-add -l)
#
#  Pushes with --tags and --all, but avoids --mirror
#   (though I think --mirror *might* be better?)

for gitdir in ${GIT_TOP}/package/epics/modules/*.git ${GIT_TOP}/package/epics/base/base.git
do
    pushd "$gitdir" &> /dev/null || continue
    (git remote get-url --push github-slac &> /dev/null) && (
        echo "* Updating $gitdir ..."
        # git push --dry-run --mirror github-slac
        git push --all github-slac
        git push --tags github-slac
    ) || (
        echo "* $(basename $gitdir) is not on slac-epics"
    )
    popd &> /dev/null || exit 1
done
