#!/bin/bash

CURRENT_DIR=$(pwd)
BACKUP_DIR="$HOME/.dotfiles/backup/"

declare -a apt_packages=(
  "git"
  "docker.io"
  "docker-compose"
  "chromium-browser"
  "zsh"
  "virtualbox"
  "python-dev"
  "virtualenv"
  "build-essential"
  "gnome-tweak-tool"
  "numix-gtk-theme"
  "libssl-dev"
  "libc6-dev"
  "libncursesw5-dev"
  "libgdbm-dev"
  "libsqlite3-dev"
  "libbz2-dev"
  "zlib1g-dev"
)

declare -a symlink_dotfiles_source=(
  "$CURRENT_DIR/terminator/config"
  "$CURRENT_DIR/git/.gitconfig"
)

declare -a symlink_dotfiles_dest=(
  "$HOME/.config/terminator/config"
  "$HOME/.gitconfig"
)

declare -a ubuntu_appearance_gsetting=(
  "org.gnome.desktop.interface gtk-theme 'Numix'"
  "org.gnome.desktop.interface clock-show-date true"
  "org.gnome.desktop.calendar show-weekdate true"
  "org.gnome.nautilus.desktop home-icon-visible false"
  "org.gnome.nautilus.desktop volumes-visible false"
  "org.gnome.nautilus.desktop network-icon-visible false"
  "org.gnome.nautilus.desktop trash-icon-visible false"
)

print_error() {
  printf "\e[0;31m  [✖] $1 $2\e[0m\n"
}

print_info() {
  printf "\n\e[0;35m $1\e[0m\n"
}

print_question() {
  printf "\n\e[0;33m [?] $1\e[0m"
}

print_success() {
  printf "\e[0;32m [✔] $1\e[0m\n"
}

print_result() {
  [ $1 -eq 0 ] && print_success "${2:-Success}" || print_error "${3:-Failed}"
}

ask_for_sudo() {
  sudo -v &> /dev/null

  # Update existing sudo timestamp until this script has finished
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
        print_error "File with the same name already exists! ($1)"
      else
        print_success "$1"
      fi
    else
      execute "mkdir -p $1"
    fi
  fi
}

execute() {
  print_info "Execute: $1"
  $1 &> /dev/null
  print_result $? $2 $3
}

install_apt_packages() {
  print_info "Installing packages (can take a moment)"
  execute "sudo apt-get update"
  execute "sudo apt-get upgrade --yes"
  execute "sudo apt-get install --yes ${apt_packages[*]}"
}

backup_dotfiles() {
  mkd $backup_dir

  for i in ${symlink_dotfiles_source[@]}; do
    execute "cp --parents $i $BACKUP_DIR"
  done
}

symlink_dotfiles() {
  for i in ${!symlink_dotfiles_source[@]}; do
    execute "ln --symbolic --force ${symlink_dotfiles_source[$i]} ${symlink_dotfiles_dest[$i]}"
  done
}

ubuntu_appearance() {
  for i in ${!ubuntu_appearance_gsetting[@]}; do
    execute "gsettings set ${ubuntu_appearance_gsetting[$i]}"
  done
}

confirm() {
  while true; do
    print_question "$1 [Y/n]"
    read -p " " input

    case $input in
      [Yy]* )
        $2
        break;;
      [Nn]* )
        break;;
      * )
        $2
        break;;
      # * ) echo "Please answer yes or no.";;
    esac
  done
}

main() {
  ask_for_sudo

  confirm "Install apt packages?" install_apt_packages
  confirm "Backup original dotfiles?" backup_dotfiles
  confirm "Symlink dotfiles?" symlink_dotfiles
  confirm "Set appearances?" ubuntu_appearance
}

main
