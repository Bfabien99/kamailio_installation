#!/bin/bash

echo "## Bienvenue dans le script d'installation de Kamailio 5.8."
sleep 0.5

## Vérifier que le script est lancé en mode root
if [[ $EUID -ne 0 ]]; then
    echo ":: XX Ce script doit être exécuté avec des privilèges root. Veuillez réessayer avec 'sudo'."
    exit 1
fi

## Vérifier la distribution
if [[ -f /etc/os-release ]]; then
    distribution=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    echo ":: Détails du système : $distribution ($codename)"
else
    echo ":: XX Impossible de déterminer la distribution. Assurez-vous que votre système utilise /etc/os-release. XX"
    exit 1
fi

sleep 0.5
## Vérifier si Kamailio est déjà installé
echo "## Vérification de l'existence de Kamailio"
sleep 0.5
if [[ -x /usr/local/sbin/kamailio ]] || command -v kamailio >/dev/null 2>&1; then
    echo ":: Kamailio est déjà installé sur ce système."
    sleep 0.5
    if command -v kamailio >/dev/null 2>&1; then
        echo ":: Utilisation de 'kamailio' via le PATH pour afficher la version."
        kamailio -V
    else
        echo ":: 'kamailio' n'est pas dans le PATH, utilisation de /usr/local/sbin/kamailio."
        /usr/local/sbin/kamailio -V
    fi
    sleep 0.5
    echo "## Fin du programme d'installation de Kamailio"
    exit 0
fi

sleep 0.5 ## Mettre à jour les dépôts APT
echo "## Mise à jour des dépôts APT..."
sleep 0.5
if ! apt update -y; then
    echo ":: X Échec lors de la mise à jour des dépôts APT. X"
    echo "..."
fi

## Installation des dépendances
echo "## Installation des dépendances requises..."
sleep 0.5
deps=(make autoconf pkg-config git gcc g++ flex bison libssl-dev default-libmysqlclient-dev)

for dep in "${deps[@]}"; do
    echo "Installation de $dep..."
    if ! apt install -y "$dep"; then
        echo ":: XX L'installation de $dep a échoué. XX"
        exit 1
    fi
    sleep 0.5
done

## Création du dossier de stockage
echo "## Préparation du dossier pour Kamailio..."
kamailio_src="/usr/local/src/kamailio-5.8"
if [[ ! -d $kamailio_src ]]; then
    mkdir -p "$kamailio_src"
    echo ":: Dossier créé : $kamailio_src"
else
    echo ":: Dossier déjà existant : $kamailio_src"
fi

sleep 0.5
## Clonage du dépôt Git
# Vérifier si le dépôt a déjà été cloné
echo "## Vérification de l'existence du dépôt Kamailio dans $kamailio_src..."
if [[ -d "$kamailio_src/kamailio/.git" ]]; then
    echo ":: Le dépôt Kamailio est déjà cloné dans $kamailio_src/kamailio."
    echo ":: Mise à jour du dépôt existant..."
    cd "$kamailio_src/kamailio" || exit
    if git pull origin 5.8; then
        echo ":: Le dépôt Kamailio a été mis à jour avec succès."
    else
        echo ":: XX Échec de la mise à jour du dépôt Git. XX"
        exit 1
    fi
else
    echo ":: Clonage du dépôt Kamailio dans $kamailio_src..."
    cd "$kamailio_src" || exit
    if git clone --depth 1 --branch 5.8 https://github.com/kamailio/kamailio kamailio; then
        echo ":: Le dépôt Kamailio a été cloné avec succès."
        cd "kamailio"
    else
        echo ":: XX Échec du clonage du dépôt Git. Vérifiez votre connexion réseau. XX"
        exit 1
    fi
fi

sleep 0.5
## Compilation et installation
echo "## Compilation et installation de Kamailio avec les modules db_mysql et tls..."
make clean
if ! make include_modules="db_mysql tls" cfg || ! make all || ! make install; then
    echo ":: XX La compilation ou l'installation de Kamailio a échoué. XX"
    exit 1
fi

sleep 0.5
echo "## Installation du serveur mysql par défaut"
sleep 0.5
if ! apt -y install default-mysql-server; then
    echo ":: X Échec lors de l'installation du serveur mysql par défaut. X"
    echo ":: X Pour utiliser kamailio avec mysql vous devez installer un serveur. X"
    echo "..."
fi

sleep 0.5
## Configuration des services systemd
echo "## Configuration des services systemd pour Kamailio..."
# Sauvegarder les permissions actuelles de la commande 'adduser'
original_permissions=$(stat -c "%a" /usr/sbin/adduser)
original_owner=$(stat -c "%U:%G" /usr/sbin/adduser)

# Modifier les permissions pour permettre l'exécution par tous
sudo chmod 755 /usr/sbin/adduser
sudo chown root:root /usr/sbin/adduser

# Ajouter /usr/sbin au PATH pour tous les utilisateurs de la session actuelle
export PATH=$PATH:/usr/sbin

if ! make install-systemd-debian || ! systemctl enable kamailio; then
    echo ":: X La configuration de Kamailio avec systemd a échoué. X"
fi
systemctl enable kamailio
systemctl daemon-reload

# Restaurer les permissions originales
sudo chmod "$original_permissions" /usr/sbin/adduser
sudo chown "$original_owner" /usr/sbin/adduser

echo "Permissions restaurées."

echo "## Copier et configurer le script d'initialisation"
cp $kamailio_src/kamailio/pkg/kamailio/deb/debian/kamailio.init /etc/init.d/kamailio
chmod 755 /etc/init.d/kamailio
sed -i 's|^PATH=.*|&:/usr/local/sbin:/usr/local/bin|' /etc/init.d/kamailio
sed -i 's|^DAEMON=/usr/sbin/kamailio|DAEMON=/usr/local/sbin/kamailio|' /etc/init.d/kamailio
sed -i 's|^CFGFILE=/etc/\$NAME/kamailio.cfg|CFGFILE=/usr/local/etc/kamailio/kamailio.cfg|' /etc/init.d/kamailio

sleep 0.5
## Fin
echo "## Installation et configuration de Kamailio terminées."
if command -v kamailio >/dev/null 2>&1; then
        echo ":: Utilisation de 'kamailio' via le PATH pour afficher la version."
        kamailio -V
    else
        echo ":: X 'kamailio' n'as pas être mis dans le PATH, utilisation de /usr/local/sbin/kamailio.X "
        /usr/local/sbin/kamailio -V
    fi
echo "## Fin du programme d'installation de Kamailio"
echo ":: Démarrage de kamailio."
systemctl start kamailio
kamailio