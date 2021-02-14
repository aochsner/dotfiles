#!/bin/sh
#
# oh-my-zsh
#

# Check for oh-my-zsh
if test ! $(typeset -f omz > /dev/null)
then
  echo "  Installing oh-my-zsh for you."

  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  
fi

exit 0
