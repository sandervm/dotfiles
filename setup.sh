#!/bin/bash

backup_dir="$HOME/.dotfiles_backup"

apt_packages=(
  "git"
  "docker.io"
  "docker-composer"
  "chromium-browser"
  "zsh"
  "virtualbox"
  "vlc"
  "python-dev"
  "virtualenv"
  "build-essential"
  "libncursesw5-dev"
  "libreadline5-dev"
  "libssl-dev"
  "libgdbm-dev"
  "libc6-dev"
  "libsqlite3-dev"
  "libbz2-dev"
  "zlib1g-dev"
  "libssl-dev"
)

symlink_dotfiles_source=(
  "./terminator/config"
  "./git/.gitconfig"
)

symlink_dotfiles_dest=(
  "$HOME/.config/terminator/config"
  "$HOME/.gitconfig"
)

print_error() {
  # Print output in red
  printf "\e[0;31m  [✖] $1 $2\e[0m\n"
}

print_info() {
  # Print output in purple
  printf "\n\e[0;35m $1\e[0m\n\n"
}

print_question() {
  # Print output in yellow
  printf "\e[0;33m  [?] $1\e[0m"
}

print_success() {
  # Print output in green
  printf "\e[0;32m  [✔] $1\e[0m\n"
}

print_result() {
  [ $1 -eq 0 ] && print_success "$2" || print_error "$2"
  [ "$3" == "true" ] && [ $1 -ne 0 ] && exit
}

ask_for_sudo() {
    sudo -v &> /dev/null
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
  $1 &> /dev/null
  print_result $? "${2:-$1}"
}

install_apt_packages() {
  sudo apt-get update
  print_success "apt-get update"

  sudo apt-get upgrade
  print_success "apt-get upgrade"

  sudo apt-get install ${apt_packages[@]}
}

backup_dotfiles() {
  mkd $backup_dir
}

symlink_dotfiles() {
  for i in ${symlink_dotfiles[@]}; do
    execute i
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

  # print_info "Symlink dotfiles: ${apt_packages[*]}"
}

main
