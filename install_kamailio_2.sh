#!/bin/bash

# Vérifier si le script est exécuté avec des privilèges root
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté avec des privilèges root." 
   exit 1
fi

# Faire une sauvegarde de la configuration de base
echo "Sauvegarde de la configuration de Kamailio..."
sudo cp /usr/local/etc/kamailio/kamailio.cfg /usr/local/etc/kamailio/kamailio.cfg.bak

# Activer quelques modules
echo "Activation des modules dans la configuration..."
sed -i 's|^#!KAMAILIO|#!KAMAILIO\n#!define WITH_USRLOCDB\n#!define WITH_ACCDB|' /usr/local/etc/kamailio/kamailio.cfg

# Insérer la ligne DBURL avant #!ifdef WITH_MYSQL
echo "Insertion de la ligne DBURL dans la configuration..."
sed -i '/Global Parameters/i #!define DBURL "postgres://kamailio:kamailiorw@localhost/kamailio"' /usr/local/etc/kamailio/kamailio.cfg
sed -i '/loadmodule "tm.so"/i loadmodule "db_postgres.so"' /usr/local/etc/kamailio/kamailio.cfg
 



# Copier et configurer le script d'initialisation
echo "Configuration du script d'initialisation..."
cp /opt/kamailio/pkg/kamailio/deb/bullseye/kamailio.init /etc/init.d/kamailio
chmod 755 /etc/init.d/kamailio
sed -i 's|^PATH=.*|&:/usr/local/sbin:/usr/local/bin|' /etc/init.d/kamailio
sed -i 's|^DAEMON=/usr/sbin/kamailio|DAEMON=/usr/local/sbin/kamailio|' /etc/init.d/kamailio
sed -i 's|^HOMEDIR=/run/\$NAME|HOMEDIR=/var/run/\$NAME|' /etc/init.d/kamailio
sed -i 's|^CFGFILE=/etc/\$NAME/kamailio.cfg|CFGFILE=/usr/local/etc/kamailio/kamailio.cfg|' /etc/init.d/kamailio

# Copier et configurer le fichier par défaut
echo "Configuration du fichier par défaut..."
cp /opt/kamailio/pkg/kamailio/deb/bullseye/kamailio.default /etc/default/kamailio
sed -i 's|^#RUN_KAMAILIO=yes|RUN_KAMAILIO=yes|' /etc/default/kamailio
sed -i 's|^#USER=kamailio|USER=kamailio|' /etc/default/kamailio
sed -i 's|^#GROUP=kamailio|GROUP=kamailio|' /etc/default/kamailio
sed -i 's|^#SHM_MEMORY=64|SHM_MEMORY=64|' /etc/default/kamailio
sed -i 's|^#PKG_MEMORY=8|PKG_MEMORY=8|' /etc/default/kamailio
sed -i 's|^#CFGFILE=/etc/kamailio/kamailio.cfg|CFGFILE=/usr/local/etc/kamailio/kamailio.cfg|' /etc/default/kamailio

# Créer le répertoire d'exécution et l'utilisateur
echo "Création du répertoire d'exécution et de l'utilisateur Kamailio..."
mkdir -p /var/run/kamailio
adduser --quiet --system --group --disabled-password --shell /bin/false --gecos "Kamailio" --home /var/run/kamailio kamailio
chown kamailio:kamailio /var/run/kamailio

# Copier et configurer le fichier de service systemd
echo "Configuration du fichier de service systemd..."
cp /opt/kamailio/pkg/kamailio/deb/bullseye/kamailio.service /etc/systemd/system/kamailio.service
sed -i "s|CFGFILE=/etc/kamailio/kamailio.cfg|CFGFILE=/usr/local/etc/kamailio/kamailio.cfg|" /etc/systemd/system/kamailio.service
sed -i 's|^PIDFile=/run/kamailio/kamailio.pid|PIDFile=/var/run/kamailio/kamailio.pid|' /etc/systemd/system/kamailio.service
sed -i 's|ExecStart=/usr/sbin/kamailio|ExecStart=/usr/local/sbin/kamailio|' /etc/systemd/system/kamailio.service
sed -i 's|-P /run/kamailio/kamailio.pid|-P /var/run/kamailio/kamailio.pid|' /etc/systemd/system/kamailio.service


# Ajouter des utilisateurs Kamailio
echo "Ajout des utilisateurs Kamailio..."
kamctl add yebe yebe
kamctl add keffa keffa

echo "Installation et configuration de Kamailio terminées."
