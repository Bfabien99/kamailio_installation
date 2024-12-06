#!/bin/bash

echo "## Welcome to the Kamailio 5.8 installation script."
sleep 0.5

## Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo ":: XX This script must be run with root privileges. Please try again with 'sudo'."
    exit 1
fi

## Check the distribution
if [[ -f /etc/os-release ]]; then
    distribution=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    echo ":: System details: $distribution ($codename)"
else
    echo ":: XX Unable to determine the distribution. Ensure your system uses /etc/os-release. XX"
    exit 1
fi

sleep 0.5
## Check if Kamailio is already installed
echo "## Checking if Kamailio is already installed"
sleep 1
if [[ -x /usr/local/sbin/kamailio ]] || command -v kamailio >/dev/null 2>&1; then
    echo ":: Kamailio is already installed on this system."
    sleep 0.5
    if command -v kamailio >/dev/null 2>&1; then
        echo ":: Using 'kamailio' via PATH to display the version."
        kamailio -V
    else
        echo ":: 'kamailio' is not in PATH, using /usr/local/sbin/kamailio."
        /usr/local/sbin/kamailio -V
    fi
    sleep 0.5
    echo "## Kamailio installation program ended."
    exit 0
fi

sleep 0.5
## Update APT repositories
echo "## Updating APT repositories..."
sleep 1
if ! apt update -y; then
    echo ":: X Failed to update APT repositories. X"
    echo "..."
fi

## Install dependencies
echo "## Installing required dependencies..."
sleep 1
deps=(make autoconf pkg-config git gcc g++ flex bison libssl-dev default-libmysqlclient-dev)

for dep in "${deps[@]}"; do
    echo "Installing $dep..."
    if ! apt install -y "$dep"; then
        echo ":: XX Failed to install $dep. XX"
        exit 1
    fi
    sleep 0.5
done

## Create the storage folder
echo "## Preparing the folder for Kamailio..."
sleep 1
kamailio_src="/usr/local/src/kamailio-5.8"
if [[ ! -d $kamailio_src ]]; then
    mkdir -p "$kamailio_src"
    echo ":: Folder created: $kamailio_src"
else
    echo ":: Folder already exists: $kamailio_src"
fi

sleep 0.5
## Clone the Git repository
echo "## Checking for the Kamailio repository in $kamailio_src..."
sleep 1
if [[ -d "$kamailio_src/kamailio/.git" ]]; then
    echo ":: The Kamailio repository is already cloned in $kamailio_src/kamailio."
    echo ":: Updating the existing repository..."
    cd "$kamailio_src/kamailio" || exit
    if git pull origin 5.8; then
        echo ":: The Kamailio repository was successfully updated."
    else
        echo ":: XX Failed to update the Git repository. XX"
        exit 1
    fi
else
    echo ":: Cloning the Kamailio repository into $kamailio_src..."
    cd "$kamailio_src" || exit
    if git clone --depth 1 --branch 5.8 https://github.com/kamailio/kamailio kamailio; then
        echo ":: The Kamailio repository was successfully cloned."
        cd "kamailio"
    else
        echo ":: XX Failed to clone the Git repository. Check your network connection. XX"
        exit 1
    fi
fi

sleep 0.5
## Compile and install
echo "## Compiling and installing Kamailio with db_mysql and tls modules..."
sleep 1
make clean
if ! make include_modules="db_mysql tls" cfg || ! make all || ! make install; then
    echo ":: XX Failed to compile or install Kamailio. XX"
    exit 1
fi

sleep 0.5
echo "## Installing the default MySQL server"
sleep 1
if ! apt -y install default-mysql-server; then
    echo ":: X Failed to install the default MySQL server. X"
    echo ":: X To use Kamailio with MySQL, you must install an SQL server later. X"
    echo "..."
fi

sleep 0.5
## Configure systemd services
echo "## Configuring systemd services for Kamailio..."
sleep 1
sudo chmod 755 /usr/sbin/adduser
sudo chown root:root /usr/sbin/adduser
export PATH=$PATH:/usr/sbin

if ! make install-systemd-debian || ! systemctl enable kamailio; then
    echo ":: X Failed to configure Kamailio with systemd. X"
fi
systemctl enable kamailio
systemctl daemon-reload
sudo chmod "$original_permissions" /usr/sbin/adduser
sudo chown "$original_owner" /usr/sbin/adduser

sleep 0.5
echo "## Adding Kamailio to the PATH"
sleep 1
echo 'PATH=$PATH:/usr/local/sbin' >> ~/.bashrc
echo 'export PATH' >> ~/.bashrc
source ~/.bashrc

sleep 0.5
echo "## Kamailio installation and configuration completed."
sleep 1
if command -v kamailio >/dev/null 2>&1; then
        echo ":: Using 'kamailio' via PATH to display the version."
        kamailio -V
    else
        echo ":: X 'kamailio' was not added to the PATH. Using /usr/local/sbin/kamailio.X "
        /usr/local/sbin/kamailio -V
    fi
echo "## Kamailio installation program ended."
echo ":: Starting Kamailio."
systemctl start kamailio
kamailio

sleep 0.5
echo "## Proceeding to configure your configuration files"
sleep 1
echo ">> Please enter your SIP domain:"
read sip_domain

while [ -z "$sip_domain" ]; do
    echo "No SIP domain entered. Please try again:"
    read sip_domain
done

config_file="/usr/local/etc/kamailio"

sed -i 's/^# DBENGINE=MYSQL/DBENGINE=MYSQL/' "$config_file/kamctlrc"
sed -i "s/^# SIP_DOMAIN=kamailio.org/SIP_DOMAIN=$sip_domain/" "$config_file/kamctlrc"
sed -i 's/^# DBRWPW="kamailiorw"/DBRWPW="kamailiorw"/' "$config_file/kamctlrc"
sed -i '/#!KAMAILIO/a \#!define WITH_MYSQL\n#!define WITH_AUTH\n#!define WITH_USRLOCDB' "$config_file/kamailio.cfg"

sleep 0.5
echo ":: Configuration updated."
kamdbctl create

sleep 0.5
# Générer un mot de passe aléatoire de 12 caractères
generate_password() {
    openssl rand -base64 12 | tr -dc 'a-zA-Z0-9@#$%&' | head -c 12
}

# Variables pour l'utilisateur
user1="test"
password1=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 12)

sleep 0.5
echo "## Creating a test user : $user"
sleep 1

echo "Ajout de l'utilisateur $user1 avec le mot de passe généré..."
kamctl add "$user1" "$password1"

if [ $? -eq 0 ]; then
    echo "Utilisateur $user1 ajouté avec succès. Mot de passe : $password1"
else
    echo "Échec lors de l'ajout de l'utilisateur $user1."
fi