GIT_PUBLIC=$HOME/GIT
LOCAL_BIN=$HOME/bin

PACKAGES=(
  awscli 
  dhcp-client
  eza
  gh
  glab
  golang-bin
  ipython3
  jq 
  nmap
  nodejs24-bin
  python3-autopep8
  terraform
  tmux 
  tmux-powerline
  vim
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

# GhosTTY
#
# dnf copr enable scottames/ghostty
# dnf install ghostty

# Terraform Switcher
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/master/install.sh |\
     bash -s -- -b $LOCAL_BIN


# Git settings
git config --global core.editor "vim"

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

