GIT_PUBLIC=$HOME/GIT
LOCAL_BIN=$HOME/bin
mkdir -p $HOME/.bash_sources

PACKAGES=(
  awscli
  dhcp-client
  eza
  gh
  glab
  golang-bin
  graphviz
  ipython3
  jq
  nmap
  nodejs24-bin
  python3-autopep8
  terraform
  tmux
  tmux-powerline
  vim
  vim-pathogen
  awesome-vim-colorschemes
  # AWS session manager:
  # https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
  https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
)

dnf -y update
dnf install -y ${PACKAGES[*]}

# GoReleaser -- https://goreleaser.com/

echo '[goreleaser]
name=GoReleaser
baseurl=https://repo.goreleaser.com/yum/
enabled=1
gpgcheck=0
exclude=goreleaser-pro' | sudo tee /etc/yum.repos.d/goreleaser.repo
dnf install -y goreleaser

# saml2aws -- https://github.com/Versent/saml2aws
mkdir -p $GIT_PUBLIC
cd $GIT_PUBLIC
git clone git clone https://github.com/Versent/saml2aws.git
cd saml2aws
sed -i -e '/^ci:/s/^/#/' Makefile # there was missing target
make
make install

mkdir -p ~/bin

#
# Session Manager Plugin for AWS CLI
# https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-linux.html
dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

# GhosTTY
#
# dnf copr enable scottames/ghostty
# dnf install ghostty

# Terraform Switcher
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/master/install.sh |\
     bash -s -- -b $LOCAL_BIN

# Nice color scheme for ViM
# https://github.com/tpope/vim-vividchalk/tree/master
curl -o $HOME/.vim/colors/vividchalk.vim \
    https://raw.githubusercontent.com/tpope/vim-vividchalk/refs/heads/master/colors/vividchalk.vim

# Git settings
git config --global core.editor "vim"
git config --global push.autoSetupRemote true

# Copilot CLI
# https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli
curl -fsSL https://gh.io/copilot-install | PREFIX=$HOME bash

# Claude Code CLI
# https://docs.claude.com/en/docs/claude-code/setup
# The official installer drops the binary in ~/.local/bin; symlink it into
# $LOCAL_BIN.
curl -fsSL https://claude.ai/install.sh | bash
ln -sf "$HOME/.local/bin/claude" "$LOCAL_BIN/claude"

# Notes:
#
# Slow networking in VirtualBox guest
# -----------------------------------
#
# Find the Command Prompt icon, right click it and choose Run As Administrator.
# Enter this command:
#    bcdedit /set hypervisorlaunchtype off
#    DISM /Online /Disable-Feature:Microsoft-Hyper-V
#
# https://forums.virtualbox.org/viewtopic.php?f=25&t=99390

