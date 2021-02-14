#!/bin/sh
#
# oh-my-zsh
#

# Check for oh-my-zsh
if test ! $(which omz)
then
  echo "  Installing oh-my-zsh for you."

  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  
fi

exit 0
