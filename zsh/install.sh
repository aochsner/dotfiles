#!/bin/sh
#
# brew's zsh
#

# Check for brew's zsh
if [ "$SHELL" != "/opt/homebrew/bin/zsh" ]
then
  echo "  Setting default shell to brew's zsh for you."

  sudo dscl . -create /Users/$USER UserShell /opt/homebrew/bin/zsh
fi

exit 0

