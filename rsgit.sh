#!/bin/bash

# Config
repositories=(
    "roellsh=master"
    "web-template=master"
)
base_path="/mnt/d/workspace"
script_name="rsgit.sh"
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

install() {
    script_path="$(pwd)/$script_name"
    echo "${bold}Installing rsgit v${version}${normal}"
    echo -e "Install path: ${GREEN}${script_path}${SET}"
    local alias_path
    local install_path
    if [ -n "$($SHELL -c 'echo $ZSH_VERSION')" ]; then
        alias_path=~/.zshrc
        echo "ZSH shell detected"
    elif [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
        alias_path="$(checkBashDirs)"
        echo "BASH shell detected"
    else
        echo "${LIGHTRED}No bash or zsh shell detected to create write alias file${SET}"
    fi
    script_path="$(pwd)/$script_name"
    echo -e "Checking permissions to execute ${script_name}"
    if [[ ! -x "$script_path" ]]; then
        echo -e "Setting +x (execute permission) for ${GREEN}${script_path}${SET}"
        chmod +x $script_name
    fi
    echo -e "Writing alias to ${GREEN}${alias_path}${SET}"
    echo -e "Require administrator permission to write to ${GREEN}${alias_path}${SET}"
    sudo grep -q -F "$script_path" $alias_path || echo alias rsgit="$script_path" >>$alias_path
    echo -e "Done... Start new session and type ${bold}rsgit${normal}"
}

uninstall() {
    echo -e "${RED} install ${SET}"
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

checkBashDirs() {
    bash=~/.bashrc
    bash_profile=~/.bashrc_profile
    if [ -f $bash ]; then
        return $bash
    elif [ -f $bash_profile ]; then
        return $bash_profile
    else
        touch $bash
        return $bash
    fi
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
    "--uninstall") uninstall ;;
    "--help") _help ;;
    *) _help ;;
    esac
else
    menu
fi
