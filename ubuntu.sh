#!/bin/bash

##############################################################
# CONFIG
##############################################################
GHR="https://raw.githubusercontent.com/lucasmouilleron/Survival/master"
##############################################################
# HELPERS
##############################################################
RED='\033[0;31m';GREEN='\033[0;33m';BLUE='\033[0;34m';NC='\033[0m'
printStep() {echo "$GREEN$1$NC";}
printError() {echo "$RED$1$NC";}
printSmallStep() {echo "$BLUE$1$NC";}
##############################################################
getGHConfigFile() {
    printSmallStep "Downloading file $GHR/configs/$1"
    if [ -f $1 ]; then cp $1 $1.back.$(date +%s); fi
    curl -O -sL --fail $GHR/configs/$1
    returnCode=$?
    if [ "$returnCode" -ne "0" ]; then
        printError "Can't download file $GHR/configs/$1 $returnCode"
    fi
}

##############################################################
# MAIN
##############################################################
printStep "Sudo ..."
read -p "What user has root rights and you know the password of (root*|username|skip) ? " answer
if [ "$answer" = "skip" ]; then
    printSmallStep "Skipping sudoing"
else
    if [ "$answer" = "" ]; then answer="root"; fi
    printSmallStep "Logging as $answer and making $USER sudoer"
    su - $answer -c "sudo usermod -aG sudo $USER"
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi
##############################################################
printStep "SSH key ...";mkdir -p .ssh;ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N ""
##############################################################
printStep "Installing binaries ..."
sudo apt-get -qq update;sudo apt-get install -qq -y curl git zsh vim glances xclip openssl tmux ca-certificates # main binaries
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" # oh my zsh
cd /usr/local/bin;curl -sS https://getmic.ro | sudo bash >/dev/null 2>&1;cd $HOME # micro
##############################################################
printStep "Configuring locales ..."
sudo locale-gen --purge en_US.UTF-8;echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' | sudo tee /etc/default/locale
##############################################################
printStep "Configuring ..."
cd $HOME;getGHConfigFile .zshrc
cd $HOME;getGHConfigFile .vimrc
cd $HOME;getGHConfigFile .selected_editor
cd $HOME;getGHConfigFile .hushlogin
cd $HOME;getGHConfigFile .tmux.conf

##############################################################
printStep "Done !"