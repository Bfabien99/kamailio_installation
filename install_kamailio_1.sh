#!/bin/bash

# Mettre à jour le système et installer les dépendances
echo "Mise à jour du système et installation des dépendances..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y git build-essential flex bison libmariadb-dev libpq5 libpq-dev \
    libssl-dev libcurl4-openssl-dev libxml2-dev libpcre3-dev libunistring-dev \
    libglib2.0-dev libncurses5-dev libncursesw5-dev pkg-config libtool libsqlite3-dev libjansson-dev libunwind-dev \
    libsnmp-dev libhiredis-dev libsystemd-dev libpcre2-dev gcc make libevent-dev libspandsp-dev libmosquitto-dev \
    libwebsockets-dev libopus-dev

# Installer PostgreSQL et le client PostgreSQL
echo "Installation de PostgreSQL et des pilotes..."
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Démarrer et activer le service PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Modifier le mot de passe de l'utilisateur 'postgres'
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'Nan2019#23';"

# Configure .pgpass file for credentials
{
  echo "localhost:5432:kamailio:postgres:Nan2019#23"
  echo "localhost:5432:kamailio:kamailio:kamailiorw"
} >> ~/.pgpass

chmod 600 ~/.pgpass

# Update PostgreSQL configuration to listen on all addresses
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/13/main/postgresql.conf

# Allow specific host in pg_hba.conf
echo "host    all             all             160.155.249.176/32      md5" | sudo tee -a /etc/postgresql/13/main/pg_hba.conf

# Restart PostgreSQL service
sudo systemctl restart postgresql

echo "PostgreSQL a été installé et configuré avec succès."


cd /opt
# Cloner le dépôt Kamailio depuis GitHub
echo "Clonage du dépôt Kamailio..."
git clone https://github.com/kamailio/kamailio.git
cd kamailio

# Compiler et installer Kamailio
echo "Compilation et installation de Kamailio..."
make clean
make include_modules="db_postgres tls websocket" cfg
make all
sudo make install

# Modifier le fichier de configuration de Kamailio pour utiliser PostgreSQL
sed -i 's/^# DBENGINE=MYSQL/DBENGINE=PGSQL/' /usr/local/etc/kamailio/kamctlrc
sed -i 's/^# SIP_DOMAIN=kamailio.org/SIP_DOMAIN=lab22.alcall.net/' /usr/local/etc/kamailio/kamctlrc
sed -i 's/^# DBPORT=3306/DBPORT=5432/' /usr/local/etc/kamailio/kamctlrc
sed -i 's/^# \(DBRWUSER="kamailio"\)/\1/' /usr/local/etc/kamailio/kamctlrc
sed -i 's/^# \(DBRWPW="kamailiorw"\)/\1/' /usr/local/etc/kamailio/kamctlrc
sed -i 's/^# \(DBROUSER="kamailioro"\)/\1/' /usr/local/etc/kamailio/kamctlrc
sed -i 's/^# \(DBROPW="kamailioro"\)/\1/' /usr/local/etc/kamailio/kamctlrc

# Initialiser la base de données Kamailio
echo "Initialisation de la base de données Kamailio..."
export PGPASSWORD="Nan2019#23"
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
sudo /usr/local/sbin/kamdbctl create