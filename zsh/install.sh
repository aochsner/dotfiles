#!/bin/sh
#
# brew's zsh
#

# Check for brew's zsh
if [ "$SHELL" != "/usr/local/bin/zsh" ]
then
  echo "  Setting default shell to brew's zsh for you."

  sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
fi

exit 0

