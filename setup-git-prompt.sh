#!/bin/bash

# Download git completion and git prompt for .bashrc
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -O ~/git-completion.bash
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -O ~/git-prompt.sh

printf "\nsource ~/git-completion.bash" >> ~/.bashrc
printf "\nsource ~/git-prompt.sh\n" >> ~/.bashrc