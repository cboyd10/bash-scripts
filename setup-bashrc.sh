#!/bin/bash
./setup-git-prompt.sh

# Set PS1 
# This sets the prompt display the $USER in a nice red color (31;1m) 
# and adds the git prompt PS1 which shows the git branch in git repo directories
# Example: [cboyd19 lighthouse (master)]$
sed -i 's|PS1=.*|PS1='\''\\e[31;1m[\\u \\W$(__git_ps1 "'" (%s)"'")]\\$\\e[m '\''|g' ~/.bashrc

source ~/.bashrc