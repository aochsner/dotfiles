#!/bin/sh

# Only run on macOS
if test "$(uname)" != "Darwin"
then
  exit 0
fi

# Don't display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
