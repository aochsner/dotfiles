#!/bin/sh
#
# brew's zsh
#

# Check for brew's zsh
if [ "$SHELL" -ne "/usr/local/bin/zsh" ]
then
  echo "  Setting default shell to brew's zsh for you."

  sudo dscl . -create ~/ UserShell /usr/local/bin/zsh
fi

exit 0

