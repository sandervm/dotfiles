#!/bin/bash

# https://github.com/alrra/dotfiles/blob/master/src/os/utils.sh

CWD=$(pwd)

backup_dir="$HOME/.dotfiles/backup/"

apt_packages=(
  "git"
  "docker.io"
  "docker-compose"
  "chromium-browser"
  "zsh"
  "virtualbox"
  "python-dev"
  "virtualenv"
  "build-essential"
  "libssl-dev"
  "gnome-tweak-tool"
  "numix-gtk-theme"
  "libc6-dev"
  "libncursesw5-dev"
  "libgdbm-dev"
  "libsqlite3-dev"
  "libbz2-dev"
  "zlib1g-dev"
)

symlink_dotfiles_source=(
  "$CWD/terminator/config"
  "$CWD/git/.gitconfig"
)

symlink_dotfiles_dest=(
  # "$HOME/.config/terminator/config"
  # "$HOME/.gitconfig"
  "/tmp/test1"
  "/tmp/test2"
)

print_error() {
  # Print output in red
  printf "\e[0;31m  [✖] $1 $2\e[0m\n"
}

print_info() {
  # Print output in purple
  printf "\n\e[0;35m $1\e[0m\n"
}

print_question() {
  # Print output in yellow
  printf "\e[0;33m [?] $1\e[0m"
}

print_success() {
  # Print output in green
  printf "\e[0;32m [✔] $1\e[0m\n"
}

print_result() {
  [ $1 -eq 0 ] && print_success "$2" || print_error "Failed"
  # [ "$3" == "true" ] && [ $1 -ne 0 ] && exit
}

ask_for_sudo() {
  sudo -v &> /dev/null

  # Update existing `sudo` time stamp until this script has finished
  # https://gist.github.com/cowboy/3118588
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &> /dev/null &
}

mkd() {
  if [ -n "$1" ]; then
    if [ -e "$1" ]; then
      if [ ! -d "$1" ]; then
        print_error "$1 - a file with the same name already exists!"
      else
        print_success "$1"
      fi
    else
      execute "mkdir -p $1" "$1"
    fi
  fi
}

execute() {
  print_info "Execute: $1"
  $1 &> /dev/null
  print_result $? "${2:-$1}"
}

install_apt_packages() {
  execute "sudo apt-get update" "Success"
  execute "sudo apt-get upgrade" "Success"
  execute "sudo apt-get install --yes ${apt_packages[*]}" "Success"
}

backup_dotfiles() {
  mkd $backup_dir

  for i in ${symlink_dotfiles_source[@]}; do
    execute "cp --parents $i $backup_dir" "Success"
  done
}

symlink_dotfiles() {
  # loop over all the keys of the array
  for i in ${!symlink_dotfiles_source[@]}; do
    execute "ln --symbolic --force ${symlink_dotfiles_source[$i]} ${symlink_dotfiles_dest[$i]}" "Success"
  done
}

confirm() {
  while true; do
    print_question "$1 [y/n]"
    read -p " " yn

    case $yn in
      [Yy]* )
        $2
        break
        ;;
      [Nn]* ) break;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

main() {
  ask_for_sudo

  confirm "Install apt packages?" install_apt_packages

  confirm "Backup original dotfiles?" backup_dotfiles

  confirm "Symlink dotfiles?" symlink_dotfiles
}

main
