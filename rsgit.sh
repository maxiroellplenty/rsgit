#!/bin/bash

# Config

repositories=(
    "roellsh=master"
    "web-template=master"
)
base_path="/workspace"
script_name="rsgit.sh"
config="config.cfg"
version=3

# Colors
DARKGRAY='\033[1;30m'
RED='\033[0;31m'
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
SET='\033[0m'

# Font
bold=$(tput bold)
normal=$(tput sgr0)

# Install vars
declare alias_path=""
declare install_path=""

install() {
    echo "${bold}Installing rsgit v${version}${normal}"

    if [ -f $config ]; then
        echo "Reading config";
        install_path=$(head -n 1 $config);
    else
        install_path="$(pwd)/$script_name";
    fi

    echo -e "Install path: ${GREEN}${install_path}${SET}";

    if [ -n "$($SHELL -c 'echo $ZSH_VERSION')" ]; then
        alias_path=~/.zshrc
        echo "ZSH shell detected"
    elif [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
        echo "BASH shell detected"
        check_bash_alias_files
    else
        echo "${RED}No bash or zsh shell detected to create write alias file${SET}"
    fi
    echo -e "Writing alias to ${GREEN}${alias_path}${SET}"
    grep -q -F "$install_path" $alias_path || echo alias rsgit="$install_path" >>$alias_path
    echo "Saving config"
    if [ -f $config ]; then
        echo $install_path > $config
        echo $alias_path >> $config
    else
        touch $config
        echo $install_path >config.cfg
        echo $alias_path >>config.cfg
    fi
    echo -e "Done... Start new session and type ${bold}rsgit${normal}"
}

uninstall() {
    install_path=$(head -n 1 $config);
    alias_path=$(cat $config | head -2 | tail -1);
    dir=$(dirname $install_path);
    echo "Removing $dir"
    rm -rf $dir;
    echo "Removing alias from $alias_path"
    line=$(grep -n "$install_path" $alias_path)
    line_to_remove=$(echo "$line" | grep -Eo '[0-9]{1,4}');
    sed $(echo "${line_to_remove}d") $alias_path;
    echo "Done";
}

menu() {
    cat <<"EOF"

   ___  ___________________
  / _ \/ __/ ___/  _/_  __/
 / , _/\ \/ (_ // /  / /   
/_/|_/___/\___/___/ /_/  v3 by roelldev
                           
[1]  Pull repositories
[2]  List repositories
[3]  Reset repositories to base branch
[4]  Help
[99] Exit
EOF
    printf "%0.s-" {1..47}
    echo -e "\nEnter option: "
    local choice
    read choice
    case $choice in
    "1") pull_repos ;;
    "2") list_repos ;;
    "3") reset_repos_to_base ;;
    "4") _help ;;
    "99") exit 0 ;;
    *) menu ;;
    esac
    menu
}

pull_repos() {
    for repo in "${repositories[@]}"; do
        if [[ $repo == *"="* ]]; then
            repo_path="$(cut -d '=' -f1 <<<$repo)"
        else
            repo_path=$repo
        fi
        dir="$base_path/$repo_path"
        cd $dir
        echo -e "Pulling: ${BLUE}$(basename $(pwd))${SET} | ${PURPLE}$(getCurrentBranch)${SET}"
        pull
    done
}

list_repos() {
    for repo in "${repositories[@]}"; do
        declare repo_path
        if [[ $repo == *"="* ]]; then
            repo_path="$(cut -d '=' -f1 <<<$repo)"
        else
            repo_path=$repo
        fi
        dir="$base_path/$repo_path"
        cd $dir
        if [[ -z $(git status --porcelain) ]]; then
            changes=""
        else
            changes="${GREEN}+${SET}${RED}-${SET}"
        fi
        echo -e "$(basename $(pwd)) ${bold}=> ${normal}${PURPLE}$(getCurrentBranch)${SET} $changes"
    done
    echo ""
}

reset_repos_to_base() {
    for repo in "${repositories[@]}"; do
        if [[ $repo == *"="* ]]; then
            repo_branch="$(cut -d '=' -f2 <<<$repo)"
            repo_path="$(cut -d '=' -f1 <<<$repo)"
            cd "$base_path/$repo_path"
            echo -e "${BLUE}${repo_path}${SET}:"
            pull
            git checkout $repo_branch
        else
            repo_path="$(cut -d '=' -f1 <<<$repo)"
            echo -e "${BLUE}${repo_path}${SET}:"
            echo -e "${YELLOW}No base branch found for repository ${repo_path} ${SET}"
        fi
    done
    echo ""
}

pull() {
    if [ -n "$(git status --porcelain)" ]; then
        stash
        git pull &>/dev/null
        echo -e "${GREEN} ✔️ ${SET} done"
    else
        git pull &>/dev/null
        echo -e "${GREEN} ✔️ ${SET} done"
    fi
}

stash() {
    name="rsgit_$(getCurrentBranch)_$(date +%F)_$(date +%T)"
    git stash save $name
}

getCurrentBranch() {
    echo $(git branch | grep \* | cut -d ' ' -f2)
}

check_bash_alias_files() {
    bash=~/.bashrc
    bash_profile=~/.bashrc_profile
    if [ -f $bash ]; then
        alias_path=$bash
    elif [ -f $bash_profile ]; then
        alias_path=$bash_profile
    else
        echo -e "${RED}Missing file ${bash} or ${bash_profile} cant write alias file${SET}"
        echo "Exiting install script..."
        exit
    fi
}

areYouSure()
{
    echo -e "${YELLOW} Are you sure you want to uninstall enter: [y,n] ${SET}";
    local choice
    read choice
    case $choice in
         "y"|"Y"|"YES"|"yes"|"Yes") $1;;
        *) exit;
    esac 
}

_help() {
    cat <<"EOF"
options:
--install
--uninstall
EOF
}

if [ -n "$1" ]; then
    case $1 in
    "--install") install ;;
    "--uninstall")areYouSure uninstall ;;
    "--help") _help ;;
    *) _help ;;
    esac
else
    menu
fi
