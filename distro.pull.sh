#!/bin/bash
GITURL="http://git.drupal.org/project/wetkit.git"
BRANCH="7.x-4.x"
PREFIX="projects/wetkit"
echo "Pulling in latest updates on branch $BRANCH from remote $GITURL."

# Change to git root directory.
cd "$(git rev-parse --show-toplevel)"
git subtree pull --squash --prefix=$PREFIX $GITURL $BRANCH
