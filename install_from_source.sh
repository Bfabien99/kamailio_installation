#!/bin/bash

# function to get colored text
color_red() { echo -e "\e[31m$1\e[0m"; }
color_green() { echo -e "\e[32m$1\e[0m"; }
color_yellow() { echo -e "\e[33m$1\e[0m"; }
color_blue() { echo -e "\e[34m$1\e[0m"; }

color_yellow "## Welcome to the Kamailio 5.8 installation script."
sleep 0.5

## Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    colored_red ":: XX This script must be run with root privileges. Please try again with 'sudo'."
    exit 1
fi

## Check the distribution
if [[ -f /etc/os-release ]]; then
    distribution=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    colored_green ":: System details: $distribution ($codename)"
else
    colored_red ":: XX Unable to determine the distribution. Ensure your system uses /etc/os-release. XX"
    exit 1
fi

sleep 0.5
## Check if Kamailio is already installed
colored_yellow "## Checking if Kamailio is already installed"
sleep 1
if [[ -x /usr/local/sbin/kamailio ]] || command -v kamailio >/dev/null 2>&1; then
    colored_green ":: Kamailio is already installed on this system."
    sleep 0.5
    if command -v kamailio >/dev/null 2>&1; then
        colored_green ":: Using 'kamailio' via PATH to display the version."
        kamailio -V
    else
        colored_green ":: 'kamailio' is not in PATH, using /usr/local/sbin/kamailio."
        /usr/local/sbin/kamailio -V
    fi
    sleep 0.5
    colored_yellow "## Kamailio installation program ended."
    exit 0
fi

sleep 0.5
## Update APT repositories
colored_yellow "## Updating APT repositories..."
sleep 1
if ! apt update -y; then
    colored_yellow ":: X Failed to update APT repositories. X"
    colored_yellow "..."
fi

## Install dependencies
colored_yellow "## Installing required dependencies..."
sleep 1
deps=(make autoconf pkg-config git gcc g++ flex bison libssl-dev default-libmysqlclient-dev)

for dep in "${deps[@]}"; do
    echo "Installing $dep..."
    if ! apt install -y "$dep"; then
        colored_red ":: XX Failed to install $dep. XX"
        exit 1
    fi
    sleep 0.5
done

## Create the storage folder
colored_yellow "## Preparing the folder for Kamailio..."
sleep 1
kamailio_src="/usr/local/src/kamailio-5.8"
if [[ ! -d $kamailio_src ]]; then
    mkdir -p "$kamailio_src"
    colored_green ":: Folder created: $kamailio_src"
else
    colored_green ":: Folder already exists: $kamailio_src"
fi

sleep 0.5
## Clone the Git repository
colored_yellow "## Checking for the Kamailio repository in $kamailio_src..."
sleep 1
if [[ -d "$kamailio_src/kamailio/.git" ]]; then
    colored_green ":: The Kamailio repository is already cloned in $kamailio_src/kamailio."
    colored_green ":: Updating the existing repository..."
    cd "$kamailio_src/kamailio" || exit
    if git pull origin 5.8; then
        colored_green ":: The Kamailio repository was successfully updated."
    else
        colored_red ":: XX Failed to update the Git repository. XX"
        exit 1
    fi
else
    colored_green ":: Cloning the Kamailio repository into $kamailio_src..."
    cd "$kamailio_src" || exit
    if git clone --depth 1 --branch 5.8 https://github.com/kamailio/kamailio kamailio; then
        colored_green ":: The Kamailio repository was successfully cloned."
        cd "kamailio"
    else
        colored_red ":: XX Failed to clone the Git repository. Check your network connection. XX"
        exit 1
    fi
fi

sleep 0.5
## Compile and install
colored_yellow "## Compiling and installing Kamailio with db_mysql and tls modules..."
sleep 1
make clean
if ! make include_modules="db_mysql tls" cfg || ! make all || ! make install; then
    colored_red ":: XX Failed to compile or install Kamailio. XX"
    exit 1
fi

sleep 0.5
colored_yellow "## Installing the default MySQL server"
sleep 1
if ! apt -y install default-mysql-server; then
    colored_yellow ":: X Failed to install the default MySQL server. X"
    colored_yellow ":: X To use Kamailio with MySQL, you must install an SQL server later. X"
    colored_yellow "..."
fi

sleep 0.5
## Configure systemd services
colored_yellow "## Configuring systemd services for Kamailio..."
sleep 1
sudo chmod 755 /usr/sbin/adduser
sudo chown root:root /usr/sbin/adduser
export PATH=$PATH:/usr/sbin

if ! make install-systemd-debian || ! systemctl enable kamailio; then
    colored_yellow ":: X Failed to configure Kamailio with systemd. X"
fi
systemctl enable kamailio
systemctl daemon-reload
sudo chmod "$original_permissions" /usr/sbin/adduser
sudo chown "$original_owner" /usr/sbin/adduser

sleep 0.5
colored_yellow "## Adding Kamailio to the PATH"
sleep 1
echo 'PATH=$PATH:/usr/local/sbin' >> ~/.bashrc
echo 'export PATH' >> ~/.bashrc
source ~/.bashrc

sleep 0.5
colored_yellow "## Kamailio installation and configuration completed."
sleep 1
if command -v kamailio >/dev/null 2>&1; then
        colored_green ":: Using 'kamailio' via PATH to display the version."
        kamailio -V
    else
        colored_yellow ":: X 'kamailio' was not added to the PATH. Using /usr/local/sbin/kamailio.X "
        /usr/local/sbin/kamailio -V
    fi
colored_yellow "## Kamailio installation program ended."
colored_green ":: Starting Kamailio."
systemctl start kamailio
kamailio

sleep 0.5
colored_yellow "## Proceeding to configure your configuration files"
sleep 1
colored_yellow ">> Please enter your SIP domain:"
read sip_domain

while [ -z "$sip_domain" ]; do
    colored_yellow "No SIP domain entered. Please try again:"
    read sip_domain
done

config_file="/usr/local/etc/kamailio"

sed -i 's/^# DBENGINE=MYSQL/DBENGINE=MYSQL/' "$config_file/kamctlrc"
sed -i "s/^# SIP_DOMAIN=kamailio.org/SIP_DOMAIN=$sip_domain/" "$config_file/kamctlrc"
sed -i 's/^# DBRWPW="kamailiorw"/DBRWPW="kamailiorw"/' "$config_file/kamctlrc"
sed -i '/#!KAMAILIO/a \#!define WITH_MYSQL\n#!define WITH_AUTH\n#!define WITH_USRLOCDB' "$config_file/kamailio.cfg"

sleep 0.5
colored_green ":: Configuration updated."
kamdbctl create

sleep 0.5
# Variables pour l'utilisateur
user1="test"
password1=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 12)

sleep 0.5
colored_yellow "## Creating a test user : $user"
sleep 1

colored_green ":: Adding user $user1 with the generated password..."
kamctl add "$user1" "$password1"

if [ $? -eq 0 ]; then
    colored_green ":: User $user1 successfully added. Password: $password1"
else
    colored_yellow ":: X Failed to add user $user1. X"
fi
colored_yellow "## End of the script"